import 'dart:ui';

import 'geometry/bim_mesh.dart';
import 'math/bim_vec3.dart';

enum BimEntityCategory {
  terrain,
  survey,
  grid,
  excavation,
  concrete,
  masonry,
  earthbag,
  wire,
  rebar,
  timber,
  bamboo,
  drainage,
  formwork,
  finishing,
  annotation,
  equipment,
}

class BimEntity {
  BimEntity({
    required this.id,
    required this.label,
    required this.mesh,
    required this.color,
    required this.category,
    this.position = BimVec3.zero,
    this.explodeGroup = 0,
    this.minStage = 0,
    this.opacity = 1.0,
    this.visible = true,
    this.pickable = false,
    this.componentId,
  });

  final String id;
  final String label;
  final BimMesh mesh;
  final Color color;
  final BimEntityCategory category;
  final BimVec3 position;
  final int explodeGroup;
  final int minStage;
  double opacity;
  bool visible;
  final bool pickable;
  final String? componentId;

  /// Build progress 0–1 within current stage animation.
  double buildProgress = 1.0;

  BimAabb get bounds {
    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    var maxZ = -double.infinity;
    for (final v in mesh.vertices) {
      final p = position + v;
      minX = minX < p.x ? minX : p.x;
      minY = minY < p.y ? minY : p.y;
      minZ = minZ < p.z ? minZ : p.z;
      maxX = maxX > p.x ? maxX : p.x;
      maxY = maxY > p.y ? maxY : p.y;
      maxZ = maxZ > p.z ? maxZ : p.z;
    }
    return BimAabb(BimVec3(minX, minY, minZ), BimVec3(maxX, maxY, maxZ));
  }
}
