import 'dart:math' as math;

/// Engineering proportions — advanced interlocking hollow block house (meters).
abstract final class AdvancedInterlockingDimensions {
  static const plotWidth = 14.0;
  static const plotDepth = 12.0;
  static const buildingWidth = 8.0;
  static const buildingDepth = 6.0;
  static const wallHeight = 3.0;
  static const wallThickness = 0.23;
  static const plinthHeight = 0.45;
  static const trenchDepth = 1.0;
  static const trenchWidth = 0.65;
  static const pccThickness = 0.075;
  static const footingWidth = 0.6;
  static const footingDepth = 0.3;
  static const plinthBeam = 0.23;
  static const blockLength = 0.39;
  static const blockHeight = 0.19;
  static const blockWidth = 0.23;
  static const coreDiameter = 0.08;
  static const bandHeight = 0.15;
  static const rebarRadius = 0.006;
  static const dpcThickness = 0.004;
  static const foundationCourses = 2;
  static const roofSlopeDegrees = 15.0;
  static const roofSlopeRadians = roofSlopeDegrees * math.pi / 180;
  static const trussSpacing = 2.0;
  static const purlinSpacing = 0.9;
  static const gridModule = 1.0;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get wallBaseY => plinthHeight;
  static double get wallTopY => wallBaseY + wallHeight;
  static double get lintelBandY => wallBaseY + 2.1;
  static double get roofBandY => wallTopY;
  static double get eaveY => roofBandY + bandHeight;
  static double get ridgeY => eaveY + (buildingDepth / 2) * math.tan(roofSlopeRadians);
  static double get trenchBottomY => -trenchDepth;
  static double get pccTopY => trenchBottomY + pccThickness;
  static double get footingTopY => pccTopY + footingDepth;
  static double get foundationWallTopY => footingTopY + foundationCourses * blockHeight;
}
