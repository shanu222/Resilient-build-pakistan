/// Engineering proportions — fly ash masonry (meters).
abstract final class FlyAshDimensions {
  static const plotWidth = 11.0;
  static const plotDepth = 12.0;
  static const buildingWidth = 6.0;
  static const buildingDepth = 4.5;
  static const wallHeight = 3.0;
  static const brickLength = 0.23;
  static const brickHeight = 0.075;
  static const brickDepth = 0.11;
  static const mortarJoint = 0.01;
  static const trenchDepth = 0.6;
  static const pccThickness = 0.075;
  static const footingDepth = 0.35;
  static const footingWidth = 0.55;
  static const plinthBeamHeight = 0.25;
  static const bandHeight = 0.2;
  static const slabThickness = 0.125;
  static const foundationCourses = 3;
  static const wallCourses = 16;
  static const dpcThickness = 0.02;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get wallBaseY =>
      -trenchDepth + pccThickness + footingDepth + plinthBeamHeight;
  static double get roofSlabY => wallBaseY + wallHeight + bandHeight + slabThickness / 2;
}
