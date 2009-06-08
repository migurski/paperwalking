import os
import sys
import re
import math
import time
import urllib
import os.path
import httplib
import urlparse
import tempfile
import commands
import StringIO
import xml.etree.ElementTree
import PIL.Image
import PIL.ImageFilter
import matchup
import ModestMaps
import AWS

class CodeReadException(Exception):
    pass

class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class Marker:
    def __init__(self, basepath):
        data = open(basepath + '.sift', 'r')
        self.features = [matchup.row2feature(row) for row in data]

        point = open(basepath + '.txt', 'r')
        self.anchor = Point(*[int(c) for c in point.read().split()])

    def locateInFeatures(self, features):
        """
        """
        start = time.time()
        
        matches = matchup.find_matches(features, self.features)
        matches_graph = matchup.group_matches(matches, features, self.features)
        needles = matchup.find_needles(matches, matches_graph, features, self.features)
        
        print >> sys.stderr, 'Found', len(needles), 'needles',
        print >> sys.stderr, 'in %.2f sec.' % (time.time() - start)
        
        assert len(needles) == 1, 'Got %d needle matches instead of 1' % len(needles)
        fs1, fs2, transform = needles[0]
        
        print >> sys.stderr, (self.anchor.x, self.anchor.y),

        x, y = transform(self.anchor.x, self.anchor.y)
        print >> sys.stderr, '->', (x, y),

        self.anchor = Point(x, y)

def main(url, markers, apibase, message_id, bucket_id, aws_access, aws_secret, password):
    """
    """
    url_pat = re.compile(r'^http://([^\.]+).s3.amazonaws.com/scans/([^/]+)/(.*)$', re.I)
    
    if url_pat.match(url):
        scan_id = url_pat.sub(r'\2', url)

    else:
        print >> sys.stderr, url, "doesn't match expected form"
        return

    # shorthand
    updateStepLocal = lambda step_number, timeout: updateStep(apibase, password, scan_id, step_number, message_id, timeout)
    
    try:
        s3 = AWS.Storage.Service(aws_access, aws_secret)

        # sifting
        updateStepLocal(2, 60)
        
        image, features, scale = siftImage(url)
        
        # finding needles
        updateStepLocal(3, 30)
        
        for (name, marker) in markers.items():
            print >> sys.stderr, name, '...',
            marker.locateInFeatures(features)
    
            x, y = int(marker.anchor.x / scale), int(marker.anchor.y / scale)
            print >> sys.stderr, '->', (x, y)
    
            marker.anchor = Point(x, y)
        
        # reading QR code
        updateStepLocal(4, 10)
        
        qrcode = extractCode(image, markers)

        qrcode_name = 'scans/%(scan_id)s/qrcode.jpg' % locals()
        qrcode_bytes = StringIO.StringIO()
        qrcode_image = qrcode.copy()
        qrcode_image.save(qrcode_bytes, 'JPEG')
        qrcode_bytes = qrcode_bytes.getvalue()
        s3.putBucketObject(bucket_id, qrcode_name, qrcode_bytes, 'image/jpeg', 'public-read')
    
        print_id, north, west, south, east = readCode(qrcode)
        print 'code contents:', 'Print', print_id, (north, west, south, east)
        
        # tiling and uploading
        updateStepLocal(5, 180)

        gym = ModestMaps.OpenStreetMap.Provider()
        
        topleft = gym.locationCoordinate(ModestMaps.Geo.Location(north, west))
        bottomright = gym.locationCoordinate(ModestMaps.Geo.Location(south, east))
        
        print topleft, bottomright

        renders = {}
        
        # make a smallish preview image
        preview_name = 'scans/%(scan_id)s/preview.jpg' % locals()
        preview_bytes = StringIO.StringIO()
        preview_image = image.copy()
        preview_image.thumbnail((409, 280), PIL.Image.ANTIALIAS)
        preview_image.save(preview_bytes, 'JPEG')
        preview_bytes = preview_bytes.getvalue()
        s3.putBucketObject(bucket_id, preview_name, preview_bytes, 'image/jpeg', 'public-read')
        
        # make a largish image
        large_name = 'scans/%(scan_id)s/large.jpg' % locals()
        large_bytes = StringIO.StringIO()
        large_image = image.copy()
        large_image.thumbnail((900, 900), PIL.Image.ANTIALIAS)
        large_image.save(large_bytes, 'JPEG')
        large_bytes = large_bytes.getvalue()
        s3.putBucketObject(bucket_id, large_name, large_bytes, 'image/jpeg', 'public-read')
        
        min_zoom, max_zoom = 20, 0
        
        for zoom in range(20, 0, -1):
            localTopLeft = topleft.zoomTo(zoom)
            localBottomRight = bottomright.zoomTo(zoom)

            zoom_renders = tileZoomLevel(image, localTopLeft, localBottomRight, markers, renders)
            
            for (coord, tile_image) in zoom_renders:
                x, y, z = coord.column, coord.row, coord.zoom
                tile_name = 'scans/%(scan_id)s/%(z)d/%(x)d/%(y)d.jpg' % locals()
                
                tile_bytes = StringIO.StringIO()
                tile_image.save(tile_bytes, 'JPEG')
                tile_bytes = tile_bytes.getvalue()

                s3.putBucketObject(bucket_id, tile_name, tile_bytes, 'image/jpeg', 'public-read')
            
                renders[str(coord)] = tile_image
                
                min_zoom = min(coord.zoom, min_zoom)
                max_zoom = max(coord.zoom, max_zoom)
        
        print 'min:', topleft.zoomTo(min_zoom)
        print 'max:', bottomright.zoomTo(max_zoom)
        
        # finished!
        updateScan(apibase, password, scan_id, print_id, topleft.zoomTo(min_zoom), bottomright.zoomTo(max_zoom))
        updateStepLocal(6, None)

    except CodeReadException:
        print 'Failed QR code, maybe will try again?'
        updateStepLocal(98, 10)
    
    except KeyboardInterrupt:
        raise

    except:
        # an error
        updateStepLocal(99, 90)

        raise

    return 0

