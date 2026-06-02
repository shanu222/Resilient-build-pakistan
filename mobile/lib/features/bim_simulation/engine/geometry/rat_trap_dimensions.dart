/// Engineering proportions — Rat Trap Bond masonry (meters).
abstract final class RatTrapDimensions {
  static const plotWidth = 11.0;
  static const plotDepth = 12.0;
  static const buildingWidth = 6.0;
  static const buildingDepth = 4.5;
  static const wallHeight = 3.0;
  /// Brick length — also wall thickness in RTB.
  static const brickLength = 0.23;
  /// Course height when brick is on edge.
  static const courseHeight = 0.11;
  static const brickWidth = 0.11;
  static const cavityWidth = 0.12;
  static const mortarJoint = 0.01;
  static const trenchDepth = 0.6;
  static const pccThickness = 0.075;
  static const footingDepth = 0.35;
  static const footingWidth = 0.55;
  static const plinthBeamHeight = 0.25;
  static const bandHeight = 0.2;
  static const slabThickness = 0.125;
  static const foundationCourses = 3;
  static const wallCourses = 12;
  static const dpcThickness = 0.02;
  static const baySpacing = 0.72;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get wallBaseY =>
      -trenchDepth + pccThickness + footingDepth + plinthBeamHeight;
  static double get roofSlabY =>
      wallBaseY + wallHeight + bandHeight + slabThickness / 2;
  static int get baysAlongWidth => (buildingWidth / baySpacing).floor();
  static int get baysAlongDepth => (buildingDepth / baySpacing).floor();
}
