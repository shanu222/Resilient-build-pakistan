import 'dart:math' as math;
import 'dart:ui';

import '../math/bim_vec3.dart';
import 'bim_camera.dart';

class ProjectedTriangle {
  ProjectedTriangle({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.depth,
    required this.color,
    required this.entityId,
    required this.showEdges,
  });

  final Offset p1;
  final Offset p2;
  final Offset p3;
  final double depth;
  final Color color;
  final String entityId;
  final bool showEdges;
}

class BimProjector {
  BimProjector({required this.camera, required this.viewportSize});

  final BimCamera camera;
  final Size viewportSize;

  Offset project(BimVec3 world, {double? depthOut}) {
    final rel = world - camera.position;
    final view = _viewMatrix();
    final vx = view[0] * rel.x + view[1] * rel.y + view[2] * rel.z;
    final vy = view[3] * rel.x + view[4] * rel.y + view[5] * rel.z;
    final vz = view[6] * rel.x + view[7] * rel.y + view[8] * rel.z;

    final fov = 900.0;
    final scale = fov / (vz + fov * 0.02);
    final sx = viewportSize.width / 2 + vx * scale;
    final sy = viewportSize.height / 2 - vy * scale;
    if (depthOut != null) {
      // ignore - can't set out param easily
    }
    return Offset(sx, sy);
  }

  double depthAt(BimVec3 world) {
    final rel = world - camera.position;
    final view = _viewMatrix();
    return view[6] * rel.x + view[7] * rel.y + view[8] * rel.z;
  }

  List<double> _viewMatrix() {
    final forward = (camera.target - camera.position).normalized();
    final right = forward.cross(const BimVec3(0, 1, 0)).normalized();
    final up = right.cross(forward).normalized();
    return [
      right.x, right.y, right.z,
      up.x, up.y, up.z,
      forward.x, forward.y, forward.z,
    ];
  }
}
