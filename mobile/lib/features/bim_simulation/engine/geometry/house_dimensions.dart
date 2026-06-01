/// Engineering proportions — single-storey interlocking brick house (meters).
abstract final class HouseDimensions {
  static const plotWidth = 10.0;
  static const plotDepth = 12.0;
  static const buildingWidth = 6.0;
  static const buildingDepth = 4.0;
  static const wallHeight = 3.0;
  static const trenchDepth = 1.0;
  static const trenchWidth = 0.65;
  static const pccThickness = 0.075;
  static const footingWidth = 0.6;
  static const footingDepth = 0.3;
  static const plinthBeam = 0.23;
  static const blockLength = 0.39;
  static const blockHeight = 0.19;
  static const blockWidth = 0.19;
  static const slabThickness = 0.125;
  static const bandHeight = 0.15;
  static const rebarRadius = 0.006;
  static const wallThickness = 0.23;

  static const originX = 0.0;
  static const originZ = 0.0;
  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
}
