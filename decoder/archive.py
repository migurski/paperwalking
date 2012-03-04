from urllib import urlopen
from urlparse import urljoin, urlparse
from os.path import dirname, basename, relpath
from mimetypes import guess_type

from boto.s3.connection import S3Connection
from boto.exception import S3CreateError

from apiutils import ALL_FINISHED

def main(apibase, password, index_url, s3_access, s3_secret, bucket_name):
    """
    """
    yield 1
    
    s, index_host, index_path, q, p, f = urlparse(index_url)
    
    conn = S3Connection(s3_access, s3_secret, is_secure=False, host='s3.us.archive.org')
    
    try:
        bucket = conn.create_bucket(bucket_name)
    except S3CreateError:
        bucket = conn.get_bucket(bucket_name)
    
    for line in urlopen(index_url):
        item_url = urljoin(index_url, line.strip())
        
        s, item_host, item_path, q, p, f = urlparse(item_url)
        
        if item_host != index_host:
            item_name = basename(item_path)
        
        elif relpath(item_path, dirname(index_path)).startswith('../'):
            item_name = basename(item_path)
        
        else:
            item_name = relpath(item_path, dirname(index_path)).replace('/', '-')
        
        item_data = urlopen(item_url).read()
        item_type, enc = guess_type(item_url)
        
        key = bucket.new_key(item_name)
        key.set_contents_from_string(item_data, headers={'Content-Type': item_type}, policy='public-read')
        
        print dir(key)
        
        print item_name, 'from', key.generate_url(100)
        
        break
    
    yield ALL_FINISHED
