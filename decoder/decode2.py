from sys import argv, stderr
from StringIO import StringIO
from subprocess import Popen, PIPE
from os.path import dirname, join as pathjoin
from xml.etree import ElementTree
from urllib import urlopen
from glob import glob

from PIL import Image
from PIL.ImageDraw import ImageDraw

from featuremath import Feature, MatchedFeature, blobs2features, stream_triples, stream_pairs
from imagemath import Point, imgblobs, extract_image
from matrixmath import Transform, quad2quad

#
# points, clockwise from top-left
#
point_A = Point(-508.37, -720.33)
point_B = Point(-13.56, -720.37)
point_C = Point(-13.56, -229.53)
point_D = Point(-149.12, -13.56)

#
# fifth point, by paper size and orientation
#
point_E_portrait_a3 = Point(-508.37, -126.63)
point_E_portrait_a4 = Point(-509.72, -199.48)
point_E_portrait_ltr = Point(-565.82, -271.11)
point_E_landscape_a3 = Point(-1105.00, -213.19)
point_E_landscape_a4 = Point(-1146.04, -300.08)
point_E_landscape_ltr = Point(-1034.82, -155.33)

#
# primary feature triangles
#
feature_acb = Feature(point_A, point_C, point_B)
feature_adc = Feature(point_A, point_D, point_C)
feature_dab = Feature(point_D, point_A, point_B)

#
# secondary feature triangles
#
feature_e_portrait_a3 = Feature(point_A, point_C, point_E_portrait_a3)
feature_e_portrait_a4 = Feature(point_A, point_C, point_E_portrait_a4)
feature_e_portrait_ltr = Feature(point_A, point_C, point_E_portrait_ltr)
feature_e_landscape_a3 = Feature(point_A, point_C, point_E_landscape_a3)
feature_e_landscape_a4 = Feature(point_A, point_C, point_E_landscape_a4)
feature_e_landscape_ltr = Feature(point_A, point_C, point_E_landscape_ltr)

#
# feature tolerances and minimum size for featuremath.blobs2features()
#
ratio_tol = 0.03
theta_tol = 0.04 # approx 2 degrees, either direction
min_size = 800

#
# Ratios of homogenous print coordinates above to printed point coordinates
#
ratio_portrait_a3 = 0.677938
ratio_portrait_a4 = 1.000007
ratio_portrait_ltr = 1.0729091
ratio_landscape_a3 = 0.999974
ratio_landscape_a4 = 1.506211
ratio_landscape_ltr = 1.456091

def blob_match(blobs):
    """
    """
    for (acb_match, adc_match) in _blob_matches_primary(blobs):
        for (e_match, point_E) in _blob_matches_secondary(blobs, acb_match, adc_match):
            #
            # determing paper size and orientation based on identity of point E.
            #
            if point_E is point_E_portrait_a3:
                orientation, paper_size, scale = 'portrait', 'a3', 1/ratio_portrait_a3

            elif point_E is point_E_portrait_a4:
                orientation, paper_size, scale = 'portrait', 'a4', 1/ratio_portrait_a4

            elif point_E is point_E_portrait_ltr:
                orientation, paper_size, scale = 'portrait', 'letter', 1/ratio_portrait_ltr

            elif point_E is point_E_landscape_a3:
                orientation, paper_size, scale = 'landscape', 'a3', 1/ratio_landscape_a3

            elif point_E is point_E_landscape_a4:
                orientation, paper_size, scale = 'landscape', 'a4', 1/ratio_landscape_a4

            elif point_E is point_E_landscape_ltr:
                orientation, paper_size, scale = 'landscape', 'letter', 1/ratio_landscape_ltr
            
            else:
                raise Exception('How did we ever get here?')
            
            #
            # find the scan location of point E
            #
            (scan_E, ) = [getattr(e_match, 's%d' % i)
                          for i in (1, 2, 3)
                          if getattr(e_match, 'p%d' % i) is point_E]
        
            #
            # transform from scan pixels to homogenous print coordinates - A, B, D, E
            #
            s2h = quad2quad(acb_match.s1, acb_match.p1, acb_match.s3, acb_match.p3,
                            adc_match.s2, adc_match.p2, scan_E, point_E)
            
            #
            # transform from scan pixels to printed points, with (0, 0) at lower right
            #
            h2p = Transform(scale, 0, 0, 0, scale, 0)
            s2p = s2h.multiply(h2p)
            
            return s2p, orientation, paper_size

