from numpy import matrix as _matrix, dot as _dot

class Point:
    """ Simplest point.
    """
    def __init__(self, x, y):
        self.x, self.y = x, y

    def __str__(self):
        return '(%.3f, %.3f)' % (self.x, self.y)

class Vector:
    """ Like a point, but built from difference between two points.
    """
    def __init__(self, p1, p2):
        self.x, self.y = p2.x - p1.x, p2.y - p1.y

class Transform:
    """ Callable linear transformation.
    
        | a b c |
        | d e f |
        
        or
        
        x = ax + by + c
        y = dx + ey + c
        
        or
        
        | a b c |
        | d e f |
        | 0 0 1 |
        
        or
        
        | a b c |
        | d e f |
        | g h i |
        
        Anyway.
    """
    def __init__(self, a, b, c, d, e, f, g=0, h=0, i=1):
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.f = f
        self.g = g
        self.h = h
        self.i = i
        
        self.matrix = _matrix([[a, b, c], [d, e, f], [g, h, i]], dtype=float)

    def __call__(self, pt):
        """
        """
        pt = _matrix([[pt.x], [pt.y], [1]])
        pt = _dot(self.matrix, pt)
        
        return Point(pt[0,0]/pt[2,0], pt[1,0]/pt[2,0])
    
    def __str__(self):
        return '[%.3f, %.3f, %.3f, %.3f, %.3f, %.3f]' % tuple(self.values)

    def affine(self, x, y, w, h):
        """
        """
        #
        # Solve for x
        #
        r1, s1, t1 = float(x),   float(y), self(Point(x,   y)).x
        r2, s2, t2 = float(x), float(h+y), self(Point(x, h+y)).x
        r3, s3, t3 = float(x+w), float(y), self(Point(x+w, y)).x

        a = (((t2 - t3) * (s1 - s2)) - ((t1 - t2) * (s2 - s3))) \
          / (((r2 - r3) * (s1 - s2)) - ((r1 - r2) * (s2 - s3)))
    
        b = (((t2 - t3) * (r1 - r2)) - ((t1 - t2) * (r2 - r3))) \
          / (((s2 - s3) * (r1 - r2)) - ((s1 - s2) * (r2 - r3)))
    
        c = t1 - (r1 * a) - (s1 * b)

        #
        # Solve for y
        #
        r1, s1, t1 = float(x),   float(y), self(Point(x,   y)).y
        r2, s2, t2 = float(x), float(h+y), self(Point(x, h+y)).y
        r3, s3, t3 = float(x+w), float(y), self(Point(x+w, y)).y
    
        d = (((t2 - t3) * (s1 - s2)) - ((t1 - t2) * (s2 - s3))) \
          / (((r2 - r3) * (s1 - s2)) - ((r1 - r2) * (s2 - s3)))
    
        e = (((t2 - t3) * (r1 - r2)) - ((t1 - t2) * (r2 - r3))) \
          / (((s2 - s3) * (r1 - r2)) - ((s1 - s2) * (r2 - r3)))
    
        f = t1 - (r1 * d) - (s1 * e)
        
        return a, b, c, d, e, f
    
    def multiply(self, other):
        """
        """
        return matrix2transform(_dot(other.matrix, self.matrix))

    def inverse(self):
        """
        """
        return matrix2transform(self.matrix.I)

def matrix2transform(m):
    """
    """
    a, b, c = m[0,0], m[0,1], m[0,2]
    d, e, f = m[1,0], m[1,1], m[1,2]
    g, h, i = m[2,0], m[2,1], m[2,2]
    
    return Transform(a, b, c, d, e, f, g, h, i)

def square2quad(p0, p1, p2, p3):
    """ Return a homogenous transform from points in a unit square to a quad.
    
        See line 265 of http://www.java2s.com/Open-Source/Java-Document/6.0-JDK-Modules/Java-Advanced-Imaging/javax/media/jai/PerspectiveTransform.java.htm
        
        Order of points must be clockwise:
          0. top-left (0, 0)
          1. top-right (0, 1)
          2. bottom-right (1, 1)
          3. bottom-left (1, 0)
    """
    x0, y0, x1, y1, x2, y2, x3, y3 = map(float, (p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y))
    
    dx3 = x0 - x1 + x2 - x3
    dy3 = y0 - y1 + y2 - y3
    
    m22 = 1.0
    
    if (dx3 == 0.0 and dy3 == 0.0):
        # to do: use tolerance
        m00 = x1 - x0
        m01 = x2 - x1
        m02 = x0
        m10 = y1 - y0
        m11 = y2 - y1
        m12 = y0
        m20 = 0.0
        m21 = 0.0
    else:
        dx1 = x1 - x2
        dy1 = y1 - y2
        dx2 = x3 - x2
        dy2 = y3 - y2
    
        invdet = 1.0 / (dx1 * dy2 - dx2 * dy1)
        m20 = (dx3 * dy2 - dx2 * dy3) * invdet
        m21 = (dx1 * dy3 - dx3 * dy1) * invdet
        m00 = x1 - x0 + m20 * x1
        m01 = x3 - x0 + m21 * x3
        m02 = x0
        m10 = y1 - y0 + m20 * y1
        m11 = y3 - y0 + m21 * y3
        m12 = y0

    return Transform(m00, m01, m02, m10, m11, m12, m20, m21, m22)

def quad2quad(l0, r0, l1, r1, l2, r2, l3, r3):
    """ Return a homogenous transformation from points in one quad to another.
        
        Order of points must be clockwise:
          0. top-left (0, 0)
          1. top-right (0, 1)
          2. bottom-right (1, 1)
          3. bottom-left (1, 0)
    """
    s2l = square2quad(l0, l1, l2, l3)
    s2r = square2quad(r0, r1, r2, r3)
    
    l2s = s2l.inverse()
    l2r = l2s.multiply(s2r)
    
    return l2r

if __name__ == '__main__':

    p = Transform(0, 0, 10, 0, 0, 10)(Point(0, 0))
    assert (p.x, p.y) == (10, 10)

    p = Transform(0, 0, 10, 0, 0, 10)(Point(10, 10))
    assert (p.x, p.y) == (10, 10)

    p = Transform(1, 0, 0, 0, 1, 0)(Point(0, 0))
    assert (p.x, p.y) == (0, 0)

    p = Transform(1, 0, 0, 0, 1, 0)(Point(10, 10))
    assert (p.x, p.y) == (10, 10)

    p = Transform(10, 0, 0, 0, 10, 0)(Point(0, 0))
    assert (p.x, p.y) == (0, 0)

    p = Transform(10, 0, 0, 0, 10, 0)(Point(10, 10))
    assert (p.x, p.y) == (100, 100)

    p = Transform(10, 0, 10, 0, 10, 10)(Point(0, 0))
    assert (p.x, p.y) == (10, 10)

    p = Transform(10, 0, 10, 0, 10, 10)(Point(10, 10))
    assert (p.x, p.y) == (110, 110)
    
    
    
    p = Point( 0,  0), Point(480, 0), Point(480, 480), Point( 0, 480)
    s = Point(66, 38), Point(328, 5), Point(476, 441), Point(89, 474)
    
    s2p = quad2quad(s[0], p[0], s[1], p[1], s[2], p[2], s[3], p[3])
    p2s = s2p.inverse()
    
    for i in range(4):
        assert round(p[i].x, 9) == round(s2p(s[i]).x, 9)
        assert round(p[i].y, 9) == round(s2p(s[i]).y, 9)

        assert round(s[i].x, 9) == round(p2s(p[i]).x, 9)
        assert round(s[i].y, 9) == round(p2s(p[i]).y, 9)
