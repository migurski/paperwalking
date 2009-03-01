"""
Access methods for Amazon S3.
http://docs.amazonwebservices.com/AmazonS3/2006-03-01/

>>> ss = Service('<your AWS access key>', '<your AWS secret>')

Adding Bucket...
>>> ss.putBucket('magicalwonderbucket')
True

Getting Buckets...
>>> bucket_id = ss.getBuckets(re.compile(r'magicalwonderbucket'))[0]
>>> bucket_id
'magicalwonderbucket'

Putting Object...
>>> ss.putBucketObject(bucket_id, 'greeting', 'Hello World')
True

Getting Bucket Objects...
>>> object_id = ss.listBucketObjects(bucket_id)[0]
>>> object_id
'greeting'

Getting Object...
>>> ss.getBucketObject(bucket_id, object_id).read()
'Hello World'

Deleting Object...
>>> ss.deleteBucketObject(bucket_id, object_id)
True

Putting Object with Meta...
>>> object_id = 'greeting2'
>>> ss.putBucketObject(bucket_id, object_id, 'Hello World', meta={'Kind': 'Salutation'})
True

Getting Object with Meta...
>>> dict(ss.headBucketObject(bucket_id, object_id).getheaders()).get('x-amz-meta-kind')
'Salutation'

Deleting Object...
>>> ss.deleteBucketObject(bucket_id, object_id)
True

Deleting Bucket...
>>> ss.deleteBucket('magicalwonderbucket')
True
"""

import os, re, base64, hmac, sha, md5, time, httplib, urlparse, urllib, operator, cStringIO
from xml.dom.minidom import parseString as parseXML

try:
    os.SEEK_SET
except AttributeError:
    os.SEEK_SET, os.SEEK_CUR, os.SEEK_END = range(3)

