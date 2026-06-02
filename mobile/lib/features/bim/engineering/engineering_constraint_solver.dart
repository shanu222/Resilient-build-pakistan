import 'dart:math' as math;

import '../engineering_constraint_engine.dart';
import '../../bim_simulation/engine/bim_entity.dart';
import '../../bim_simulation/engine/math/bim_vec3.dart';
import 'engineering_rule_library.dart';

/// Rule-based QC — export/render gate (Phase 19).
abstract final class EngineeringConstraintSolver {
  static ConstraintValidationResult validate(
    List<BimEntity> entities, {
    BuildingFootprint? footprint,
  }) {
    final base = EngineeringConstraintEngine.validate(
      entities,
      footprint: footprint,
    );
    final errors = List<String>.from(base.errors);
    final warnings = List<String>.from(base.warnings);
    final fp = footprint ?? EngineeringConstraintEngine.footprintFromEntities(entities);

    _checkGridAlignment(entities, warnings);
    _checkMemberOverlap(entities, errors);
    _checkWallContinuity(entities, fp, warnings);
    _checkRoofContinuity(entities, fp, errors, warnings);
    _checkBeamLevel(entities, warnings);
    _checkDisconnectedStructural(entities, warnings);

    return ConstraintValidationResult(
      passed: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  static void _checkGridAlignment(List<BimEntity> entities, List<String> warnings) {
    const g = EngineeringRuleLibrary.gridModuleM;
    for (final e in entities) {
      if (!_needsGridSnap(e)) continue;
      final c = e.bounds.center;
      for (final axis in [c.x, c.z]) {
        final rem = (axis / g) % 1;
        final off = rem > 0.5 ? 1 - rem : rem;
        if (off > 0.02 && off < 0.98) {
          warnings.add('${e.id}: minor grid offset (${EngineeringRuleLibrary.ruleSnapGrid})');
          return;
        }
      }
    }
  }

  static bool _needsGridSnap(BimEntity e) =>
      e.id.startsWith('blk_') ||
      e.id.startsWith('col_') ||
      e.id.startsWith('rcc_column') ||
      e.id.contains('pedestal');

  static void _checkMemberOverlap(List<BimEntity> entities, List<String> errors) {
    final structural = entities.where((e) {
      if (e.category == BimEntityCategory.grid ||
          e.category == BimEntityCategory.terrain) {
        return false;
      }
      return e.id.startsWith('blk_') ||
          e.id.contains('column') ||
          e.id.contains('beam');
    }).toList();

    for (var i = 0; i < structural.length; i++) {
      for (var j = i + 1; j < structural.length; j++) {
        final a = structural[i];
        final b = structural[j];
        if (_aabbOverlap(a.bounds.min, a.bounds.max, b.bounds.min, b.bounds.max, margin: 0.02)) {
          if (_isColumn(a) && _isColumn(b)) {
            errors.add('${a.id} overlaps ${b.id} (${EngineeringRuleLibrary.ruleNoColumnOverlap})');
          }
        }
      }
    }
  }

  static void _checkWallContinuity(
    List<BimEntity> entities,
    BuildingFootprint fp,
    List<String> warnings,
  ) {
    final walls = entities.where((e) => e.id.startsWith('blk_') || e.category == BimEntityCategory.masonry);
    if (walls.isEmpty) return;
    final lowest = walls.map((w) => w.bounds.min.y).reduce(math.min);
    if (lowest > fp.foundationContactY + EngineeringRuleLibrary.toleranceM * 3) {
      warnings.add('Wall base may not bear on foundation (${EngineeringRuleLibrary.ruleWallOnFoundation})');
    }
  }

  static void _checkRoofContinuity(
    List<BimEntity> entities,
    BuildingFootprint fp,
    List<String> errors,
    List<String> warnings,
  ) {
    final roofs = entities.where((e) => e.id.contains('roof') || e.id.contains('truss'));
    if (roofs.isEmpty) return;
    final roofMin = roofs.map((r) => r.bounds.min.y).reduce(math.min);
    if (roofMin < fp.wallTopY - EngineeringRuleLibrary.toleranceM * 6) {
      warnings.add('Roof may be disconnected from wall plate (${EngineeringRuleLibrary.ruleRoofLoadPath})');
    }
    final cx = roofs.map((r) => r.bounds.center.x).reduce((a, b) => a + b) / roofs.length;
    final cz = roofs.map((r) => r.bounds.center.z).reduce((a, b) => a + b) / roofs.length;
    final fpCx = (fp.minX + fp.maxX) / 2;
    final fpCz = (fp.minZ + fp.maxZ) / 2;
    if ((cx - fpCx).abs() > 2.5 || (cz - fpCz).abs() > 2.5) {
      warnings.add('Roof may not be centered on structure (${EngineeringRuleLibrary.ruleRoofCentered})');
    }
  }

  static void _checkBeamLevel(List<BimEntity> entities, List<String> warnings) {
    final beams = entities.where((e) => e.id.contains('beam') || e.id.contains('band'));
    if (beams.length < 2) return;
    final ys = beams.map((b) => b.bounds.center.y).toList();
    final spread = ys.reduce(math.max) - ys.reduce(math.min);
    if (spread > EngineeringRuleLibrary.toleranceM * 4) {
      warnings.add('Beams may not be level (${EngineeringRuleLibrary.ruleBeamsLevel})');
    }
  }

  static void _checkDisconnectedStructural(
    List<BimEntity> entities,
    List<String> warnings,
  ) {
    final cols = entities.where((e) => e.id.contains('column') || e.id.startsWith('col_')).length;
    final founds = entities.where((e) => e.id.contains('footing') || e.id.contains('found')).length;
    if (cols > 0 && founds == 0) {
      warnings.add('Structural columns without visible foundation (${EngineeringRuleLibrary.ruleNoDisconnected})');
    }
  }

  static bool _aabbOverlap(
    BimVec3 aMin,
    BimVec3 aMax,
    BimVec3 bMin,
    BimVec3 bMax, {
    required double margin,
  }) {
    return aMin.x < bMax.x - margin &&
        aMax.x > bMin.x + margin &&
        aMin.y < bMax.y - margin &&
        aMax.y > bMin.y + margin &&
        aMin.z < bMax.z - margin &&
        aMax.z > bMin.z + margin;
  }

  static bool _isColumn(BimEntity e) =>
      e.id.contains('column') || e.id.startsWith('col_');
}
