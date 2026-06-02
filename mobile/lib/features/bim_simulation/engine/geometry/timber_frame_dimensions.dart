/// Engineering proportions — timber frame with lath & plaster (meters).
abstract final class TimberFrameDimensions {
  static const plotWidth = 12.0;
  static const plotDepth = 11.0;
  static const buildingWidth = 5.6;
  static const buildingDepth = 4.3;
  static const columnSize = 0.12;
  static const beamWidth = 0.1;
  static const beamDepth = 0.14;
  static const wallHeight = 2.7;
  static const braceSize = 0.08;
  static const lathSpacing = 0.25;
  static const lathThickness = 0.025;
  static const plasterThickness = 0.02;
  static const trenchDepth = 0.5;
  static const pccThickness = 0.075;
  static const stoneCourseHeight = 0.2;
  static const stoneFoundationCourses = 3;
  static const plinthBeamHeight = 0.22;
  static const trussHeight = 0.9;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get wallBaseY =>
      -trenchDepth +
      pccThickness +
      stoneFoundationCourses * stoneCourseHeight +
      plinthBeamHeight;
  static double get wallPlateY => wallBaseY + wallHeight;
  static double get ridgeY => wallPlateY + trussHeight;
}
