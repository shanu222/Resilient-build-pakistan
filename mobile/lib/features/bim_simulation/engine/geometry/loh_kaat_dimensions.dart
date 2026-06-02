/// Engineering proportions — Loh-Kaat timber house (meters).
abstract final class LohKaatDimensions {
  static const plotWidth = 12.0;
  static const plotDepth = 11.0;
  static const buildingWidth = 5.5;
  static const buildingDepth = 4.5;
  static const wallHeight = 2.8;
  static const stoneCourseHeight = 0.22;
  static const stoneFoundationCourses = 4;
  static const masonryCourseHeight = 0.2;
  static const masonryCourses = 12;
  static const bandHeight = 0.12;
  static const bandDepth = 0.1;
  static const trenchDepth = 0.5;
  static const pccThickness = 0.06;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get foundationTopY =>
      -trenchDepth + pccThickness + stoneFoundationCourses * stoneCourseHeight;
  static double get wallBaseY => foundationTopY + bandHeight;
  static double get midBandY => wallBaseY + wallHeight * 0.45;
  static double get lintelBandY => wallBaseY + wallHeight - 0.35;
  static double get roofBaseY => wallBaseY + wallHeight + 0.1;
}
