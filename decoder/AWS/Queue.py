import re, base64, hmac, sha, md5, time, httplib, urlparse, urllib
from xml.dom.minidom import parseString as parseXML

""" Access methods for Amazon Simple Queue Service.

    http://docs.amazonwebservices.com/AWSSimpleQueueService/2006-04-01/
"""

class Service:

    def __init__(self, access_key, secret_key, service_host='queue.amazonaws.com', aws_version='2006-04-01'):
        """ Create a queue service connection.
        
            Service(access_key, secret_key[, service_host[, aws_version]])
        """
        self.service_host = service_host
        self.aws_version  = aws_version
        self.access_key   = access_key
        self.secret_key   = secret_key
    
    
    
    def sendQueueServiceRequest(self, method, path, query='', data='', content_type='text/plain'):
        """ Make a request of Queue REST API.
        """
        date = time.strftime('%a, %d %b %Y %H:%M:%S %Z', time.localtime())
        content_md5 = base64.encodestring(md5.new(data).digest()).strip()
        authorization = 'AWS %s:%s' % (self.access_key, base64.encodestring(hmac.new(self.secret_key, '%(method)s\n%(content_md5)s\n%(content_type)s\n%(date)s\n%(path)s' % locals(), sha).digest()).strip())
    
        headers = {'Date': date, 'AWS-Version': self.aws_version,
                   'Content-Type': content_type, 'Content-MD5': content_md5,
                   'Content-Length': len(data), 'Authorization': authorization}
        
        while True:
            try:
                conn = httplib.HTTPConnection(self.service_host)
                conn.request(method, path + query, data, headers)
                return conn.getresponse()
            except:
                print 'Failed httplib.request, sleeping for 10 seconds...'
                time.sleep(10)
    
    
    
    def getQueues(self, name=re.compile(r'.*')):
        """ Retrieve a list of queue ID's.
        """
        return [urlparse.urlparse(QueueURL.firstChild.nodeValue)[2] for QueueURL
                in parseXML(self.sendQueueServiceRequest('GET', '/').read()).getElementsByTagName('QueueUrl')
                if name.search(str(QueueURL.firstChild.nodeValue))]
                
    
    
    def addQueue(self, queue_name):
        """ 
        """
        return [urlparse.urlparse(QueueURL.firstChild.nodeValue)[2] for QueueURL
                in parseXML(self.sendQueueServiceRequest('POST', '/', '?'+urllib.urlencode({'QueueName':queue_name})).read()).getElementsByTagName('QueueUrl')][0]
                
    
    
    def deleteQueue(self, queue_name, force=False):
        """ 
        """
        if force:
            query = '?ForceDeletion=true'
        else:
            query = '?ForceDeletion=false'
        
        return self.sendQueueServiceRequest('DELETE', queue_name, query).status == 200
                
    
    
    def sendQueueMessage(self, queue_name, message, visibility_timeout=0):
        """ Send one message to the queue.
        """
        return [str(MessageID.firstChild.nodeValue) for MessageID
                in parseXML(self.sendQueueServiceRequest('PUT', queue_name+'/back', '?VisibilityTimeout=%(visibility_timeout)d' % locals(), message).read()).getElementsByTagName('MessageId')][0]
    
    
    
    def messageNodeParts(self, message):
        """ Extract an ID and a body out of a message node.
        """
        message_id = str(message.getElementsByTagName('MessageId')[0].firstChild.nodeValue)
        message_body = str(message.getElementsByTagName('MessageBody')[0].firstChild.nodeValue)
        return (message_id, message_body)
    
    
    
    def getQueueMessages(self, queue_name, number_of_messages=255, visibility_timeout=0):
        """ Retrieve a variable number of messages from the queue, in (id, body) form.
        """
        return map(self.messageNodeParts, parseXML(self.sendQueueServiceRequest('GET', queue_name+'/front', '?NumberOfMessages=%(number_of_messages)d&VisibilityTimeout=%(visibility_timeout)d' % locals()).read()).getElementsByTagName('Message'))
    
    
    
    def getQueueMessage(self, queue_name, visibility_timeout=0):
        """ Retrieve one message from the queue, in (id, body) form.
        """
        try:
            return self.getQueueMessages(queue_name, 1, visibility_timeout)[0]
        except IndexError:
            return None
    
    
    
    def getMessage(self, queue_name, message_id):
        """ Get one message, in (id, body) form.
        
            Unlike self.getQueueMessage(), this has no effect on visibility timeout.
        """
        return self.messageNodeParts(parseXML(self.sendQueueServiceRequest('GET', '%(queue_name)s/%(message_id)s' % locals()).read()).getElementsByTagName('Message')[0])
    
    
    
    def deleteMessage(self, queue_name, message_id):
        """ Delete one message from the queue.
        """
        return str(parseXML(self.sendQueueServiceRequest('DELETE', '%(queue_name)s/%(message_id)s' % locals()).read()).getElementsByTagName('StatusCode')[0].firstChild.nodeValue)



if __name__ == '__main__':

    qs = Service('<Your Access Key Here>', '<Your Secret Key Here>')

    print 'Adding Queue...'
    queue_name = qs.addQueue('TestQueue')
    print '  Queue ID:', queue_name
    
    print 'Getting Queue...'
    queue_name = qs.getQueues(re.compile(r'/TestQueue$'))[0]
    print '  Queue ID:', queue_name
    
    print 'Sending Messages...'
    for i in range(1):
        message_id = qs.sendQueueMessage(queue_name, 'Hello World')
        print '  Message ID:', message_id
    
    while True:
        print 'Getting Messages...'
        for (message_id, message_body) in qs.getQueueMessages(queue_name):
            print '  Getting Message...'
            print '  Message:', qs.getMessage(queue_name, message_id)
        
            print '  Deleting Message...'
            print '  Status:', qs.deleteMessage(queue_name, message_id)

        print 'Deleting Queue...'
        if qs.deleteQueue(queue_name):
            print '  Finished.'
            break
        else:
            print '  Could not be deleted...'
