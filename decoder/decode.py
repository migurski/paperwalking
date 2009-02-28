import os
import sys
import re
import math
import time
import urllib
import os.path
import httplib
import tempfile
import commands
import StringIO
import PIL.Image
import PIL.ImageFilter
import matchup
import ModestMaps

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
        
        assert len(needles) == 1
        fs1, fs2, transform = needles[0]
        
        print >> sys.stderr, (self.anchor.x, self.anchor.y),

        x, y = transform(self.anchor.x, self.anchor.y)
        print >> sys.stderr, '->', (x, y),

        self.anchor = Point(x, y)

def main(url, markers, apibase):
    """
    """
    url_pat = re.compile(r'^http://([^\.]+).s3.amazonaws.com/([^/]+)/(.+)$', re.I)
    
    if url_pat.match(url):
        print url_pat.sub(r'\2', url)
        return
    
    image, features, scale = siftImage(url)
    
    for (name, marker) in markers.items():
        print >> sys.stderr, name, '...',
        marker.locateInFeatures(features)

        x, y = int(marker.anchor.x / scale), int(marker.anchor.y / scale)
        print >> sys.stderr, '->', (x, y)

        marker.anchor = Point(x, y)
    
    # scale = 3
    # width, height = 540 * scale, 720 * scale
    # 
    # # transformation from ideal space to printed image space.
    # # markers are positioned with Spout-2 at upper left, Spout-1 at upper right, and Reader at lower left
    # 
    # ax, bx, cx = linearSolution(0,      0, markers['Spout-2'].anchor.x,
    #                             width,  0, markers['Spout-1'].anchor.x,
    #                             0, height, markers['Reader'].anchor.x)
    # 
    # ay, by, cy = linearSolution(0,      0, markers['Spout-2'].anchor.y,
    #                             width,  0, markers['Spout-1'].anchor.y,
    #                             0, height, markers['Reader'].anchor.y)
    #
    # # extract the whole thing
    # normalized = image.transform((width, height), PIL.Image.AFFINE, (ax, bx, cx, ay, by, cy), PIL.Image.BICUBIC)
    # 
    # #normalized.show()
    
    qrcode = extractCode(image, markers)
    #qrcode.show()

    north, west, south, east = readCode(qrcode)
    print 'code contents:', (north, west, south, east)
    
    gym = ModestMaps.OpenStreetMap.Provider()
    
    topleft = gym.locationCoordinate(ModestMaps.Geo.Location(north, west))
    bottomright = gym.locationCoordinate(ModestMaps.Geo.Location(south, east))
    
    print topleft, bottomright
    
    renders = {}
    
    for zoom in range(20, 0, -1):
        localTopLeft = topleft.zoomTo(zoom)
        localBottomRight = bottomright.zoomTo(zoom)

        # transformation from coordinate space to pixel space
        
        top, left, bottom, right = localTopLeft.row, localTopLeft.column, localBottomRight.row, localBottomRight.column
        
        ax, bx, cx = linearSolution(left,    top, markers['Spout-2'].anchor.x,
                                    right,   top, markers['Spout-1'].anchor.x,
                                    left, bottom, markers['Reader'].anchor.x)
        
        ay, by, cy = linearSolution(left,    top, markers['Spout-2'].anchor.y,
                                    right,   top, markers['Spout-1'].anchor.y,
                                    left, bottom, markers['Reader'].anchor.y)

        magnification = math.hypot(ax, bx) / 256
        
        if .65 < magnification and magnification < 20:
        
            print zoom, (ax, bx, cx, ay, by, cy)
            
            coordinatePixel = lambda x, y: (ax * x + bx * y + cx, ay * x + by * y + cy)
            
            for row in range(int(localTopLeft.container().row), int(localBottomRight.container().row) + 1):
                for column in range(int(localTopLeft.container().column), int(localBottomRight.container().column) + 1):
                    coord = ModestMaps.Core.Coordinate(row, column, zoom)
                    
                    # the tile image itself
                    tile_name = 'out/%(zoom)d-r%(row)d-c%(column)d.jpg' % coord.__dict__
                    tile_img = extractTile(image, coord, coordinatePixel, renders)
                    tile_img.save(tile_name)
                    
                    # for future use
                    renders[str(coord)] = tile_img

    return 0

def extractTile(image, coord, coordinatePixel, renders):
    """
    """
    left, top = coordinatePixel(coord.column, coord.row)
    right, bottom = coordinatePixel(coord.right().column, coord.down().row)
    
    # transformation from tile image space to pixel space
    axt, bxt, cxt = linearSolution(0, 0, left, 512, 0, right, 0, 512, left)
    ayt, byt, cyt = linearSolution(0, 0, top, 512, 0, top, 0, 512, bottom)

    print coord, (int(left), int(top)), (int(right), int(bottom)), (axt, bxt, cxt, ayt, byt, cyt)
    
    tile_pixels = image.transform((512, 512), PIL.Image.AFFINE, (axt, bxt, cxt, ayt, byt, cyt), PIL.Image.BICUBIC)
    tile_img = PIL.Image.new('L', tile_pixels.size, 0xCC).convert('RGB')
    tile_img.paste(tile_pixels, (0, 0), tile_pixels)

    if renders.has_key(str(coord.zoomBy(1))):
        tile_img.paste(renders[str(coord.zoomBy(1))], (0, 0))

    if renders.has_key(str(coord.zoomBy(1).right())):
        tile_img.paste(renders[str(coord.zoomBy(1).right())], (256, 0))

    if renders.has_key(str(coord.zoomBy(1).down())):
        tile_img.paste(renders[str(coord.zoomBy(1).down())], (0, 256))

    if renders.has_key(str(coord.zoomBy(1).down().right())):
        tile_img.paste(renders[str(coord.zoomBy(1).down().right())], (256, 256))

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
    status, output = commands.getstatusoutput("%(basedir)s/vlfeat/bin/mac/sift --peak-thresh=8 -o '%(sift_filename)s' '%(pgm_filename)s'" % locals())
    data = open(sift_filename, 'r')
    
    assert status == 0
    
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
    # markers are positioned with Spout-2 at upper left, Spout-1 at upper right, and Reader at lower left
    
    ax, bx, cx = linearSolution(0,   0, markers['Spout-2'].anchor.x,
                                540, 0, markers['Spout-1'].anchor.x,
                                0, 720, markers['Reader'].anchor.x)
    
    ay, by, cy = linearSolution(0,   0, markers['Spout-2'].anchor.y,
                                540, 0, markers['Spout-1'].anchor.y,
                                0, 720, markers['Reader'].anchor.y)
    
    # candidate location of the QR code on the printed image:
    # top-left, top-right, bottom-left corner of QR code.
    corners = [Point(ax * x + bx * y + cx, ay * x + by * y + cy)
               for (x, y)
               in [(474, 654), (540, 654), (474, 720)]]

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
    
    # blur and raise contrast
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
    
    assert res.status == 200
    
    decoded = res.read()
    
    assert decoded.startswith('uri=')
    
    return [float(val) for val in decoded[4:].split()]

if __name__ == '__main__':
    url = sys.argv[1]
    markers = {}
    
    for basename in ('Reader', 'Spout-1', 'Spout-2'):
        basepath = os.path.dirname(os.path.realpath(__file__)) + '/Gargoyles/' + basename
        markers[basename] = Marker(basepath)
    
    sys.exit(main(url, markers))
