from imagemath import Point
from featuremath import Feature

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

#
# basic conversions between millimeters, points, and inches
#
mmppt = 0.352777778
inppt = 0.013888889

ptpin = 1./inppt
ptpmm = 1./mmppt

#
# paper sizes in printed points
#
paper_size_landscape_a3 = 420 * ptpmm, 297 * ptpmm
paper_size_landscape_a4 = 297 * ptpmm, 210 * ptpmm
paper_size_landscape_ltr = 11 * ptpin, 8.5 * ptpin

paper_size_portrait_a3 = 297 * ptpmm, 420 * ptpmm
paper_size_portrait_a4 = 210 * ptpmm, 297 * ptpmm
paper_size_portrait_ltr = 8.5 * ptpin, 11 * ptpin

#
# preview map sizes
#
preview_size_landscape_a3 = 480, 314.932
preview_size_landscape_a4 = 480, 303.800
preview_size_landscape_ltr = 480, 360 - 24

preview_size_portrait_a3 = 360, 506.200
preview_size_portrait_a4 = 360, 504.897
preview_size_portrait_ltr = 360, 480 - 24
