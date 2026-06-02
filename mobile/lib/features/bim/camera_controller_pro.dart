import 'dart:math' as math;

import '../bim_simulation/engine/math/bim_vec3.dart';
import '../bim_simulation/engine/rendering/bim_camera.dart';
import '../bim_simulation/engine/rendering/bim_scene_bounds.dart';

/// Professional orbit camera — auto-fit, presets, focus, viewport-aware scale.
class CameraControllerPro {
  CameraControllerPro({BimCamera? inner}) : _camera = inner ?? BimCamera();

  final BimCamera _camera;

  BimCamera get camera => _camera;

  double _viewportFillTarget = 0.85;

  void setViewportFill(double fraction) {
    _viewportFillTarget = fraction.clamp(0.72, 0.92);
  }

  /// Desktop 80%, tablet 75%, mobile 90% viewport occupancy.
  void setViewportClass({required double width}) {
    if (width >= 1024) {
      setViewportFill(0.80);
    } else if (width >= 600) {
      setViewportFill(0.75);
    } else {
      setViewportFill(0.90);
    }
  }

  void fitToBounds(BimSceneBounds bounds, {double? viewportWidth, double? viewportHeight}) {
    if (viewportWidth != null) {
      setViewportClass(width: viewportWidth);
    }

    _camera.target = bounds.center;
    _camera.panX = 0;
    _camera.panY = 0;

    final fill = _viewportFillTarget;
    var scale = 1.85 / fill;
    if (viewportWidth != null && viewportHeight != null && viewportWidth > 0) {
      final aspect = viewportWidth / viewportHeight;
      scale = aspect > 1.2 ? 2.0 / fill : 1.75 / fill;
    }
    _camera.distance = (bounds.radius * scale).clamp(5.5, 36.0);
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
    _camera.distance = (radius * 2.8).clamp(5.0, 24.0);
  }

  void applyPreset(CameraPreset preset, BimVec3 center, double radius) {
    _camera.target = center;
    _camera.panX = 0;
    _camera.panY = 0;
    _camera.distance = (radius * 2.4).clamp(8.0, 32.0);

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
        _camera.distance = (radius * 2.9).clamp(10.0, 30.0);
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
