import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/utils/web_asset_url.dart';

/// BIM-style 3D viewer (GLB/GLTF). Shows engineering placeholder if asset is not bundled yet.
class ModelViewerWidget extends StatelessWidget {
  const ModelViewerWidget({
    super.key,
    required this.modelPath,
    required this.stageName,
    this.explodedView = false,
    this.crossSection = false,
    this.viewMode = 'structural',
    this.onComponentTap,
  });

  final String modelPath;
  final String stageName;
  final bool explodedView;
  final bool crossSection;
  final String viewMode;
  final void Function(String componentId)? onComponentTap;

  static const _components = [
    ('footing', 'Footing'),
    ('foundation', 'Foundation'),
    ('plinth', 'Plinth'),
    ('wall', 'Wall'),
    ('column', 'Column'),
    ('beam', 'Beam'),
    ('lintel_band', 'Lintel'),
    ('roof_joint', 'Roof'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ModelViewerOrPlaceholder(path: modelPath, stageName: stageName),
              if (explodedView || crossSection)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _badge(
                    context,
                    [
                      if (explodedView) 'Exploded',
                      if (crossSection) 'Cross-Section',
                      viewMode,
                    ].join(' · '),
                  ),
                ),
            ],
          ),
        ),
        if (onComponentTap != null)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: _components.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(c.$2, style: const TextStyle(fontSize: 11)),
                    onPressed: () => onComponentTap!(c.$1),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _badge(BuildContext context, String text) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: tokens.textOnHero, fontSize: 11),
      ),
    );
  }
}

class _ModelViewerOrPlaceholder extends StatelessWidget {
  const _ModelViewerOrPlaceholder({required this.path, required this.stageName});

  final String path;
  final String stageName;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ModelViewer(
          src: webAssetUrl(path),
          alt: stageName,
          ar: false,
          autoRotate: true,
          cameraControls: true,
          backgroundColor: const Color(0xFFE2E8F0),
          loading: Loading.lazy,
          relatedCss: '''
            .userInputWrapper { display: none; }
          ''',
          relatedJs: '''
            document.addEventListener('DOMContentLoaded', function() {
              const mv = document.querySelector('model-viewer');
              if (mv) {
                mv.addEventListener('error', function() {
                  console.log('Model load fallback');
                });
              }
            });
          ''',
          onWebViewCreated: (_) {},
        ),
        IgnorePointer(
          child: Container(
            color: const Color(0x33E2E8F0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.view_in_ar, size: 72, color: AppColors.navy.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  stageName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
