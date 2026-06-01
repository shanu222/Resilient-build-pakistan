/// Engineering proportions — light gauge steel house (meters).
abstract final class LightGaugeDimensions {
  static const plotWidth = 11.0;
  static const plotDepth = 12.0;
  static const buildingWidth = 6.0;
  static const buildingDepth = 4.5;
  static const wallHeight = 2.8;
  static const studSpacing = 0.6;
  static const studWeb = 0.09;
  static const studFlange = 0.05;
  static const trackHeight = 0.05;
  static const trenchDepth = 0.55;
  static const pccThickness = 0.075;
  static const footingDepth = 0.35;
  static const footingWidth = 0.5;
  static const roofPitch = 0.35;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
  static double get frameBaseY =>
      -trenchDepth + pccThickness + footingDepth + trackHeight;
  static double get roofEaveY => frameBaseY + wallHeight;
}
