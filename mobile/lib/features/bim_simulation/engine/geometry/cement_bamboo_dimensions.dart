/// Engineering proportions — cement bamboo frame house (meters).
abstract final class CementBambooDimensions {
  static const plotWidth = 11.0;
  static const plotDepth = 13.0;
  static const buildingWidth = 6.0;
  static const buildingDepth = 5.0;
  static const wallHeight = 2.8;
  static const columnHeight = 2.8;
  static const columnSize = 0.12;
  static const beamDepth = 0.1;
  static const beamWidth = 0.14;
  static const gridSpacingX = 2.0;
  static const gridSpacingZ = 2.5;
  static const trenchDepth = 0.55;
  static const pccThickness = 0.075;
  static const footingDepth = 0.28;
  static const foundationBeamHeight = 0.25;
  static const plasterThickness = 0.025;
  static const meshOffset = 0.02;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
}