class Service:

    def __init__(self, access_key, secret_key, service_host='s3.amazonaws.com'):
        """ Create a storage service connection.
        
            Service(access_key, secret_key[, service_host])
        """
        self.service_host = service_host
        self.access_key   = access_key
        self.secret_key   = secret_key
    
    
    
    def querySignature(self, path, data='', content_type='', timeout=60):
        """
        """
        canon_amz_headers = ''

        if data:
            content_md5 = base64.encodestring(md5.new(data).digest()).strip()
        else:
            content_md5 = ''
            
        expires = int(time.time() + timeout)
        sign_string = 'GET\n%(content_md5)s\n%(content_type)s\n%(expires)d\n%(canon_amz_headers)s%(path)s' % locals()
        
        query = {'AWSAccessKeyId': self.access_key,
                 'Signature': base64.encodestring(hmac.new(self.secret_key, sign_string, sha).digest()).strip(),
                 'Expires': expires}
        
        return path + '?' + urllib.urlencode(query)
    
    
    
    def sendS3ServiceRequest(self, method, path, query='', data='', content_type='text/plain', acl=None, meta=None, extra_headers={}):
        """ Make a request of S3 REST API.
            Valid ACL's: private, public-read, public-read-write, authenticated-read.
        """
        canon_amz_headers = ''

        if acl:
            canon_amz_headers += 'x-amz-acl:%(acl)s\n' % locals()
        
        if meta:
            key_values = meta.items()
            key_values.sort(key=operator.itemgetter(0))
            for key, value in meta.items():
                canon_amz_headers += 'x-amz-meta-%s:%s\n' % (key.lower(), value)

        date = time.strftime('%a, %d %b %Y %H:%M:%S %Z', time.localtime())
        content_md5 = base64.encodestring(md5.new(data).digest()).strip()
        sign_string = '%(method)s\n%(content_md5)s\n%(content_type)s\n%(date)s\n%(canon_amz_headers)s%(path)s' % locals()
        authorization = 'AWS %s:%s' % (self.access_key, base64.encodestring(hmac.new(self.secret_key, sign_string, sha).digest()).strip())
    
        headers = {'Date': date,
                   'Content-Type': content_type, 'Content-MD5': content_md5,
                   'Content-Length': len(data), 'Authorization': authorization}
                   
        if acl:
            headers['X-Amz-Acl'] = acl

        if meta:
            for key, value in meta.items():
                headers['X-Amz-Meta-%s' % key] = str(value)
                
        if extra_headers:
            for key, value in extra_headers.items():
                headers[key] = str(value)

        while True:
            try:
                conn = httplib.HTTPConnection(self.service_host)
                conn.request(method, path + query, data, headers)
                return conn.getresponse()
            except:
                print 'Failed httplib.request, sleeping for 10 seconds...'
                time.sleep(10)
    
    
    
    def putBucket(self, name, acl='private'):
        """ Add a new bucket.
            Valid ACL's: private, public-read, public-read-write, authenticated-read.
        """
        return self.sendS3ServiceRequest('PUT', '/'+name, acl=acl).status == 200
                
    
    
    def deleteBucket(self, name):
        """ Delete a bucket.
        """
        return self.sendS3ServiceRequest('DELETE', '/'+name).status == 204
                
    
    
    def getBuckets(self, name=re.compile(r'.*')):
        """ Retrieve a list of queue ID's.
        """
        return [str(BucketName.firstChild.nodeValue)
                for BucketName
                in [Bucket.getElementsByTagName('Name')[0]
                    for Bucket
                    in parseXML(self.sendS3ServiceRequest('GET', '/').read()).getElementsByTagName('Bucket')]
                if name.search(str(BucketName.firstChild.nodeValue))]
                
    
    
    def listBucketObjects(self, bucket_id, prefix='', marker='', max_keys=40):
        """ Retrieve a list of object ID's.
        """
        return [str(ObjectKey.firstChild.nodeValue)
                for ObjectKey
                in [Contents.getElementsByTagName('Key')[0]
                    for Contents
                    in parseXML(self.sendS3ServiceRequest('GET', '/'+bucket_id, '?'+urllib.urlencode({'prefix':prefix, 'marker':marker, 'max-keys':max_keys})).read()).getElementsByTagName('Contents')]]
                
    
    
    def putBucketObject(self, bucket_id, object_id, object_content, object_type='text/plain', acl='private', meta=None):
        """ Put one object into the bucket, return HTTP status code.
            Valid ACL's: private, public-read, public-read-write, authenticated-read.
        """
        return self.sendS3ServiceRequest('PUT', '/'+bucket_id+'/'+object_id, data=object_content, content_type=object_type, acl=acl, meta=meta).status == 200
                
    
    
    def getBucketObject(self, bucket_id, object_id, range=None):
        """ Get one object from the bucket, in HTTPResponse form.
            Range is an optional string that looks like 'bytes=0-100'.
        """
        if range:
            extra_headers = {'Range': range}
        else:
            extra_headers = {}
        
        return self.sendS3ServiceRequest('GET', '/'+bucket_id+'/'+object_id, extra_headers=extra_headers)
                
    
    
    def getBucketObjectSignedURL(self, bucket_id, object_id, timeout=60):
        """ Get one object from the bucket, in HTTPResponse form.
        """
        return 'http://s3.amazonaws.com' + self.querySignature('/%s/%s' % (bucket_id, object_id), timeout=timeout)
                
    
    
    def headBucketObject(self, bucket_id, object_id):
        """ Get information about an object from the bucket, in HTTPResponse form.
        """
        return self.sendS3ServiceRequest('HEAD', '/'+bucket_id+'/'+object_id)
                
    
    
    def deleteBucketObject(self, bucket_id, object_id):
        """ Delete one object from the bucket, return HTTP status code.
        """
        return self.sendS3ServiceRequest('DELETE', '/'+bucket_id+'/'+object_id).status == 204



class FileObject:

    def __init__(self, service, bucket, object, block_size=(16 * 1024)):
        self.service = service
        self.bucket = bucket
        self.object = object

        self.offset = 0
        self.length = int(self.service.headBucketObject(self.bucket, self.object).getheader('content-length'))
        self.chunks = {}
        
        self.block_size = block_size

    def byte(self, offset):
        """ Read a single byte from the resource at the specified offset.
        """
        chunk = self.block_size * (offset / self.block_size)
        chunk_offset = offset % self.block_size
        
        if not self.chunks.has_key(chunk):
            # get a chunk from S3
            range = self.service.getBucketObject(self.bucket, self.object, 'bytes=%d-%d' % (offset, offset + self.block_size - 1))
            self.chunks[chunk] = cStringIO.StringIO()
            self.chunks[chunk].write(range.read())
            range.close()
        
        self.chunks[chunk].seek(chunk_offset, os.SEEK_SET)
        return self.chunks[chunk].read(1)
    
    def read(self, count):
        """ Read /count/ bytes from the resource at the current offset.
        """
        out = cStringIO.StringIO()
        
        for i in range(self.offset, self.offset + count):
            out.write(self.byte(i))
            self.offset += 1

        out.seek(0)
        return out.read()

    def seek(self, offset, whence=os.SEEK_SET):
        """ Seek to the specified offset.
            /whence/ behaves as with other file-like objects:
                http://docs.python.org/lib/bltin-file-objects.html
        """
        if whence == os.SEEK_SET:
            self.offset = offset
        elif whence == os.SEEK_CUR:
            self.offset += offset
        elif whence == os.SEEK_END:
            self.offset = self.length - offset
    
    
    
    
if __name__ == '__main__':
    import doctest
    doctest.testmod()
