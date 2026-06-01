import 'dart:math' as math;

import '../bim_simulation/engine/bim_entity.dart';
import '../bim_simulation/engine/math/bim_vec3.dart';

/// Staging zones and delivery paths for real assembly animation.
abstract final class ConstructionAssemblyAnimator {
  static const stagingDistance = 4.5;

  /// Offset from final position while component is being placed (buildProgress 0→1).
  static BimVec3 assemblyOffset(BimEntity e, double buildProgress) {
    if (buildProgress >= 1.0) return BimVec3.zero;
    if (buildProgress <= 0) return _fullStagingOffset(e);

    final t = _easeOutCubic(buildProgress);
    final staging = _fullStagingOffset(e);
    return BimVec3(
      staging.x * (1 - t),
      staging.y * (1 - t),
      staging.z * (1 - t),
    );
  }

  static BimVec3 _fullStagingOffset(BimEntity e) {
    final zone = _stagingZone(e);
    final lift = _verticalApproach(e);
    return BimVec3(
      zone.x * stagingDistance,
      zone.y * stagingDistance * 0.15 + lift,
      zone.z * stagingDistance,
    );
  }

  static ({double x, double y, double z}) _stagingZone(BimEntity e) {
    switch (e.category) {
      case BimEntityCategory.masonry:
      case BimEntityCategory.earthbag:
      case BimEntityCategory.finishing:
        return (x: -1.0, y: 0.0, z: 0.0); // materials — left
      case BimEntityCategory.rebar:
      case BimEntityCategory.concrete:
      case BimEntityCategory.bamboo:
      case BimEntityCategory.timber:
      case BimEntityCategory.wire:
        return (x: 1.0, y: 0.0, z: 0.0); // structural — right
      default:
        if (e.id.contains('roof') || e.id.contains('slab') || e.id.contains('truss')) {
          return (x: 0.0, y: 0.0, z: -1.0); // roof — rear
        }
        if (e.id.contains('found') || e.id.contains('trench') || e.id.contains('excav')) {
          return (x: 0.0, y: -0.3, z: 0.0); // below grade delivery
        }
        return (x: -0.6, y: 0.0, z: 0.3);
    }
  }

  static double _verticalApproach(BimEntity e) {
    if (e.id.contains('roof') || e.id.contains('slab')) return 2.0;
    if (_isColumn(e)) return 1.5;
    if (e.category == BimEntityCategory.masonry) return 0.4;
    return 0.0;
  }

  static bool _isColumn(BimEntity e) =>
      e.id.contains('column') || e.id.contains('col_') || e.id.startsWith('vbar');

  static double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
}
