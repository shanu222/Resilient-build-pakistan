/// Global engineering rules for resilient housing BIM (100 mm grid minimum).
abstract final class EngineeringRuleLibrary {
  static const gridModuleM = 0.1;
  static const toleranceM = 0.08;
  static const columnVerticalityTolerance = 0.02;
  static const minFoundationBeyondWallM = 0.05;

  // Foundation
  static const ruleFoundationBearsColumns = 'foundation.columns_bear';
  static const ruleNoUnsupportedColumns = 'foundation.no_float';
  static const ruleFootingCenteredOnLoad = 'foundation.footing_centered';
  static const ruleFoundationWiderThanWall = 'foundation.width_exceeds_wall';

  // Column
  static const ruleColumnVertical = 'column.vertical';
  static const ruleColumnAlignsFooting = 'column.align_footing';
  static const ruleNoColumnOverlap = 'column.no_overlap';
  static const ruleNoFloatingColumns = 'column.no_float';

  // Wall
  static const ruleWallOnFoundation = 'wall.on_foundation';
  static const ruleWallBelowRoof = 'wall.below_roof';
  static const ruleOpeningsOnGrid = 'opening.grid_align';
  static const ruleWallsConnectCorners = 'wall.corner_connect';

  // Beam
  static const ruleBeamsConnectColumns = 'beam.connect_columns';
  static const ruleBeamsLevel = 'beam.level';
  static const ruleBeamEndsOnSupport = 'beam.on_support';

  // Roof
  static const ruleRoofCentered = 'roof.centered';
  static const ruleRoofEqualProjection = 'roof.projection';
  static const ruleRoofLoadPath = 'roof.load_transfer';

  // Connection
  static const ruleSupportPath = 'connection.support_path';
  static const ruleNoDisconnected = 'connection.continuous';
  static const ruleNoIsolated = 'connection.no_isolate';

  // Grid
  static const ruleSnapGrid = 'grid.snap';
  static const ruleSymmetry = 'grid.symmetry';

  /// Snap scalar to engineering grid (100 mm default).
  static double snap(double value, {double grid = gridModuleM}) {
    if (grid <= 0) return value;
    return (value / grid).round() * grid;
  }

  static double snapFloor(double value, {double grid = gridModuleM}) {
    if (grid <= 0) return value;
    return (value / grid).floor() * grid;
  }

  static double snapCeil(double value, {double grid = gridModuleM}) {
    if (grid <= 0) return value;
    return (value / grid).ceil() * grid;
  }
}
