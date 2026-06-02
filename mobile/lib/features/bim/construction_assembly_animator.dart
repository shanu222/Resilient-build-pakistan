import 'dart:math' as math;

import '../bim_simulation/engine/bim_entity.dart';
import '../bim_simulation/engine/math/bim_vec3.dart';

/// Staging zones and delivery paths for real assembly animation.
///
/// Sequence: appear → travel → rotate → align → lower → snap → lock
abstract final class ConstructionAssemblyAnimator {
  static const stagingDistance = 5.0;

  /// Opacity multiplier during placement (0 = invisible at staging, 1 = fully visible).
  static double assemblyOpacity(BimEntity e, double buildProgress) {
    if (buildProgress >= 1.0) return 1.0;
    if (buildProgress <= 0) return 0.0;
    final p = buildProgress.clamp(0.0, 1.0);
    // Phase 0 — appear (0–8%)
    if (p <= 0.08) return _easeOutCubic(p / 0.08);
    return 1.0;
  }

  /// Offset from final position while component is being placed (buildProgress 0→1).
  static BimVec3 assemblyOffset(BimEntity e, double buildProgress) {
    if (buildProgress >= 1.0) return BimVec3.zero;
    if (buildProgress <= 0) return _fullStagingOffset(e);

    final staging = _fullStagingOffset(e);
    final p = buildProgress.clamp(0.0, 1.0);

    // Phase 0 — appear at staging yard (0–8%): hold full offset
    if (p <= 0.08) return staging;

    // Phase 1 — travel from staging yard (8–35%)
    if (p <= 0.35) {
      final t = _easeOutCubic((p - 0.08) / 0.27);
      return staging * (1 - t * 0.85);
    }

    // Phase 2 — rotate + align horizontally above slot (35–55%)
    if (p <= 0.55) {
      final t = _easeInOutCubic((p - 0.35) / 0.2);
      final hover = staging * 0.15;
      final lift = _verticalApproach(e);
      return BimVec3(
        hover.x * (1 - t),
        hover.y + lift * (1 - t * 0.4),
        hover.z * (1 - t),
      );
    }

    // Phase 3 — lower into place (55–82%)
    if (p <= 0.82) {
      final t = _easeInQuad((p - 0.55) / 0.27);
      final lift = _verticalApproach(e) * 0.4;
      return BimVec3(0, lift * (1 - t), 0);
    }

    // Phase 4 — snap + lock (82–100%)
    final t = _easeOutBack((p - 0.82) / 0.18);
    return BimVec3(0, 0.035 * (1 - t), 0);
  }

  /// Y-axis rotation (radians) during align / install phases.
  static double assemblyRotation(BimEntity e, double buildProgress) {
    if (buildProgress >= 1.0 || buildProgress <= 0) return 0;
    final p = buildProgress.clamp(0.0, 1.0);

    // Rotate during travel (8–35%)
    if (p <= 0.35) {
      final t = _easeOutCubic((p - 0.08) / 0.27);
      return _targetRotation(e) * t;
    }

    // Settle rotation during align (35–55%)
    if (p <= 0.55) {
      final t = _easeInOutCubic((p - 0.35) / 0.2);
      return _targetRotation(e) * (1 - t * 0.9);
    }

    // Final settle (55–82%)
    if (p <= 0.82) {
      return _targetRotation(e) * 0.1 * (1 - (p - 0.55) / 0.27);
    }
    return 0;
  }

  static double _targetRotation(BimEntity e) {
    if (e.id.contains('roof') ||
        e.id.contains('truss') ||
        e.id.contains('purlin') ||
        e.id.contains('sheet')) {
      return math.pi / 2;
    }
    if (_isColumn(e)) return math.pi / 4;
    if (e.category == BimEntityCategory.masonry) return math.pi / 6;
    if (e.category == BimEntityCategory.rebar) return math.pi / 5;
    return math.pi / 8;
  }

  static BimVec3 _fullStagingOffset(BimEntity e) {
    final zone = _stagingZone(e);
    final lift = _verticalApproach(e);
    return BimVec3(
      zone.x * stagingDistance,
      zone.y * stagingDistance * 0.12 + lift,
      zone.z * stagingDistance,
    );
  }

  /// Materials left, structural right, roof rear.
  static ({double x, double y, double z}) _stagingZone(BimEntity e) {
    switch (e.category) {
      case BimEntityCategory.masonry:
      case BimEntityCategory.earthbag:
      case BimEntityCategory.finishing:
        if (e.id.startsWith('roof_sheet')) {
          return (x: 0.0, y: 0.0, z: -1.0);
        }
        return (x: -1.0, y: 0.0, z: 0.0);
      case BimEntityCategory.rebar:
      case BimEntityCategory.concrete:
      case BimEntityCategory.bamboo:
      case BimEntityCategory.timber:
      case BimEntityCategory.wire:
      case BimEntityCategory.formwork:
        return (x: 1.0, y: 0.0, z: 0.0);
      default:
        if (e.id.contains('roof') ||
            e.id.contains('truss') ||
            e.id.contains('purlin') ||
            e.id.contains('ridge') ||
            e.id.contains('bracing')) {
          return (x: 0.0, y: 0.0, z: -1.0);
        }
        if (e.id.contains('found') ||
            e.id.contains('footing') ||
            e.id.contains('trench') ||
            e.id.contains('excav') ||
            e.id.contains('pcc')) {
          return (x: 0.0, y: -0.25, z: 0.0);
        }
        return (x: -0.5, y: 0.0, z: 0.3);
    }
  }

  static double _verticalApproach(BimEntity e) {
    if (e.id.contains('roof') ||
        e.id.contains('truss') ||
        e.id.contains('ridge') ||
        e.id.contains('purlin')) {
      return 2.5;
    }
    if (e.id.startsWith('roof_sheet')) return 1.8;
    if (_isColumn(e)) return 1.6;
    if (e.category == BimEntityCategory.masonry) return 0.6;
    if (e.category == BimEntityCategory.timber) return 0.9;
    if (e.category == BimEntityCategory.rebar) return 0.45;
    return 0.3;
  }

  static bool _isColumn(BimEntity e) =>
      e.id.contains('column') ||
      e.id.contains('col_') ||
      e.id.startsWith('tie_col') ||
      e.id.startsWith('steel_column') ||
      e.id.startsWith('timber_column');

  static double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();

  static double _easeInOutCubic(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;

  static double _easeInQuad(double t) => t * t;

  static double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }
}
