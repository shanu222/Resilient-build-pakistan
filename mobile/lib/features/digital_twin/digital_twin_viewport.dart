import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/web_asset_url.dart';
import 'construction_stage_controller.dart';
import 'widgets/hazard_simulation_overlay.dart';

/// GLB construction viewer — hazard overlays + stage HUD.
///
/// Important: keep the `ModelViewer` instance stable to preserve user interaction
/// state as much as the underlying web component allows. Avoid `AnimatedSwitcher`
/// and widget keys that force disposal/recreation.
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final stage = controller.currentStage;
        final glb = controller.currentGlbPath;
        return Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: ModelViewer(
                // Intentionally no key: avoid widget disposal which resets state.
                src: webAssetUrl(glb),
                alt: stage?.title ?? 'Construction model',
                ar: false,
                autoRotate: !controller.isPlaying,
                cameraControls: true,
                backgroundColor: AppColors.viewerBg,
                loading: Loading.eager,
                relatedCss: '''
                  .userInputWrapper { display: none; }
                ''',
              ),
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
      },
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
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
