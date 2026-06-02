import 'dart:math' as math;

/// Engineering proportions — single-storey interlocking brick house (meters).
abstract final class HouseDimensions {
  // Plot & building footprint
  static const plotWidth = 12.0;
  static const plotDepth = 14.0;
  static const buildingWidth = 6.0;
  static const buildingDepth = 8.0;

  // Structural
  static const wallHeight = 3.0;
  static const wallThickness = 0.23;
  static const plinthHeight = 0.45;
  static const bandHeight = 0.15;
  static const dpcThickness = 0.004;

  // Foundation
  static const trenchDepth = 1.0;
  static const trenchWidth = 0.65;
  static const pccThickness = 0.075;
  static const footingWidth = 0.6;
  static const footingDepth = 0.3;
  static const plinthBeam = 0.23;
  static const foundationCourses = 2;

  // Interlocking block (390 × 190 × 230 mm typical)
  static const blockLength = 0.39;
  static const blockHeight = 0.19;
  static const blockWidth = 0.23;

  // Roof
  static const roofSlopeDegrees = 15.0;
  static const roofSlopeRadians = roofSlopeDegrees * math.pi / 180;
  static const purlinSpacing = 0.9;
  static const trussSpacing = 2.0;
  static const sheetThickness = 0.001;

  // Reinforcement
  static const rebarRadius = 0.006;
  static const verticalBarDiameter = 0.012;
  static const barDevelopmentLength = 0.48;

  // Grid — 1 m layout lines; 100 mm snap for block placement
  static const gridModule = 1.0;
  static const engineeringGrid = 0.1;

  static const originX = 0.0;
  static const originZ = 0.0;

  static double get centerX => buildingWidth / 2;
  static double get centerZ => buildingDepth / 2;

  /// Top of plinth beam / DPC — wall masonry base (m above ground).
  static double get wallBaseY => plinthHeight;

  /// Top of wall masonry (before bands).
  static double get wallTopY => wallBaseY + wallHeight;

  /// Lintel band elevation (opening head level).
  static double get lintelBandY => wallBaseY + 2.1;

  /// Roof band elevation (top of wall).
  static double get roofBandY => wallTopY;

  /// Eave line after roof band.
  static double get eaveY => roofBandY + bandHeight;

  /// Ridge height for gable roof (15° slope over half-depth).
  static double get ridgeY =>
      eaveY + (buildingDepth / 2) * math.tan(roofSlopeRadians);

  /// Foundation trench bottom elevation.
  static double get trenchBottomY => -trenchDepth;

  /// PCC top elevation inside trench.
  static double get pccTopY => trenchBottomY + pccThickness;

  /// Footing top elevation.
  static double get footingTopY => pccTopY + footingDepth;

  /// Foundation masonry top (before plinth beam).
  static double get foundationWallTopY =>
      footingTopY + foundationCourses * blockHeight;

  /// Plinth beam center elevation.
  static double get plinthBeamCenterY =>
      foundationWallTopY + plinthBeam / 2;

  /// DPC layer elevation.
  static double get dpcY => foundationWallTopY + plinthBeam;
}
