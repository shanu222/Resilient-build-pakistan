/// Engineering proportions — raised plinth flood-resilient house (meters).
abstract final class RaisedPlinthDimensions {
  static const plotWidth = 13.0;
  static const plotDepth = 11.0;
  static const buildingWidth = 5.5;
  static const buildingDepth = 4.2;
  static const riverWidth = 3.0;
  static const trenchDepth = 0.5;
  static const pccThickness = 0.075;
  static const footingDepth = 0.35;
  static const footingWidth = 0.6;
  static const foundationMasonryHeight = 0.35;
  static const plinthFillHeight = 1.25;
  static const plinthBeamHeight = 0.28;
  static const plinthBeamWidth = 0.23;
  static const dpcThickness = 0.02;
  static const courseHeight = 0.2;
  static const wallHeight = 2.5;
  static const wallThickness = 0.23;
  static const designFloodLevel = 1.05;
  static const highFloodMark = 1.35;
  static const blockLength = 0.4;
  static const blockDepth = 0.2;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;

  static double get foundationTopY =>
      -trenchDepth + pccThickness + footingDepth + foundationMasonryHeight;

  static double get plinthTopY =>
      foundationTopY + plinthFillHeight + plinthBeamHeight;

  static double get floorLevelY => plinthTopY + dpcThickness;

  static double get roofBaseY => floorLevelY + wallHeight;
}
