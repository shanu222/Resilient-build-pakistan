import 'dart:math' as math;

import '../bim_simulation/engine/math/bim_vec3.dart';
import '../bim_simulation/engine/rendering/bim_camera.dart';
import '../bim_simulation/engine/rendering/bim_scene_bounds.dart';

/// Professional orbit camera — auto-fit, presets, focus, viewport-aware scale.
class CameraControllerPro {
  CameraControllerPro({BimCamera? inner}) : _camera = inner ?? BimCamera();

  final BimCamera _camera;

  BimCamera get camera => _camera;

  double _viewportFillTarget = 0.78;

  void setViewportFill(double fraction) {
    _viewportFillTarget = fraction.clamp(0.65, 0.88);
  }

  void fitToBounds(BimSceneBounds bounds, {double? viewportWidth, double? viewportHeight}) {
    _camera.target = bounds.center;
    _camera.panX = 0;
    _camera.panY = 0;

    var scale = 2.4;
    if (viewportWidth != null && viewportHeight != null && viewportWidth > 0) {
      final aspect = viewportWidth / viewportHeight;
      final fill = _viewportFillTarget;
      scale = aspect > 1.2 ? 2.6 / fill : 2.2 / fill;
    }
    _camera.distance = (bounds.radius * scale).clamp(8.0, 42.0);
    _camera.pitch = 0.42;
    _camera.yaw = 0.72;
  }

  void reset() {
    _camera.yaw = 0.72;
    _camera.pitch = 0.42;
    _camera.panX = 0;
    _camera.panY = 0;
  }

  void rotate(double dx, double dy) => _camera.rotate(dx, dy);
  void pan(double dx, double dy) => _camera.pan(dx, dy);
  void zoom(double delta) => _camera.zoom(delta);
  void zoomIn() => _camera.zoom(-8);
  void zoomOut() => _camera.zoom(8);

  void focusOn(BimVec3 point, {double radius = 2.0}) {
    _camera.target = point;
    _camera.distance = (radius * 3.2).clamp(6.0, 28.0);
  }

  void applyPreset(CameraPreset preset, BimVec3 center, double radius) {
    _camera.target = center;
    _camera.panX = 0;
    _camera.panY = 0;
    _camera.distance = (radius * 2.8).clamp(10.0, 40.0);

    switch (preset) {
      case CameraPreset.top:
        _camera.pitch = 1.45;
        _camera.yaw = 0;
      case CameraPreset.front:
        _camera.pitch = 0.35;
        _camera.yaw = 0;
      case CameraPreset.rear:
        _camera.pitch = 0.35;
        _camera.yaw = math.pi;
      case CameraPreset.side:
        _camera.pitch = 0.35;
        _camera.yaw = math.pi / 2;
      case CameraPreset.isometric:
        _camera.pitch = 0.55;
        _camera.yaw = 0.65;
      case CameraPreset.structural:
        _camera.pitch = 0.25;
        _camera.yaw = 0.4;
        _camera.distance = (radius * 3.4).clamp(12.0, 36.0);
    }
  }

  void autoOrbit(double t) => _camera.autoOrbit(t);
}

enum CameraPreset {
  top,
  front,
  rear,
  side,
  isometric,
  structural,
}
