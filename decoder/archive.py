from sys import stderr
from time import sleep
from urllib import urlopen
from urlparse import urljoin, urlparse
from os.path import dirname, basename, relpath
from mimetypes import guess_type
from re import compile

from boto.s3.connection import S3Connection
from boto.exception import S3CreateError

from apiutils import get_scan_info, ALL_FINISHED

tile_pat = compile(r'^\d+/\d+/\d+\.\w+$')

html_template = """<!DOCTYPE html>
<html>
    <head>
        <title>%(item_title)s</title>
    </head>
    <body>
        <h1><a href="%(scan_url)s">Scan #%(scan_id)s</a></h1>
        <p>From <a href="%(site_url)s">%(scan_host)s</a>.</p>
        <ul>
            <li><a href="%(print_href)s">Print PDF</a></li>
            <li><a href="%(geotiff_href)s">GeoTIFF</a></li>
            <li><a href="%(tile_href)s">Sample spherical mercator tile</a></li>
        </ul>
        <p><a href="%(original_href)s"><img src="large.jpg" border="1"></a></p>
    </body>
</html>"""

def main(apibase, password, scan_url, index_url, s3_access, s3_secret, bucket_name):
    """
    """
    yield 15
    
    scan_id, place_woeid, place_name = get_scan_info(scan_url)
    
    s, scan_host, scan_path, q, p, f = urlparse(scan_url)
    site_url = 'http://' + scan_host + dirname(scan_path).rstrip('/') + '/'
    item_title = 'Map scan #%(scan_id)s from %(scan_host)s' % locals()
    
    meta = {'x-archive-meta-source': site_url,
            'x-archive-meta-title': item_title,
            'x-archive-meta-place-name': place_name,
            'x-archive-meta-place-woeid': place_woeid,
            'x-archive-meta-paperwalking': 'yes',
            'x-archive-meta-horse': 'yes'}
               
    conn = S3Connection(s3_access, s3_secret, is_secure=False, host='s3.us.archive.org')
    
    try:
        bucket = conn.create_bucket(bucket_name, headers=meta)
        
        # sleep while archive.org figures out that it really does have a bucket.
        sleep(5)

    except S3CreateError:
        bucket = conn.get_bucket(bucket_name)
    
    tile_size = -1
    
    print >> stderr, 'Archiving',
    
    yield 5*60
    
    s, index_host, index_path, q, p, f = urlparse(index_url)
    
    for (index, line) in enumerate(urlopen(index_url)):
        item_url = urljoin(index_url, line.strip())
        
        s, item_host, item_path, q, p, f = urlparse(item_url)
        item_relpath = relpath(item_path, dirname(index_path))
        
        if item_host != index_host:
            item_href = basename(item_path)
        
        elif item_relpath.startswith('../'):
            item_href = basename(item_path)
        
        else:
            item_href = item_relpath.replace('/', '-')
        
        item_data = urlopen(item_url).read()
        item_type, enc = guess_type(item_url)
        
        key = bucket.new_key(item_href)
        key.set_contents_from_string(item_data, headers={'Content-Type': item_type}, policy='public-read')
        
        if index == 0:
            # we know that the first item is the origin scan
            original_href = item_href
            print >> stderr, 'original',
        
        elif item_href == 'large.jpg':
            # alphabetically-first preview image
            key = bucket.new_key('--preview.jpg')
            key.set_contents_from_string(item_data, headers={'Content-Type': item_type}, policy='public-read')
            print >> stderr, 'preview',
        
        elif tile_pat.match(item_relpath):
            if index < 20 and len(item_data) > tile_size:
                # use the largest of the first few tiles as an example
                tile_href = item_href
                tile_size = len(item_data)

            print >> stderr, 't',
        
        elif item_href.endswith('.tif'):
            geotiff_href = item_href
            print >> stderr, 'geotiff',
        
        elif item_href.endswith('.pdf'):
            print_href = item_href
            print >> stderr, 'print pdf',
        
        else:
            print >> stderr, '.',

    print >> stderr, '.'
    
    yield 5

    html = html_template % locals()
    
    key = bucket.new_key('index.html')
    key.set_contents_from_string(html, headers={'Content-Type': 'text/html'}, policy='public-read')
    
    print >> stderr, 'http://www.archive.org/details/%s' % bucket_name
    print >> stderr, 'http://www.archive.org/download/%s/' % bucket_name
    
    yield ALL_FINISHED
