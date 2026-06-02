/// Engineering proportions — elevated flood-resilient house (meters).
abstract final class ElevatedFloodDimensions {
  static const plotWidth = 14.0;
  static const plotDepth = 11.0;
  static const buildingWidth = 5.0;
  static const buildingDepth = 4.0;
  static const columnSize = 0.3;
  static const columnHeight = 2.5;
  static const platformBeamHeight = 0.35;
  static const platformBeamWidth = 0.25;
  static const slabThickness = 0.15;
  static const wallHeight = 2.6;
  static const wallPanelThickness = 0.08;
  static const trenchDepth = 0.55;
  static const footingDepth = 0.4;
  static const footingWidth = 0.65;
  static const pedestalHeight = 0.15;
  static const designFloodLevel = 1.75;
  static const highFloodMark = 2.15;
  static const platformElevation = columnHeight;
  static const riverWidth = 3.5;
  static const rebarRadius = 0.006;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get platformTopY =>
      columnHeight + platformBeamHeight + slabThickness;
  static double get roofBaseY => platformTopY + wallHeight;
}
