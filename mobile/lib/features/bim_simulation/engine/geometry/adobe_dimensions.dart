/// Engineering proportions — reinforced adobe structure (meters).
abstract final class AdobeDimensions {
  static const plotWidth = 12.0;
  static const plotDepth = 11.0;
  static const buildingWidth = 5.8;
  static const buildingDepth = 4.4;
  static const wallHeight = 2.8;
  static const brickLength = 0.3;
  static const brickHeight = 0.1;
  static const brickDepth = 0.2;
  static const mortarJoint = 0.012;
  static const trenchDepth = 0.55;
  static const pccThickness = 0.075;
  static const footingDepth = 0.35;
  static const footingWidth = 0.55;
  static const plinthBeamHeight = 0.25;
  static const bandHeight = 0.2;
  static const foundationCourses = 3;
  static const wallCourses = 10;
  static const dpcThickness = 0.02;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get wallBaseY =>
      -trenchDepth + pccThickness + footingDepth + plinthBeamHeight;
  static double get roofBaseY => wallBaseY + wallHeight + bandHeight;
}
