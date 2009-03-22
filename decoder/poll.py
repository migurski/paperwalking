import sys
import time
import urllib
import httplib
import os.path
import datetime
import decode

if __name__ == '__main__':
    markers = {}

    for basename in ('Header', 'Hand', 'CCBYSA'):
        basepath = os.path.dirname(os.path.realpath(__file__)) + '/corners/' + basename
        markers[basename] = decode.Marker(basepath)
    
    while True:
        try:
            params = urllib.urlencode({'timeout': 5})
            
            req = httplib.HTTPConnection('paperwalking.com', 80)
            req.request('POST', '/paperwalking/site/www/dequeue.php', params, {'Content-Type': 'application/x-www-form-urlencoded'})
            res = req.getresponse()
            
            assert res.status == 200
            
            try:
                message_id, url = res.read().split()
                message_id = int(message_id)
            except ValueError:
                # probably no queue message
                pass
            else:
                print >> sys.stderr, datetime.datetime.now(), 'Decoding message id', message_id, '-', url
                decode.main(url, markers, 'http://www.paperwalking.com/paperwalking/site/www', message_id)

        except KeyboardInterrupt:
            raise

        except Exception, e:
            print >> sys.stderr, 'Something went wrong, authorities are being notified:', e
            raise

        time.sleep(5)
