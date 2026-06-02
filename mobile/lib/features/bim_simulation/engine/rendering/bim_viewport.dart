import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../bim_entity.dart';
import '../bim_simulation_controller.dart';
import '../bim_visualization_mode.dart';
import '../../ui/bim_toolbar.dart';
import '../../../bim/camera_controller_pro.dart';
import '../../../bim/engineering/construction_sequence_engine.dart';
import '../../../bim/engineering_constraint_engine.dart';
import 'bim_scene_bounds.dart';
import '../math/bim_vec3.dart';
import 'bim_camera.dart';
import 'bim_projector.dart';

class BimViewport extends StatefulWidget {
  const BimViewport({super.key, required this.controller});

  final BimSimulationController controller;

  @override
  State<BimViewport> createState() => _BimViewportState();
}

class _BimViewportState extends State<BimViewport>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration? _lastTick;
  Offset? _lastPan;
  Offset? _lastTap;
  Size? _lastFitSize;

  CameraControllerPro get _cameraPro => widget.controller.cameraPro;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (_lastTick != null) {
      final dt = (elapsed - _lastTick!).inMicroseconds / 1e6;
      final c = widget.controller;
      c.advanceEnvironmentalEffects(dt);
      if (c.isPlaying ||
          (c.stageIndex == c.stages.length - 1 && c.stageProgress > 0)) {
        c.tick(dt);
      }
    }
    _lastTick = elapsed;
  }

  @override
  void dispose() {
    _ticker.dispose();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_lastFitSize != size && size.width > 0 && size.height > 0) {
          _lastFitSize = size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            widget.controller.fitCamera(
              viewportWidth: size.width,
              viewportHeight: size.height,
            );
          });
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onScaleStart: (d) => _lastPan = d.focalPoint,
              onScaleUpdate: (d) {
                if (d.pointerCount >= 2) {
                  _cameraPro.zoom(-d.scale * 20 + 20);
                } else if (_lastPan != null) {
                  final delta = d.focalPoint - _lastPan!;
                  if (d.scale == 1.0 && delta.distance > 2) {
                    if (d.pointerCount == 1) {
                      _cameraPro.rotate(delta.dx, delta.dy);
                    } else {
                      _cameraPro.pan(delta.dx, delta.dy);
                    }
                  }
                }
                _lastPan = d.focalPoint;
                setState(() {});
              },
              onDoubleTapDown: (d) => _lastTap = d.localPosition,
              onDoubleTap: () {
                widget.controller.fitCamera(
                  viewportWidth: size.width,
                  viewportHeight: size.height,
                );
                if (_lastTap != null) {
                  widget.controller.selectAt(_lastTap!, size);
                }
                setState(() {});
              },
              onTapUp: (d) {
                widget.controller.selectAt(d.localPosition, size);
              },
              child: CustomPaint(
                size: size,
                painter: _BimPainter(
                  controller: widget.controller,
                  viewportSize: size,
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: BimToolbar(
                controller: widget.controller,
                cameraPro: _cameraPro,
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isRotating(ScaleUpdateDetails d) {
    return d.rotation != 0 || d.focalPoint.dy < 200;
  }
}

class _BimPainter extends CustomPainter {
  _BimPainter({required this.controller, required this.viewportSize});

  final BimSimulationController controller;
  final Size viewportSize;

  @override
  void paint(Canvas canvas, Size size) {
    final projector = BimProjector(camera: controller.camera, viewportSize: size);

    // BIM viewport background — engineering gradient
    final bg = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bg,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8EEF4), Color(0xFFDCE4EC)],
        ).createShader(bg),
    );

    _drawGrid(canvas, size, projector);

    final validation = controller.validationResult;
    if (validation != null && !validation.passed) {
      _drawValidationBanner(canvas, size, validation);
    }

    if (controller.showStructuralGrid) {
      _drawStructuralGrid(canvas, size, projector);
    }

    final triangles = <ProjectedTriangle>[];

    for (final e in controller.entities) {
      if (!e.visible || e.buildProgress <= 0) continue;
      if (controller.viewMode == BimVisualizationMode.rebar &&
          e.category != BimEntityCategory.rebar &&
          e.opacity < 0.5) {
        continue;
      }

      final explode = controller.explodeOffset(e) +
          controller.floatOffset(e) +
          controller.assemblyOffset(e);
      final mesh = e.mesh;
      final scaleY = e.buildProgress.clamp(0.01, 1.0);

      for (var i = 0; i < mesh.indices.length; i += 3) {
        final i0 = mesh.indices[i];
        final i1 = mesh.indices[i + 1];
        final i2 = mesh.indices[i + 2];
        var v0 = _transformVertex(mesh.vertices[i0], e, explode, scaleY);
        var v1 = _transformVertex(mesh.vertices[i1], e, explode, scaleY);
        var v2 = _transformVertex(mesh.vertices[i2], e, explode, scaleY);

        if (!controller.passesCrossSection(v0) &&
            !controller.passesCrossSection(v1) &&
            !controller.passesCrossSection(v2)) {
          continue;
        }

        if (_isSeismicMode(controller.viewMode) && _shakesUnderLoad(e)) {
          final shake = math.sin(controller.earthquakePhase) * 0.035;
          final lift = math.cos(controller.earthquakePhase * 0.7) * 0.008;
          v0 = v0 + BimVec3(shake, lift, 0);
          v1 = v1 + BimVec3(shake, lift, 0);
          v2 = v2 + BimVec3(shake, lift, 0);
        }
        if (controller.viewMode == BimVisualizationMode.wind && _shakesUnderLoad(e)) {
          final sway = math.sin(controller.earthquakePhase * 1.3) * 0.02;
          v0 = v0 + BimVec3(sway, 0, sway * 0.5);
          v1 = v1 + BimVec3(sway, 0, sway * 0.5);
          v2 = v2 + BimVec3(sway, 0, sway * 0.5);
        }

        final p0 = projector.project(v0);
        final p1 = projector.project(v1);
        final p2 = projector.project(v2);
        final depth = (projector.depthAt(v0) +
                projector.depthAt(v1) +
                projector.depthAt(v2)) /
            3;

        var color = e.color.withValues(alpha: e.opacity * controller.assemblyOpacity(e));
        if (controller.viewMode == BimVisualizationMode.foundation) {
          final isFound = e.id.contains('found') ||
              e.id.contains('footing') ||
              e.id.contains('plinth') ||
              e.id.contains('pcc') ||
              e.id.contains('excav');
          if (!isFound) {
            color = color.withValues(alpha: color.a * 0.12);
          }
        }
        final connGlow = ConstructionSequenceEngine.connectionHighlight(
          e,
          e.buildProgress,
        );
        if (connGlow > 0.05) {
          color = Color.lerp(color, const Color(0xFF22C55E), connGlow * 0.45)!;
        }
        if (controller.viewMode == BimVisualizationMode.structural) {
          color = _structuralTint(e, color);
        }

        triangles.add(
          ProjectedTriangle(
            p1: p0,
            p2: p1,
            p3: p2,
            depth: depth,
            color: color,
            entityId: e.id,
            showEdges: true,
          ),
        );
      }
    }

    triangles.sort((a, b) => b.depth.compareTo(a.depth));

    for (final t in triangles) {
      final path = Path()
        ..moveTo(t.p1.dx, t.p1.dy)
        ..lineTo(t.p2.dx, t.p2.dy)
        ..lineTo(t.p3.dx, t.p3.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = t.color);
      if (t.showEdges) {
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF0F172A).withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
      }
    }

    if (controller.viewMode == BimVisualizationMode.loadTransfer) {
      _drawLoadArrows(
        canvas,
        size,
        projector,
        earthbag: controller.isEarthbag,
        cementBamboo: controller.isCementBamboo,
        confinedBlock: controller.isConfinedBlock,
        elevatedFlood: controller.isElevatedFlood,
        amphibious: controller.isAmphibious,
        flyAsh: controller.isFlyAsh,
        geogrid: controller.isGeogrid,
        lightGaugeSteel: controller.isLightGaugeSteel,
        lohKaat: controller.isLohKaat,
        prefabricated: controller.isPrefabricated,
        raisedPlinth: controller.isRaisedPlinth,
        ratTrapBond: controller.isRatTrapBond,
        reinforcedAdobe: controller.isReinforcedAdobe,
        timberFrameLath: controller.isTimberFrameLath,
        advancedInterlocking: controller.isAdvancedInterlocking,
        interlockingBrick: controller.isInterlockingBrick,
      );
      _drawFoundationReactions(canvas, projector);
    }

    if (controller.viewMode == BimVisualizationMode.timberSkeleton &&
        controller.isTimberFrameLath) {
      _drawTimberSkeletonOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.reinforcement &&
        controller.isReinforcedAdobe) {
      _drawReinforcementOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.modularAssembly &&
        controller.isPrefabricated) {
      _drawModularAssemblyOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.blockAssembly &&
        controller.isAdvancedInterlocking) {
      _drawBlockAssemblyOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.timberBand &&
        controller.isLohKaat) {
      _drawTimberBandOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.connection &&
        controller.isLightGaugeSteel) {
      _drawConnectionOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.thermal &&
        (controller.isFlyAsh ||
            controller.isPrefabricated ||
            controller.isRatTrapBond ||
            controller.isReinforcedAdobe ||
            controller.isTimberFrameLath)) {
      _drawThermalOverlay(
        canvas,
        size,
        projector,
        prefabricated: controller.isPrefabricated,
        ratTrapBond: controller.isRatTrapBond,
        reinforcedAdobe: controller.isReinforcedAdobe,
        timberFrameLath: controller.isTimberFrameLath,
      );
    }

    if (controller.viewMode == BimVisualizationMode.cavityWall &&
        controller.isRatTrapBond) {
      _drawCavityWallOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.materialComparison &&
        controller.isRatTrapBond) {
      _drawMaterialComparisonOverlay(canvas, size);
    }

    if (controller.viewMode == BimVisualizationMode.landslide &&
        controller.isGeogrid) {
      _drawLandslideOverlay(canvas, size, projector);
    }

    if (controller.viewMode == BimVisualizationMode.earthPressure &&
        controller.isGeogrid) {
      _drawEarthPressureOverlay(canvas, size, projector);
    }

    if (controller.viewMode == BimVisualizationMode.groundwater &&
        controller.isGeogrid) {
      _drawGroundwaterOverlay(canvas, size, projector);
    }

    if (controller.viewMode == BimVisualizationMode.drainage &&
            (controller.isEarthbag ||
                controller.isElevatedFlood ||
                controller.isRaisedPlinth ||
                controller.isGeogrid ||
                controller.isLohKaat) ||
        (controller.viewMode == BimVisualizationMode.hydraulic &&
            (controller.isElevatedFlood || controller.isAmphibious))) {
      _drawDrainageOverlay(
        canvas,
        size,
        projector,
        elevatedFlood: controller.isElevatedFlood,
        amphibious: controller.isAmphibious,
        geogrid: controller.isGeogrid,
        raisedPlinth: controller.isRaisedPlinth,
      );
    }

    if (controller.viewMode == BimVisualizationMode.flood &&
        (controller.isElevatedFlood ||
            controller.isAmphibious ||
            controller.isRaisedPlinth)) {
      _drawFloodOverlay(canvas, size, projector);
    }

    if (controller.viewMode == BimVisualizationMode.buoyancy &&
        controller.isAmphibious) {
      _drawBuoyancyOverlay(canvas, size, projector);
    }

    if (controller.viewMode == BimVisualizationMode.hydraulic &&
        (controller.isElevatedFlood || controller.isAmphibious)) {
      _drawHydraulicOverlay(canvas, size, projector);
    }

    if (_isSeismicMode(controller.viewMode)) {
      _drawSeismicOverlay(canvas, size);
    }

    _drawHud(canvas, size);
  }

  bool _isSeismicMode(BimVisualizationMode m) =>
      m == BimVisualizationMode.earthquake || m == BimVisualizationMode.seismic;

  bool _shakesUnderLoad(BimEntity e) =>
      e.category == BimEntityCategory.masonry ||
      e.category == BimEntityCategory.earthbag ||
      e.category == BimEntityCategory.bamboo ||
      e.category == BimEntityCategory.wire ||
      (controller.isLightGaugeSteel &&
          (e.category == BimEntityCategory.rebar ||
              e.id.startsWith('brace'))) ||
      (controller.isLohKaat &&
          (e.category == BimEntityCategory.timber ||
              e.category == BimEntityCategory.masonry)) ||
      (controller.isPrefabricated &&
          (e.explodeGroup >= 2 && e.explodeGroup <= 4)) ||
      (controller.isReinforcedAdobe &&
          (e.category == BimEntityCategory.masonry ||
              e.category == BimEntityCategory.wire)) ||
      (controller.isTimberFrameLath &&
          (e.category == BimEntityCategory.timber ||
              e.id.startsWith('brace') ||
              e.id.startsWith('plaster'))) ||
      (controller.isAdvancedInterlocking &&
          (e.category == BimEntityCategory.masonry ||
              e.category == BimEntityCategory.rebar ||
              e.id.contains('band')));

  BimVec3 _transformVertex(
    BimVec3 v,
    BimEntity e,
    BimVec3 explode,
    double scaleY,
  ) {
    var local = BimVec3(v.x, v.y * scaleY, v.z);
    final rot = controller.assemblyRotation(e);
    if (rot.abs() > 0.001) {
      final b = e.bounds;
      final center = BimVec3(
        b.center.x - e.position.x,
        b.center.y - e.position.y,
        b.center.z - e.position.z,
      );
      final dx = local.x - center.x;
      final dz = local.z - center.z;
      final cosR = math.cos(rot);
      final sinR = math.sin(rot);
      local = BimVec3(
        center.x + dx * cosR - dz * sinR,
        local.y,
        center.z + dx * sinR + dz * cosR,
      );
    }
    return BimVec3(
      e.position.x + local.x + explode.x,
      e.position.y + local.y + explode.y,
      e.position.z + local.z + explode.z,
    );
  }

  void _drawValidationBanner(Canvas canvas, Size size, ConstraintValidationResult result) {
    final h = 72.0;
    final rect = Rect.fromLTWH(8, 8, size.width - 16, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFFEE2E2).withValues(alpha: 0.92),
    );
    final title = TextPainter(
      text: TextSpan(
        text: 'Engineering QC: ${result.errors.length} issue(s)',
        style: const TextStyle(
          color: Color(0xFF991B1B),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 16);
    title.paint(canvas, Offset(rect.left + 12, rect.top + 10));
    final body = result.errors.take(2).join(' · ');
    final detail = TextPainter(
      text: TextSpan(
        text: body,
        style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 16);
    detail.paint(canvas, Offset(rect.left + 12, rect.top + 32));
  }

  void _drawValidationBlocked(Canvas canvas, Size size, ConstraintValidationResult result) {
    final panel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: math.min(size.width - 32, 420),
        height: math.min(size.height * 0.45, 260),
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      panel,
      Paint()..color = const Color(0xFFFEE2E2),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final title = TextPainter(
      text: const TextSpan(
        text: 'Engineering validation failed',
        style: TextStyle(
          color: Color(0xFF991B1B),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: panel.width - 24);
    title.paint(canvas, Offset(panel.left + 16, panel.top + 16));

    final body = result.errors.take(4).join('\n');
    final detail = TextPainter(
      text: TextSpan(
        text: body.isEmpty ? 'Column float or alignment check failed.' : body,
        style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 12, height: 1.4),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: panel.width - 32);
    detail.paint(canvas, Offset(panel.left + 16, panel.top + 48));
  }

  void _drawFoundationReactions(Canvas canvas, BimProjector projector) {
    final c = controller.sceneCenter;
    final corners = [
      BimVec3(c.x - 1.8, 0.05, c.z - 1.2),
      BimVec3(c.x + 1.8, 0.05, c.z - 1.2),
      BimVec3(c.x + 1.8, 0.05, c.z + 1.2),
      BimVec3(c.x - 1.8, 0.05, c.z + 1.2),
    ];
    for (final corner in corners) {
      final top = projector.project(corner + const BimVec3(0, 0.35, 0));
      final base = projector.project(corner);
      _arrow(canvas, top, base, '', const Color(0xFF22C55E));
    }
    final labelPt = projector.project(BimVec3(c.x, 0.15, c.z + 2.2));
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Foundation reactions ↑',
        style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, labelPt - Offset(tp.width / 2, 0));
  }

  Color _structuralTint(BimEntity e, Color c) {
    switch (e.category) {
      case BimEntityCategory.rebar:
        return const Color(0xFFEA580C);
      case BimEntityCategory.concrete:
        return const Color(0xFF6B7280);
      case BimEntityCategory.masonry:
      case BimEntityCategory.earthbag:
        return const Color(0xFFB45309);
      case BimEntityCategory.wire:
        return const Color(0xFF525252);
      case BimEntityCategory.timber:
        return const Color(0xFF92400E);
      case BimEntityCategory.bamboo:
        return const Color(0xFF65A30D);
      default:
        return c.withValues(alpha: 0.3);
    }
  }

  void _drawStructuralGrid(Canvas canvas, Size size, BimProjector projector) {
    final bounds = BimSceneBounds.fromEntities(controller.entities, structuralOnly: true);
    final minX = bounds.min.x.floor();
    final maxX = bounds.max.x.ceil();
    final minZ = bounds.min.z.floor();
    final maxZ = bounds.max.z.ceil();
    final paint = Paint()
      ..color = const Color(0xFFE85D04).withValues(alpha: 0.65)
      ..strokeWidth = 1.2;
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    var label = 0;
    for (var x = minX; x <= maxX; x++) {
      for (var z = minZ; z <= maxZ; z++) {
        final p = projector.project(BimVec3(x.toDouble(), 0.02, z.toDouble()));
        canvas.drawCircle(p, 3, paint);
        if ((x - minX).isEven && (z - minZ).isEven) {
          labelPaint.text = TextSpan(
            text: '${String.fromCharCode(65 + (x - minX).clamp(0, 25))}$z',
            style: const TextStyle(color: Color(0xFFE85D04), fontSize: 9),
          );
          labelPaint.layout();
          labelPaint.paint(canvas, Offset(p.dx + 4, p.dy - 8));
          label++;
        }
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, BimProjector projector) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    for (var i = 0; i <= 10; i++) {
      final a = projector.project(BimVec3(i.toDouble(), 0, 0));
      final b = projector.project(BimVec3(i.toDouble(), 0, 12));
      canvas.drawLine(a, b, paint);
      final c = projector.project(BimVec3(0, 0, i.toDouble()));
      final d = projector.project(BimVec3(10, 0, i.toDouble()));
      canvas.drawLine(c, d, paint);
    }
  }

  void _drawLoadArrows(
    Canvas canvas,
    Size size,
    BimProjector projector, {
    bool earthbag = false,
    bool cementBamboo = false,
    bool confinedBlock = false,
    bool elevatedFlood = false,
    bool amphibious = false,
    bool flyAsh = false,
    bool geogrid = false,
    bool lightGaugeSteel = false,
    bool lohKaat = false,
    bool prefabricated = false,
    bool raisedPlinth = false,
    bool ratTrapBond = false,
    bool reinforcedAdobe = false,
    bool timberFrameLath = false,
    bool advancedInterlocking = false,
    bool interlockingBrick = false,
  }) {
    if (interlockingBrick) {
      final cx = 3.0;
      final cz = 4.0;
      final roof = projector.project(BimVec3(cx, 4.8, cz));
      final band = projector.project(BimVec3(cx, 3.6, cz));
      final wall = projector.project(BimVec3(cx, 2.0, cz));
      final plinth = projector.project(BimVec3(cx, 0.45, cz));
      final foot = projector.project(BimVec3(cx, -0.35, cz));
      final soil = projector.project(BimVec3(cx, -1.0, cz));
      _arrow(canvas, roof, band, 'Roof → band', const Color(0xFFEF4444));
      _arrow(canvas, band, wall, 'Bands → walls', const Color(0xFFF97316));
      _arrow(canvas, wall, plinth, 'Walls → plinth', const Color(0xFFEA580C));
      _arrow(canvas, plinth, foot, 'Plinth → footings', const Color(0xFF64748B));
      _arrow(canvas, foot, soil, 'Foundation → soil', const Color(0xFF22C55E));
      return;
    }
    if (advancedInterlocking) {
      const cx = 4.0;
      const cz = 3.0;
      final roof = projector.project(BimVec3(cx, 4.9, cz));
      final band = projector.project(BimVec3(cx, 3.6, cz));
      final wall = projector.project(BimVec3(cx, 2.0, cz));
      final core = projector.project(BimVec3(cx, 1.5, cz));
      final plinth = projector.project(BimVec3(cx, 0.45, cz));
      final soil = projector.project(BimVec3(cx, -0.5, cz));
      _arrow(canvas, roof, band, 'Steel roof → band', const Color(0xFFEF4444));
      _arrow(canvas, band, wall, 'Bands → hollow blocks', const Color(0xFFF97316));
      _arrow(canvas, wall, core, 'Grouted cores', const Color(0xFFEA580C));
      _arrow(canvas, core, plinth, 'Plinth beam', const Color(0xFF64748B));
      _arrow(canvas, plinth, soil, 'Footings → soil', const Color(0xFF22C55E));
      return;
    }
    if (timberFrameLath) {
      final roof = projector.project(const BimVec3(2.8, 4.0, 2.15));
      final beam = projector.project(const BimVec3(2.8, 3.1, 2.15));
      final col = projector.project(const BimVec3(2.8, 1.6, 2.15));
      final plinth = projector.project(const BimVec3(2.8, 0.4, 2.15));
      final soil = projector.project(const BimVec3(2.8, -0.35, 2.15));
      _arrow(canvas, roof, beam, 'Roof / truss', const Color(0xFFEF4444));
      _arrow(canvas, beam, col, 'Beams → columns', const Color(0xFF92400E));
      _arrow(canvas, col, plinth, 'Columns → plinth', const Color(0xFFF97316));
      _arrow(canvas, plinth, soil, 'Foundation → soil', const Color(0xFF22C55E));
      return;
    }
    if (reinforcedAdobe) {
      final roof = projector.project(const BimVec3(2.9, 4.0, 2.2));
      final band = projector.project(const BimVec3(2.9, 3.2, 2.2));
      final wall = projector.project(const BimVec3(2.9, 1.8, 2.2));
      final plinth = projector.project(const BimVec3(2.9, 0.25, 2.2));
      final soil = projector.project(const BimVec3(2.9, -0.5, 2.2));
      _arrow(canvas, roof, band, 'Roof band', const Color(0xFFEF4444));
      _arrow(canvas, band, wall, 'Adobe walls', const Color(0xFFF97316));
      _arrow(canvas, wall, plinth, 'Plinth band', const Color(0xFF64748B));
      _arrow(canvas, plinth, soil, 'Footings', const Color(0xFF22C55E));
      return;
    }
    if (ratTrapBond) {
      final roof = projector.project(const BimVec3(3, 4.1, 2.25));
      final wall = projector.project(const BimVec3(3, 2.5, 2.25));
      final plinth = projector.project(const BimVec3(3, 0.35, 2.25));
      final foot = projector.project(const BimVec3(3, -0.45, 2.25));
      final soil = projector.project(const BimVec3(3, -0.9, 2.25));
      _arrow(canvas, roof, wall, 'Roof slab', const Color(0xFFEF4444));
      _arrow(canvas, wall, plinth, 'RTB walls', const Color(0xFFF97316));
      _arrow(canvas, plinth, foot, 'Plinth / footings', const Color(0xFF64748B));
      _arrow(canvas, foot, soil, 'Soil', const Color(0xFF22C55E));
      return;
    }
    if (raisedPlinth) {
      final roof = projector.project(const BimVec3(3.2, 4.2, 2.1));
      final wall = projector.project(const BimVec3(3.2, 2.8, 2.1));
      final plinth = projector.project(const BimVec3(3.2, 1.5, 2.1));
      final found = projector.project(const BimVec3(3.2, 0.2, 2.1));
      final soil = projector.project(const BimVec3(3.2, -0.35, 2.1));
      _arrow(canvas, roof, wall, 'Roof / walls', const Color(0xFFEF4444));
      _arrow(canvas, wall, plinth, 'Masonry → plinth', const Color(0xFFF97316));
      _arrow(canvas, plinth, found, 'Plinth beam', const Color(0xFF64748B));
      _arrow(canvas, found, soil, 'Footings → soil', const Color(0xFF22C55E));
      return;
    }
    if (prefabricated) {
      final roof = projector.project(const BimVec3(3, 4.0, 2.25));
      final wall = projector.project(const BimVec3(3, 2.5, 2.25));
      final floor = projector.project(const BimVec3(3, 1.0, 2.25));
      final anchor = projector.project(const BimVec3(3, 0.0, 2.25));
      final soil = projector.project(const BimVec3(3, -0.45, 2.25));
      _arrow(canvas, roof, wall, 'Roof panels', const Color(0xFFEF4444));
      _arrow(canvas, wall, floor, 'Wall modules', const Color(0xFFF97316));
      _arrow(canvas, floor, anchor, 'Floor → anchors', const Color(0xFF64748B));
      _arrow(canvas, anchor, soil, 'Foundation', const Color(0xFF22C55E));
      return;
    }
    if (lohKaat) {
      final roof = projector.project(const BimVec3(2.75, 4.2, 2.25));
      final band = projector.project(const BimVec3(2.75, 2.5, 2.25));
      final wall = projector.project(const BimVec3(2.75, 1.2, 2.25));
      final found = projector.project(const BimVec3(2.75, 0.1, 2.25));
      _arrow(canvas, roof, band, 'Roof frame', const Color(0xFFEF4444));
      _arrow(canvas, band, wall, 'Timber bands', const Color(0xFF92400E));
      _arrow(canvas, wall, found, 'Masonry → stone', const Color(0xFFF97316));
      return;
    }
    if (lightGaugeSteel) {
      final roof = projector.project(const BimVec3(3, 4.5, 2.25));
      final beam = projector.project(const BimVec3(3, 3.0, 2.25));
      final stud = projector.project(const BimVec3(3, 1.5, 2.25));
      final anchor = projector.project(const BimVec3(3, -0.1, 2.25));
      _arrow(canvas, roof, beam, 'Roof / truss', const Color(0xFFEF4444));
      _arrow(canvas, beam, stud, 'Beams / studs', const Color(0xFFF97316));
      _arrow(canvas, stud, anchor, 'Frame → anchors', const Color(0xFF607D8B));
      return;
    }
    if (geogrid) {
      final soil = projector.project(const BimVec3(2, 3, 5));
      final grid = projector.project(const BimVec3(6, 2, 5));
      final face = projector.project(const BimVec3(10, 2, 5));
      final road = projector.project(const BimVec3(12, 7.2, 5));
      _arrow(canvas, soil, grid, 'Earth pressure', const Color(0xFFEF4444));
      _arrow(canvas, grid, face, 'Geogrid tension', const Color(0xFF1D4ED8));
      _arrow(canvas, face, road, 'Road protected', const Color(0xFF22C55E));
      return;
    }
    if (flyAsh) {
      final roof = projector.project(const BimVec3(3, 4.1, 2.25));
      final wall = projector.project(const BimVec3(3, 2.2, 2.25));
      final found = projector.project(const BimVec3(3, 0.1, 2.25));
      final soil = projector.project(const BimVec3(3, -0.5, 2.25));
      _arrow(canvas, roof, wall, 'Roof slab', const Color(0xFFEF4444));
      _arrow(canvas, wall, found, 'Fly ash walls', const Color(0xFFF97316));
      _arrow(canvas, found, soil, 'Footings → soil', const Color(0xFF22C55E));
      return;
    }
    if (amphibious) {
      final roof = projector.project(const BimVec3(4.0, 4.2, 2.0));
      final deck = projector.project(const BimVec3(4.0, 0.75, 2.0));
      final drum = projector.project(const BimVec3(4.0, 0.25, 2.0));
      final pad = projector.project(const BimVec3(4.0, 0.12, 2.0));
      final soil = projector.project(const BimVec3(4.0, -0.1, 2.0));
      _arrow(canvas, roof, deck, 'House load', const Color(0xFFEF4444));
      _arrow(canvas, deck, drum, 'Platform → drums', const Color(0xFFF97316));
      _arrow(canvas, drum, pad, 'Buoyancy / guide', const Color(0xFF0EA5E9));
      _arrow(canvas, pad, soil, 'Foundation pads', const Color(0xFF22C55E));
      return;
    }
    if (elevatedFlood) {
      final roof = projector.project(const BimVec3(4.2, 7.8, 2.0));
      final slab = projector.project(const BimVec3(4.2, 2.85, 2.0));
      final beam = projector.project(const BimVec3(4.2, 2.55, 2.0));
      final col = projector.project(const BimVec3(4.2, 1.25, 2.0));
      final foot = projector.project(const BimVec3(4.2, -0.15, 2.0));
      final soil = projector.project(const BimVec3(4.2, -0.55, 2.0));
      _arrow(canvas, roof, slab, 'Roof / walls', const Color(0xFFEF4444));
      _arrow(canvas, slab, beam, 'Elevated slab', const Color(0xFFF97316));
      _arrow(canvas, beam, col, 'Platform beams', const Color(0xFFEA580C));
      _arrow(canvas, col, foot, 'RCC columns', const Color(0xFF64748B));
      _arrow(canvas, foot, soil, 'Footings / soil', const Color(0xFF22C55E));
      return;
    }
    if (confinedBlock) {
      final slab = projector.project(const BimVec3(3, 4.2, 2.25));
      final band = projector.project(const BimVec3(3, 3.5, 2.25));
      final tie = projector.project(const BimVec3(3, 2.0, 2.25));
      final plinth = projector.project(const BimVec3(3, 0.2, 2.25));
      final foot = projector.project(const BimVec3(3, -0.4, 2.25));
      final soil = projector.project(const BimVec3(3, -1.0, 2.25));
      _arrow(canvas, slab, band, 'Roof slab', const Color(0xFFEF4444));
      _arrow(canvas, band, tie, 'Bands / tie beams', const Color(0xFFF97316));
      _arrow(canvas, tie, plinth, 'Tie columns', const Color(0xFFEA580C));
      _arrow(canvas, plinth, foot, 'Plinth / footings', const Color(0xFF64748B));
      _arrow(canvas, foot, soil, 'Soil', const Color(0xFF22C55E));
      return;
    }
    if (cementBamboo) {
      final roof = projector.project(const BimVec3(3, 3.8, 2.5));
      final beam = projector.project(const BimVec3(3, 2.5, 2.5));
      final col = projector.project(const BimVec3(3, 0.5, 2.5));
      final found = projector.project(const BimVec3(3, -0.3, 2.5));
      final soil = projector.project(const BimVec3(3, -0.9, 2.5));
      _arrow(canvas, roof, beam, 'Roof (light)', const Color(0xFF22C55E));
      _arrow(canvas, beam, col, 'Beam → column', const Color(0xFFF97316));
      _arrow(canvas, col, found, 'Column', const Color(0xFFEA580C));
      _arrow(canvas, found, soil, 'Foundation', const Color(0xFF64748B));
      return;
    }
    if (earthbag) {
      final roof = projector.project(const BimVec3(2.75, 3.6, 2.25));
      final wall = projector.project(const BimVec3(2.75, 1.8, 2.25));
      final trench = projector.project(const BimVec3(2.75, -0.2, 2.25));
      final soil = projector.project(const BimVec3(2.75, -0.8, 2.25));
      _arrow(canvas, roof, wall, 'Roof load', const Color(0xFFEF4444));
      _arrow(canvas, wall, trench, 'Wall → trench', const Color(0xFFF97316));
      _arrow(canvas, trench, soil, 'Soil reaction', const Color(0xFF22C55E));
      return;
    }
    final roof = projector.project(const BimVec3(3, 4.2, 2));
    final wall = projector.project(const BimVec3(3, 2, 2));
    final found = projector.project(const BimVec3(3, -0.5, 2));
    final soil = projector.project(const BimVec3(3, -1.2, 2));
    _arrow(canvas, roof, wall, 'Roof load', const Color(0xFFEF4444));
    _arrow(canvas, wall, found, 'Wall load', const Color(0xFFF97316));
    _arrow(canvas, found, soil, 'Soil reaction', const Color(0xFF22C55E));
  }

  void _drawDrainageOverlay(
    Canvas canvas,
    Size size,
    BimProjector projector, {
    bool elevatedFlood = false,
    bool amphibious = false,
    bool geogrid = false,
    bool raisedPlinth = false,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF0EA5E9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    if (geogrid) {
      final rain = projector.project(const BimVec3(3, 8, 2));
      final blanket = projector.project(const BimVec3(6, 0.35, 5));
      final pipe = projector.project(const BimVec3(9, 0.45, 5));
      canvas.drawLine(rain, blanket, paint);
      _arrow(canvas, blanket, pipe, 'To pipe', const Color(0xFF0EA5E9));
    } else if (amphibious) {
      final flex = projector.project(const BimVec3(1.0, 1.2, 2.0));
      final post = projector.project(const BimVec3(1.1, 0.5, -0.2));
      _arrow(canvas, flex, post, 'Flex utilities', const Color(0xFF0EA5E9));
    } else if (elevatedFlood) {
      final ch = projector.project(const BimVec3(8, 0.08, 10));
      final out = projector.project(const BimVec3(12, 0.05, 10));
      final plat = projector.project(const BimVec3(4.2, 2.85, 2));
      canvas.drawLine(plat, ch, paint);
      _arrow(canvas, ch, out, 'Drain away', const Color(0xFF0EA5E9));
    } else if (raisedPlinth) {
      final phase = controller.floodPhase;
      final rain = projector.project(BimVec3(4, 4.5 + math.sin(phase) * 0.15, 1));
      final plinth = projector.project(const BimVec3(3.2, 1.55, 2.1));
      final drain = projector.project(const BimVec3(7.5, 0.08, 0));
      final out = projector.project(const BimVec3(11, 0.05, 0));
      canvas.drawLine(rain, plinth, paint);
      canvas.drawLine(plinth, drain, paint);
      _arrow(canvas, drain, out, 'Runoff away', const Color(0xFF0EA5E9));
    } else {
      final start = projector.project(const BimVec3(6, 0.3, 2));
      final end = projector.project(const BimVec3(9, 0.1, 6));
      canvas.drawLine(start, end, paint);
      _arrow(canvas, start, end, 'Runoff', const Color(0xFF0EA5E9));
    }
    final msg = geogrid
        ? 'Drainage pipes & weep holes — prevent hydrostatic pressure'
        : amphibious
            ? 'Flexible services — vertical travel during flotation'
            : elevatedFlood
                ? 'Surface drains — keep foundations dry'
                : raisedPlinth
                    ? 'DRAINAGE VIEW — Surface runoff diverted · Plinth toe protected · Reduced saturation'
                    : 'Drain water away from walls';
    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width * 0.05, size.height * 0.12));
  }

  void _drawFloodOverlay(Canvas canvas, Size size, BimProjector projector) {
    final phase = controller.floodPhase;
    final level = 1.55 + math.sin(phase * 0.7) * 0.2;
    final waterY = level;
    final a = projector.project(BimVec3(3.5, waterY, 0));
    final b = projector.project(BimVec3(13, waterY, 11));
    canvas.drawRect(
      Rect.fromPoints(a, b),
      Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.28),
    );

    if (controller.isAmphibious) {
      final lift = controller.amphibiousFloatLift;
      final house = projector.project(BimVec3(4.0, 0.75 + lift, 2.0));
      canvas.drawCircle(
        house,
        10,
        Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.95),
      );
      final tp = TextPainter(
        text: TextSpan(
          text:
              'FLOOD MODE — Water rises · Structure floats ${lift.toStringAsFixed(2)} m · Guide posts restrain drift',
          style: const TextStyle(
            color: Color(0xFF0369A1),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width - 24);
      tp.paint(canvas, Offset(12, size.height - 36));
      return;
    }

    final safeY = controller.isRaisedPlinth ? 1.85 : 2.85;
    final safe = projector.project(BimVec3(3.2, safeY, 2.1));
    canvas.drawCircle(
      safe,
      8,
      Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.9),
    );
    final floodMsg = controller.isRaisedPlinth
        ? 'FLOOD MODE — Ground inundated · Raised plinth & floor level remain dry · Safe occupancy'
        : 'FLOOD MODE — Ground storey inundated · Habitable platform remains dry · Open flow below';
    final tp = TextPainter(
      text: TextSpan(
        text: floodMsg,
        style: const TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawTimberSkeletonOverlay(Canvas canvas, Size size) {
    final msg =
        'TIMBER SKELETON — Columns · Beams · Bracing · Trusses · Continuous load path';
    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Color(0xFF92400E),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(size.width * 0.05, size.height * 0.12));
  }

  void _drawTimberBandOverlay(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text:
            'TIMBER BAND VIEW — Plinth · Mid-height · Lintel · Corner reinforcement',
        style: TextStyle(
          color: Color(0xFF92400E),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawConnectionOverlay(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text:
            'CONNECTION VIEW — Anchor bolts · Screws · Gussets · Shear & axial transfer',
        style: TextStyle(
          color: Color(0xFF475569),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawLandslideOverlay(Canvas canvas, Size size, BimProjector projector) {
    final slide = controller.landslideSlideOffset;
    final phase = controller.landslidePhase;
    final msg = slide > 0.5
        ? 'LANDSLIDE MODE — Unreinforced slope failing · Reinforced block stable'
        : 'LANDSLIDE MODE — Geogrids mobilize tensile resistance · Factor of safety increased';
    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
    if (slide > 0.2) {
      final fail = projector.project(BimVec3(3.2, 4.8 - slide, 3.5));
      canvas.drawCircle(
        fail,
        6,
        Paint()..color = const Color(0xFFDC2626).withValues(alpha: 0.8),
      );
    }
    final stable = projector.project(const BimVec3(6, 3.5, 5));
    canvas.drawCircle(
      stable,
      8,
      Paint()
        ..color = Color.lerp(
          const Color(0xFF22C55E),
          const Color(0xFF16A34A),
          (math.sin(phase) + 1) / 2,
        )!
        .withValues(alpha: 0.9),
    );
  }

  void _drawEarthPressureOverlay(Canvas canvas, Size size, BimProjector projector) {
    for (var i = 0; i < 5; i++) {
      final y = 0.8 + i * 1.1;
      final wall = projector.project(BimVec3(10.2, y, 5));
      final soil = projector.project(BimVec3(4, y, 5));
      _arrow(canvas, soil, wall, '', const Color(0xFFEF4444));
    }
    final tp = TextPainter(
      text: const TextSpan(
        text:
            'EARTH PRESSURE — Ka increases with depth · Geogrid tensile resistance',
        style: TextStyle(
          color: Color(0xFFEA580C),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawGroundwaterOverlay(Canvas canvas, Size size, BimProjector projector) {
    final gw = projector.project(const BimVec3(5, 1.1, 4));
    final pipe = projector.project(const BimVec3(9, 0.45, 5));
    final out = projector.project(const BimVec3(10.5, 0.2, 7));
    _arrow(canvas, gw, pipe, 'Seepage', const Color(0xFF0EA5E9));
    _arrow(canvas, pipe, out, 'Discharge', const Color(0xFF22C55E));
    final tp = TextPainter(
      text: const TextSpan(
        text: 'GROUNDWATER — Drainage lowers pore pressure · Weep holes relieve head',
        style: TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawThermalOverlay(
    Canvas canvas,
    Size size,
    BimProjector projector, {
    bool prefabricated = false,
    bool ratTrapBond = false,
    bool reinforcedAdobe = false,
    bool timberFrameLath = false,
  }) {
    final phase = controller.thermalPhase;
    final sun = projector.project(const BimVec3(8, 5, 0));
    final wall = ratTrapBond
        ? projector.project(const BimVec3(0.15, 2.2, 2.25))
        : timberFrameLath
            ? projector.project(const BimVec3(0.15, 1.8, 2.15))
            : projector.project(const BimVec3(0.2, 2.0, 2.25));
    final interior = projector.project(const BimVec3(3, 2.0, 2.25));
    final convWall = projector.project(const BimVec3(7.2, 2.2, 2.25));
    final heavyRoof = projector.project(const BimVec3(5.5, 3.8, 2.15));
    final heatPaint = Paint()
      ..color = const Color(0xFFEF4444)
          .withValues(alpha: 0.35 + 0.25 * math.sin(phase))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(sun, wall, heatPaint);
    if (ratTrapBond) {
      canvas.drawLine(sun, convWall, heatPaint);
      _arrow(canvas, wall, interior, 'RTB: less heat', const Color(0xFF22C55E));
      _arrow(canvas, convWall, interior, 'Solid wall: more', const Color(0xFFEF4444));
    } else if (timberFrameLath) {
      canvas.drawLine(sun, heavyRoof, heatPaint);
      _arrow(canvas, wall, interior, 'Lime plaster envelope', const Color(0xFF22C55E));
      _arrow(canvas, heavyRoof, interior, 'Heavy roof (ghost)', const Color(0xFFEF4444));
    } else {
      _arrow(canvas, wall, interior, 'Reduced heat', const Color(0xFF22C55E));
    }
    if (reinforcedAdobe) {
      final delay = projector.project(const BimVec3(3, 2.0, 2.2));
      _arrow(canvas, wall, delay, 'Thermal mass delay', const Color(0xFF22C55E));
    }
    final msg = timberFrameLath
        ? 'THERMAL VIEW — Lightweight timber frame · Lime plaster skin · Moderate thermal mass'
        : reinforcedAdobe
        ? 'THERMAL VIEW — Adobe thermal mass · Delayed heat transfer · Indoor comfort'
        : ratTrapBond
        ? 'THERMAL VIEW — Air cavities insulate · Lower heat transfer · Energy savings'
        : prefabricated
            ? 'THERMAL VIEW — Sandwich panels · Insulation core · Stable indoor temperature'
            : 'THERMAL VIEW — Fly ash masonry · Lower conductivity · Stable indoor temperature';
    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Color(0xFFEA580C),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawReinforcementOverlay(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text:
            'REINFORCEMENT VIEW — Vertical bars · Wire mesh · Plinth / lintel / roof bands',
        style: TextStyle(
          color: Color(0xFFEA580C),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawCavityWallOverlay(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text:
            'CAVITY WALL VIEW — Bricks on edge · Internal air pockets · Load paths through brick webs',
        style: TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawMaterialComparisonOverlay(Canvas canvas, Size size) {
    final phase = controller.materialComparisonPhase;
    final savings = 20 + 5 * math.sin(phase);
    final tp = TextPainter(
      text: TextSpan(
        text:
            'MATERIAL COMPARISON — RTB ~${savings.toStringAsFixed(0)}% fewer bricks · Reduced mortar · Lower weight',
        style: const TextStyle(
          color: Color(0xFF16A34A),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawModularAssemblyOverlay(Canvas canvas, Size size) {
    final t = controller.modularDisassembleFactor;
    final phaseLabel = t < 0.35
        ? 'ASSEMBLED — Factory modules installed on site'
        : t < 0.65
            ? 'DISASSEMBLY — Modules separate for sequencing review'
            : 'RE-ASSEMBLY — Crane installation sequence';
    final tp = TextPainter(
      text: TextSpan(
        text:
            'MODULAR ASSEMBLY — $phaseLabel · Factory → transport → crane set',
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawBlockAssemblyOverlay(Canvas canvas, Size size) {
    final t = controller.blockDisassembleFactor;
    final phaseLabel = t < 0.35
        ? 'ASSEMBLED — Interlocking blocks locked in place'
        : t < 0.65
            ? 'EXPLODED — Individual blocks for geometry review'
            : 'RE-ASSEMBLY — Interlock keys align courses';
    final tp = TextPainter(
      text: TextSpan(
        text:
            'BLOCK ASSEMBLY — $phaseLabel · Mechanical keys · Minimal mortar',
        style: const TextStyle(
          color: Color(0xFFD97706),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawBuoyancyOverlay(Canvas canvas, Size size, BimProjector projector) {
    final deck = projector.project(const BimVec3(4.0, 0.75, 2.0));
    final up = projector.project(const BimVec3(4.0, 2.1, 2.0));
    final down = projector.project(const BimVec3(4.0, -0.2, 2.0));
    _arrow(canvas, down, deck, 'Structure weight ↓', const Color(0xFFEF4444));
    _arrow(canvas, up, deck, 'Buoyant force ↑', const Color(0xFF22C55E));
    final tp = TextPainter(
      text: const TextSpan(
        text:
            'BUOYANCY — Fb = ρgVdisplaced · Equilibrium when buoyant force equals weight',
        style: TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 36));
  }

  void _drawHydraulicOverlay(Canvas canvas, Size size, BimProjector projector) {
    final river = projector.project(const BimVec3(1.5, 0, 5));
    final target = controller.isAmphibious
        ? projector.project(const BimVec3(2.0, 0.2, 2.0))
        : projector.project(const BimVec3(4.2, 0, 0));
    _arrow(
      canvas,
      river,
      target,
      controller.isAmphibious ? 'River / flotation' : 'Flow / scour',
      const Color(0xFF0EA5E9),
    );
    final msg = controller.isAmphibious
        ? 'HYDRAULIC VIEW — Guide posts · Buoyancy drums · Flexible utilities'
        : 'HYDRAULIC VIEW — Riprap · Scour zone · River proximity';
    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 28));
  }

  void _drawSeismicOverlay(Canvas canvas, Size size) {
    final c = controller;
    final msg = c.isConfinedBlock
        ? 'SEISMIC MODE — Tie-columns confine masonry · Continuous bands · Box action'
        : c.isCementBamboo
            ? 'SEISMIC MODE — Lightweight frame · Low inertia · Bracing engages'
            : c.isEarthbag
                ? 'SEISMIC MODE — Flexible mass · Barbed wire shear keys · Band continuity'
                : c.isElevatedFlood
                    ? 'SEISMIC MODE — Elevated platform · Column ductility · Light superstructure'
                    : c.isAmphibious
                        ? 'SEISMIC MODE — Light frame · Low mass · Flexible connections'
                        : c.isFlyAsh
                            ? 'SEISMIC MODE — RC bands · Box action · Masonry compression'
                            : c.isGeogrid
                                ? 'SEISMIC MODE — Reinforced soil mass · Geogrid tensile capacity'
                                : c.isLightGaugeSteel
                                    ? 'SEISMIC MODE — Light frame · Ductile CFS · Bracing engages'
                                    : c.isLohKaat
                                        ? 'SEISMIC MODE — Kaat bands tie walls · Ductile timber · Flexible response'
                                        : c.isPrefabricated
                                            ? 'SEISMIC MODE — Light panels · Low mass · Connector force redistribution'
                                            : c.isRaisedPlinth
                                                ? 'SEISMIC MODE — Masonry on plinth · DPC continuity · Moderate mass'
                                                : c.isRatTrapBond
                                                    ? 'SEISMIC MODE — RC bands · Cavity rebar option · Box action'
                                                    : c.isReinforcedAdobe
                                                        ? 'SEISMIC MODE — Traditional adobe fails · Reinforced system survives · Mesh + bands'
                                                        : c.isTimberFrameLath
                                                            ? 'SEISMIC MODE — Light timber frame flexes · Bracing engages · Unbraced frame fails · Plaster skin cracks · Structure survives'
                                                            : c.isAdvancedInterlocking
                                                                ? 'SEISMIC MODE — Conventional masonry cracks & separates · Interlocking + grout + bands survive · Box action'
                                                                : 'SEISMIC MODE — Ductile bands · Confined masonry · Load path continuity';
    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    tp.paint(canvas, Offset(12, size.height - 28));
  }

  void _arrow(Canvas canvas, Offset from, Offset to, String label, Color color) {
    final phase = (math.sin(controller.earthquakePhase * 1.1) + 1) / 2;
    final alpha = (0.55 + 0.45 * phase).clamp(0.0, 1.0);
    final c = color.withValues(alpha: alpha);
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = c
        ..strokeWidth = 2,
    );
    // Animated "flow" marker traveling along the arrow.
    final head = Offset(
      from.dx + (to.dx - from.dx) * phase,
      from.dy + (to.dy - from.dy) * phase,
    );
    canvas.drawCircle(head, 5, Paint()..color = c.withValues(alpha: (alpha * 0.85).clamp(0, 1)));
    canvas.drawCircle(to, 4, Paint()..color = c);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2 - 14));
  }

  void _drawHud(Canvas canvas, Size size) {
    final stage = controller.currentStage;
    if (stage == null) return;
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 12, 200, 36),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.85),
    );
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${stage.timelineLabel}\n',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          TextSpan(
            text: stage.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 180);
    tp.paint(canvas, const Offset(22, 18));
  }

  @override
  bool shouldRepaint(covariant _BimPainter old) => true;
}
