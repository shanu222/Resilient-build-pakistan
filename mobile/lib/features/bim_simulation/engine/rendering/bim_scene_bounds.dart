import 'dart:math' as math;

import '../bim_entity.dart';
import '../math/bim_vec3.dart';

/// Axis-aligned bounds for procedural BIM scenes (camera auto-fit).
class BimSceneBounds {
  const BimSceneBounds({
    required this.min,
    required this.max,
    required this.center,
    required this.radius,
  });

  final BimVec3 min;
  final BimVec3 max;
  final BimVec3 center;
  final double radius;

  static BimSceneBounds fromEntities(Iterable<BimEntity> entities) {
    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    var maxZ = -double.infinity;

    for (final e in entities) {
      if (!e.visible) continue;
      final b = e.bounds;
      minX = minX < b.min.x ? minX : b.min.x;
      minY = minY < b.min.y ? minY : b.min.y;
      minZ = minZ < b.min.z ? minZ : b.min.z;
      maxX = maxX > b.max.x ? maxX : b.max.x;
      maxY = maxY > b.max.y ? maxY : b.max.y;
      maxZ = maxZ > b.max.z ? maxZ : b.max.z;
    }

    if (minX == double.infinity) {
      return const BimSceneBounds(
        min: BimVec3(-3, 0, -3),
        max: BimVec3(3, 3, 3),
        center: BimVec3.zero,
        radius: 5,
      );
    }

    final min = BimVec3(minX, minY, minZ);
    final max = BimVec3(maxX, maxY, maxZ);
    final center = BimVec3(
      (minX + maxX) / 2,
      (minY + maxY) / 2,
      (minZ + maxZ) / 2,
    );
    final dx = maxX - minX;
    final dy = maxY - minY;
    final dz = maxZ - minZ;
    final radius = math.sqrt(dx * dx + dy * dy + dz * dz) / 2 + 0.5;
    return BimSceneBounds(min: min, max: max, center: center, radius: radius);
  }
}
