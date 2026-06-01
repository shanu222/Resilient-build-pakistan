/// Engineering proportions — floating amphibious structure (meters).
abstract final class AmphibiousDimensions {
  static const plotWidth = 14.0;
  static const plotDepth = 11.0;
  static const buildingWidth = 5.0;
  static const buildingDepth = 4.0;
  static const siteOffsetX = 1.5;
  static const padSize = 0.55;
  static const padDepth = 0.35;
  static const trenchDepth = 0.45;
  static const guidePostSize = 0.1;
  static const guidePostHeight = 3.4;
  static const platformThickness = 0.16;
  static const deckY = 0.5;
  static const drumRadius = 0.26;
  static const drumHeight = 0.52;
  static const frameColumnHeight = 2.4;
  static const wallHeight = 2.5;
  static const wallThickness = 0.07;
  static const designFloodLevel = 1.65;
  static const highFloodMark = 2.0;
  static const maxFloatRise = 1.35;
  static const riverWidth = 3.2;

  static double get centerX => siteOffsetX + buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get roofBaseY => deckY + platformThickness + frameColumnHeight + 0.05;
}
