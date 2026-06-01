/// Engineering proportions — geogrid reinforced retaining wall (meters).
abstract final class GeogridDimensions {
  static const plotWidth = 16.0;
  static const plotDepth = 10.0;
  static const wallFaceX = 10.2;
  static const wallHeight = 6.0;
  static const courseHeight = 0.6;
  static const courseCount = 10;
  static const blockDepth = 0.5;
  static const blockThickness = 0.45;
  static const geogridLength = 7.8;
  static const geogridThickness = 0.025;
  static const backfillLift = 0.52;
  static const roadWidth = 4.0;
  static const roadY = 7.2;
  static const benchDepth = 6.0;

  static double get centerX => wallFaceX / 2;
  static double get centerZ => plotDepth / 2;
}
