import sys
import time
import urllib
import httplib
import os.path
import decode

if __name__ == '__main__':
    markers = {}

    for basename in ('Reader', 'Spout-1', 'Spout-2'):
        basepath = os.path.dirname(os.path.realpath(__file__)) + '/Gargoyles/' + basename
        markers[basename] = decode.Marker(basepath)
    
    #curl -s --form timeout=5 "http://www.paperwalking.com/paperwalking/site/www/dequeue.php
    
    params = urllib.urlencode({'timeout': 5})
    
    print params
    
    req = httplib.HTTPConnection('paperwalking.com', 80)
    req.request('POST', '/paperwalking/site/www/dequeue.php', params, {'Content-Type': 'application/x-www-form-urlencoded'})
    res = req.getresponse()
    
    assert res.status == 200
    
    try:
        message_id, url = res.read().split()
        message_id = int(message_id)
    except:
        pass
    else:
        print message_id
        decode.main(url, markers)
    
    
