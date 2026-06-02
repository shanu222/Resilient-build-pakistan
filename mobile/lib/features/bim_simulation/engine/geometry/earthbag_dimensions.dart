/// Engineering proportions — single-storey earthbag house (meters).
abstract final class EarthbagDimensions {
  static const plotWidth = 12.0;
  static const plotDepth = 14.0;
  static const buildingWidth = 5.5;
  static const buildingDepth = 4.5;
  static const wallHeight = 2.8;
  static const bagLength = 0.45;
  static const bagHeight = 0.28;
  static const bagDepth = 0.32;
  static const wallThickness = 0.45;
  static const trenchDepth = 0.55;
  static const trenchWidth = 0.7;
  static const gravelThickness = 0.12;
  static const rubbleDepth = 0.35;
  static const bandHeight = 0.18;
  static const plinthBandHeight = 0.2;
  static const rebarRadius = 0.006;
  static const buttressWidth = 0.9;
  static const courses = 10;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
}