def _blob_matches_primary(blobs):
    """ Generate known matches for ACB (top) and ADC (bottom) triangle pairs.
    """
    acb_theta, acb_ratio = feature_acb.theta, feature_acb.ratio
    adc_theta, adc_ratio = feature_adc.theta, feature_adc.ratio
    dab_theta, dab_ratio = feature_dab.theta, feature_dab.ratio
    
    acb_matches = blobs2features(blobs, min_size, acb_theta-theta_tol, acb_theta+theta_tol, acb_ratio-ratio_tol, acb_ratio+ratio_tol)
    adc_matches = blobs2features(blobs, min_size, adc_theta-theta_tol, adc_theta+theta_tol, adc_ratio-ratio_tol, adc_ratio+ratio_tol)
    dab_matches = blobs2features(blobs, min_size, dab_theta-theta_tol, dab_theta+theta_tol, dab_ratio-ratio_tol, dab_ratio+ratio_tol)
    
    seen_groups, max_skipped, skipped_groups = set(), 100, 0
    
    for (acb_tuple, adc_tuple, dab_tuple) in stream_triples(acb_matches, adc_matches, dab_matches):
        
        i0, j0, k0 = acb_tuple[0:3]
        i1, j1, k1 = adc_tuple[0:3]
        i2, j2, k2 = dab_tuple[0:3]
        
        group = (i0, j0, k0, i1, j1, k1, i2, j2, k2)
        
        if skipped_groups > max_skipped:
            return

        elif group in seen_groups:
            skipped_groups += 1
            #print >> stderr, 'skip:', group
            continue
        
        else:
            seen_groups.add(group)
            skipped_groups = 0
    
            acb_match = MatchedFeature(feature_acb, blobs[i0], blobs[j0], blobs[k0])
            adc_match = MatchedFeature(feature_adc, blobs[i1], blobs[j1], blobs[k1])
            dab_match = MatchedFeature(feature_dab, blobs[i2], blobs[j2], blobs[k2])
            
            if acb_match.fits(adc_match) and adc_match.fits(dab_match):
                #print >> stderr, 'yes:', group
                yield acb_match, adc_match
            
            else:
                #print >> stderr, 'no:', group
                pass

def _blob_matches_secondary(blobs, acb_match, adc_match):
    """ Generate known matches for ACB (top), ADC (bottom) and paper-specific triangle groups.
    """
    features_e = (
        (feature_e_landscape_ltr, point_E_landscape_ltr),
        (feature_e_portrait_ltr,  point_E_portrait_ltr),
        (feature_e_landscape_a4,  point_E_landscape_a4),
        (feature_e_portrait_a4,   point_E_portrait_a4),
        (feature_e_landscape_a3,  point_E_landscape_a3),
        (feature_e_portrait_a3,   point_E_portrait_a3)
      )

    for (feature_e, point_E) in features_e:
        e_theta, e_ratio = feature_e.theta, feature_e.ratio
        e_matches = blobs2features(blobs, min_size, e_theta-theta_tol, e_theta+theta_tol, e_ratio-ratio_tol, e_ratio+ratio_tol)
        
        for e_tuple in e_matches:
            i, j, k = e_tuple[0:3]
            e_match = MatchedFeature(feature_e, blobs[i], blobs[j], blobs[k])
        
            if e_match.fits(acb_match) and e_match.fits(adc_match):
                #
                # Based on the identity of point_E, we can find paper size and orientation.
                #
                yield e_match, point_E

def read_code(image):
    """
    """
    decode = 'java', '-classpath', ':'.join(glob(pathjoin(dirname(__file__), 'lib/*.jar'))), 'qrdecode'
    decode = Popen(decode, stdin=PIPE, stdout=PIPE)
    
    image.save(decode.stdin, 'PNG')
    decode.stdin.close()
    decode.wait()
    
    decoded = decode.stdout.read().strip()
    
    return decoded
    
    if decoded.startswith('http://'):
    
        html = ElementTree.parse(urlopen(decoded))
        
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
        raise CodeReadException('Attempt to read QR code failed')

def main(url):
    """
    """
    input = Image.open(StringIO(urlopen(url).read()))
    blobs = imgblobs(input, 'highpass.jpg', 'preblobs.jpg')

    s2p, paper, orientation = blob_match(blobs)

    print paper, orientation, '--', s2p
    
    qrcode = extract_image(s2p, (-90-9, -90-9, 0+9, 0+9), input, (500, 500))
    qrcode.save('qrcode.png')
    
    print read_code(qrcode)

    draw = ImageDraw(input)
    
    for blob in blobs:
        draw.rectangle(blob.bbox, outline=(0xFF, 0, 0))

    print 'saving...'
    input.save('out.png')

    return 0

if __name__ == '__main__':

    url = argv[1]
    
    exit(main(url))
