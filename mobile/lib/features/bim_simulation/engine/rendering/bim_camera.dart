import 'dart:math' as math;

import '../math/bim_vec3.dart';

/// Orbit camera for BIM viewport (rotate, zoom, pan).
class BimCamera {
  double yaw = 0.65;
  double pitch = 0.45;
  double distance = 14.0;
  BimVec3 target = const BimVec3(3, 1.5, 2);
  double panX = 0;
  double panY = 0;

  BimVec3 get position {
    final cp = math.cos(pitch);
    final x = target.x + distance * cp * math.sin(yaw) + panX;
    final y = target.y + distance * math.sin(pitch) + panY;
    final z = target.z + distance * cp * math.cos(yaw);
    return BimVec3(x, y, z);
  }

  void rotate(double dx, double dy) {
    yaw -= dx * 0.01;
    pitch = (pitch + dy * 0.01).clamp(0.15, 1.45);
  }

  void pan(double dx, double dy) {
    panX -= dx * 0.02;
    panY += dy * 0.02;
  }

  void zoom(double delta) {
    distance = (distance + delta * 0.02).clamp(6.0, 28.0);
  }

  void autoOrbit(double t) {
    yaw = 0.65 + t * 0.3;
  }

  /// Fit entire structure in view (building centroid at orbit target).
  void fitToBounds(BimVec3 center, double radius) {
    target = center;
    distance = (radius * 2.4).clamp(10.0, 36.0);
    pitch = 0.42;
    yaw = 0.72;
    panX = 0;
    panY = 0;
  }
}
