import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../core/theme/app_colors.dart';
import 'construction_stage_controller.dart';

/// GLB construction viewer — orbit, zoom, pan; stage mesh swaps on timeline.
class DigitalTwinViewport extends StatelessWidget {
  const DigitalTwinViewport({
    super.key,
    required this.controller,
    this.hazardOverlay,
  });

  final ConstructionStageController controller;
  final Widget? hazardOverlay;

  @override
  Widget build(BuildContext context) {
    final stage = controller.currentStage;
    final glb = controller.currentGlbPath;
    final hazard = controller.hazardMode;

    return Stack(
      fit: StackFit.expand,
      children: [
        ModelViewer(
          key: ValueKey(glb),
          src: glb,
          alt: stage?.title ?? 'Construction',
          ar: false,
          autoRotate: !controller.isPlaying,
          cameraControls: true,
          backgroundColor: const Color(0xFFE2E8F0),
          loading: Loading.eager,
          relatedCss: '''
            .userInputWrapper { display: none; }
          ''',
        ),
        if (hazard != 'none')
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _HazardBanner(mode: hazard),
          ),
        if (hazardOverlay != null) hazardOverlay!,
        Positioned(
          top: 12,
          left: 12,
          child: _StageBadge(
            label: stage?.timelineLabel ?? '',
            title: stage?.title ?? '',
          ),
        ),
      ],
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HazardBanner extends StatelessWidget {
  const _HazardBanner({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final (title, color) = switch (mode) {
      'earthquake' => ('EARTHQUAKE SIMULATION — Frame ductility · Band continuity', const Color(0xFFDC2626)),
      'flood' => ('FLOOD SIMULATION — Water level rise · Elevated / buoyant response', const Color(0xFF0369A1)),
      'wind' => ('WIND SIMULATION — Uplift · Wall ties · Roof anchorage', const Color(0xFF7C3AED)),
      'landslide' => ('LANDSLIDE SIMULATION — Geogrid tension · Slope stability', const Color(0xFFEA580C)),
      _ => ('HAZARD VIEW', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