def updateStep(apibase, password, scan_id, step_number, message_id, timeout):
    """
    """
    s, host, path, p, q, f = urlparse.urlparse(apibase)
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    
    params = urllib.urlencode({'scan': scan_id, 'step': step_number, 'password': password})
    
    req = httplib.HTTPConnection(host, 80)
    req.request('POST', path + '/step.php', params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to step.php %s/%d resulting in status %s instead of 200' % (scan_id, step_number, res.status)
    
    # TODO: move this responsibility to step.php
    if step_number == 6 or res.read().strip() == 'Too many errors':
        # magic number for "finished"
        params = urllib.urlencode({'id': message_id, 'password': password, 'delete': 'yes'})

    else:
        params = urllib.urlencode({'id': message_id, 'password': password, 'timeout': timeout})
    
    req = httplib.HTTPConnection(host, 80)
    req.request('POST', path + '/dequeue.php', params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to dequeue.php resulting in status %s instead of 200' % res.status
    
    return

def updateScan(apibase, password, scan_id, print_id, min_coord, max_coord):
    """
    """
    s, host, path, p, q, f = urlparse.urlparse(apibase)
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    
    query = urllib.urlencode({'id': scan_id})
    params = urllib.urlencode({'print_id': print_id,
                               'password': password,
                               'min_row': min_coord.row, 'max_row': max_coord.row,
                               'min_column': min_coord.column, 'max_column': max_coord.column,
                               'min_zoom': min_coord.zoom, 'max_zoom': max_coord.zoom})
    
    req = httplib.HTTPConnection(host, 80)
    req.request('POST', path + '/scan.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to scan.php resulting in status %s instead of 200' % res.status

    return

def tileZoomLevel(image, topleft, bottomright, markers, renders):
    """ Generator of coord, tile tuples
    """
    assert topleft.zoom == bottomright.zoom, "Top-left and bottom-right zooms don't match up as they should: %s vs. %s" % (topleft.zoom, bottomright.zoom)
    
    zoom = topleft.zoom
    
    # transformation from coordinate space to pixel space
    
    top, left, bottom, right = topleft.row, topleft.column, bottomright.row, bottomright.column
    
    ax, bx, cx = linearSolution(left,    top, markers['Header'].anchor.x,
                                right,   top, markers['Hand'].anchor.x,
                                left, bottom, markers['CCBYSA'].anchor.x)
    
    ay, by, cy = linearSolution(left,    top, markers['Header'].anchor.y,
                                right,   top, markers['Hand'].anchor.y,
                                left, bottom, markers['CCBYSA'].anchor.y)

    magnification = math.hypot(ax, bx) / 256
    
    if .65 < magnification and magnification < 20:
    
        print >> sys.stderr, zoom,
        
        coordinatePixel = lambda x, y: (ax * x + bx * y + cx, ay * x + by * y + cy)
        
        for row in range(int(topleft.container().row), int(bottomright.container().row) + 1):
            for column in range(int(topleft.container().column), int(bottomright.container().column) + 1):
                coord = ModestMaps.Core.Coordinate(row, column, zoom)
                
                # the tile image itself
                tile_img = extractTile(image, coord, coordinatePixel, renders)
                yield (coord, tile_img)

                print >> sys.stderr, '.',

        print >> sys.stderr, ''

def extractTile(image, coord, coordinatePixel, renders):
    """
    """
    left, top = coordinatePixel(coord.column, coord.row)
    right, bottom = coordinatePixel(coord.right().column, coord.down().row)
    
    # transformation from tile image space to pixel space
    axt, bxt, cxt = linearSolution(0, 0, left, 512, 0, right, 0, 512, left)
    ayt, byt, cyt = linearSolution(0, 0, top, 512, 0, top, 0, 512, bottom)

    # pull the original pixels out
    tile_pixels = image.transform((512, 512), PIL.Image.AFFINE, (axt, bxt, cxt, ayt, byt, cyt), PIL.Image.BICUBIC)
    tile_img = PIL.Image.new('L', tile_pixels.size, 0xCC).convert('RGB')
    tile_img.paste(tile_pixels, (0, 0), tile_pixels)

    # interpolate in some of the previous renders; these may look better
    for (x, y, c) in ((0, 0, coord.zoomBy(1)), (256, 0, coord.zoomBy(1).right()), (0, 256, coord.zoomBy(1).down()), (256, 256, coord.zoomBy(1).down().right())):
        if renders.has_key(str(c)):
            tile_img.paste(renders[str(c)], (x, y))

    tile_img = tile_img.resize((256, 256), PIL.Image.ANTIALIAS)
    
    return tile_img

def siftImage(url):
    """
    """
    print >> sys.stderr, 'download...',
    
    bytes = StringIO.StringIO(urllib.urlopen(url).read())
    image = PIL.Image.open(bytes).convert('RGBA')
    
    print >> sys.stderr, image.size
    
    handle, sift_filename = tempfile.mkstemp(prefix='decode-', suffix='.sift')
    os.close(handle)
        
    handle, pgm_filename = tempfile.mkstemp(prefix='decode-', suffix='.pgm')
    os.close(handle)
    
    # fit to 1000x1000
    scale = min(1., 1000. / max(image.size))
    
    # write the PGM
    pgm_size = int(image.size[0] * scale), int(image.size[1] * scale)
    image.convert('L').resize(pgm_size, PIL.Image.ANTIALIAS).save(pgm_filename)
    
    print >> sys.stderr, 'sift...', pgm_size,
    
    basedir = os.path.dirname(os.path.realpath(__file__))
    status, output = commands.getstatusoutput("%(basedir)s/bin/sift --peak-thresh=8 -o '%(sift_filename)s' '%(pgm_filename)s'" % locals())
    data = open(sift_filename, 'r')
    
    assert status == 0, 'Sift execution returned %s instead of 0' % status
    
    features = [matchup.row2feature(row) for row in data]

    print >> sys.stderr, len(features), 'features'
    
    os.unlink(sift_filename)
    os.unlink(pgm_filename)
    
    return image, features, scale

def linearSolution(r1, s1, t1, r2, s2, t2, r3, s3, t3):
    """ Solves a system of linear equations.

          t1 = (a * r1) + (b + s1) + c
          t2 = (a * r2) + (b + s2) + c
          t3 = (a * r3) + (b + s3) + c

        r1 - t3 are the known values.
        a, b, c are the unknowns to be solved.
        returns the a, b, c coefficients.
    """

    # make them all floats
    r1, s1, t1, r2, s2, t2, r3, s3, t3 = map(float, (r1, s1, t1, r2, s2, t2, r3, s3, t3))

    a = (((t2 - t3) * (s1 - s2)) - ((t1 - t2) * (s2 - s3))) \
      / (((r2 - r3) * (s1 - s2)) - ((r1 - r2) * (s2 - s3)))

    b = (((t2 - t3) * (r1 - r2)) - ((t1 - t2) * (r2 - r3))) \
      / (((s2 - s3) * (r1 - r2)) - ((s1 - s2) * (r2 - r3)))

    c = t1 - (r1 * a) - (s1 * b)
    
    return a, b, c

def extractCode(image, markers):
    """
    """
    # transformation from ideal space to printed image space.
    # markers are positioned with Header at upper left, Hand at upper right, and CCBYSA at lower left
    
    ax, bx, cx = linearSolution(0,   0, markers['Header'].anchor.x,
                                540, 0, markers['Hand'].anchor.x,
                                0, 720, markers['CCBYSA'].anchor.x)
    
    ay, by, cy = linearSolution(0,   0, markers['Header'].anchor.y,
                                540, 0, markers['Hand'].anchor.y,
                                0, 720, markers['CCBYSA'].anchor.y)
    
    # candidate location of the QR code on the printed image:
    # top-left, top-right, bottom-left corner of QR code.
    corners = [Point(ax * x + bx * y + cx, ay * x + by * y + cy)
               for (x, y)
               in [(477, 657), (540, 657), (477, 720)]]

    # projection from extracted QR code image space to source image space
    
    ax, bx, cx = linearSolution(50,  50, corners[0].x,
                                450, 50, corners[1].x,
                                50, 450, corners[2].x)
    
    ay, by, cy = linearSolution(50,  50, corners[0].y,
                                450, 50, corners[1].y,
                                50, 450, corners[2].y)

    # extract the code part
    justcode = image.convert('RGBA').transform((500, 500), PIL.Image.AFFINE, (ax, bx, cx, ay, by, cy), PIL.Image.BICUBIC)
    
    # paste it to an output image
    qrcode = PIL.Image.new('RGB', justcode.size, (0xCC, 0xCC, 0xCC))
    qrcode.paste(justcode, (0, 0), justcode)
    
    # raise contrast
    lut = [0x00] * 112 + [0xFF] * 144 # [0x00] * 112 + range(0x00, 0xFF, 8) + [0xFF] * 112
    qrcode = qrcode.convert('L').filter(PIL.ImageFilter.BLUR).point(lut)
    
    return qrcode

def readCode(image):
    """
    """
    codebytes = StringIO.StringIO()
    image.save(codebytes, 'PNG')
    codebytes.seek(0)
    
    req = httplib.HTTPConnection('127.0.0.1', 9955)
    req.request('POST', '/decode', codebytes.read(), {'Content-Type': 'image/png'})
    res = req.getresponse()
    
    decoded = res.read()
    print decoded
    
    if res.status == 200 and decoded.startswith('http://'):
    
        html = xml.etree.ElementTree.parse(urllib.urlopen(decoded))
        
        print_id, north, west, south, east = None, None, None, None, None
        
        for span in html.findall('body/span'):
            if span.get('id') == 'print-info':
                for subspan in span.findall('span'):
                    if subspan.get('class') == 'print':
                        print_id = subspan.text
                    elif subspan.get('class') == 'north':
                        north = float(subspan.text)
                    elif subspan.get('class') == 'south':
                        south = float(subspan.text)
                    elif subspan.get('class') == 'east':
                        east = float(subspan.text)
                    elif subspan.get('class') == 'west':
                        west = float(subspan.text)
    
        return print_id, north, west, south, east

    else:
        #image.show()

        raise CodeReadException('Attempt to read QR code failed')

if __name__ == '__main__':
    url = sys.argv[1]
    markers = {}
    
    for basename in ('Header', 'Hand', 'CCBYSA'):
        basepath = os.path.dirname(os.path.realpath(__file__)) + '/corners/' + basename
        markers[basename] = Marker(basepath)
    
    sys.exit(main(url, markers))
