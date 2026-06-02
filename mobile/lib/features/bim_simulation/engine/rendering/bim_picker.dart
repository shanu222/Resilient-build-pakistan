import 'dart:ui';

import '../bim_entity.dart';
import '../math/bim_vec3.dart';
import 'bim_camera.dart';
import 'bim_projector.dart';

/// Screen-space picking for structural BIM components.
class BimPicker {
  static String? pickComponent(
    Offset screenPos,
    Size size,
    List<BimEntity> entities,
    BimCamera camera,
  ) {
    final projector = BimProjector(camera: camera, viewportSize: size);
    String? bestId;
    var bestDist = 48.0;

    for (final e in entities) {
      if (!e.pickable || !e.visible || e.componentId == null) continue;
      final c = e.bounds.center;
      final p = projector.project(c);
      final d = (p - screenPos).distance;
      if (d < bestDist) {
        bestDist = d;
        bestId = e.componentId;
      }
    }
    return bestId;
  }
}
