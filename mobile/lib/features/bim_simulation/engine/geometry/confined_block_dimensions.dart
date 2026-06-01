/// Engineering proportions — confined concrete block masonry (meters).
abstract final class ConfinedBlockDimensions {
  static const plotWidth = 11.0;
  static const plotDepth = 12.0;
  static const buildingWidth = 6.0;
  static const buildingDepth = 4.5;
  static const wallHeight = 3.0;
  static const blockLength = 0.39;
  static const blockHeight = 0.19;
  static const blockDepth = 0.19;
  static const tieColumnSize = 0.23;
  static const trenchDepth = 0.6;
  static const pccThickness = 0.075;
  static const footingDepth = 0.35;
  static const footingWidth = 0.55;
  static const plinthBeamHeight = 0.25;
  static const bandHeight = 0.2;
  static const slabThickness = 0.125;
  static const courses = 15;
  static const rebarRadius = 0.006;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;
}
