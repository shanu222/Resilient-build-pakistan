import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../bim/camera_controller_pro.dart';
import '../../bim_simulation/engine/bim_simulation_controller.dart';
import '../../bim_simulation/engine/bim_visualization_mode.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/hover_lift.dart';

/// Professional BIM viewer toolbar — fit, presets, view modes, hazards.
class BimToolbar extends StatelessWidget {
  const BimToolbar({
    super.key,
    required this.controller,
    required this.cameraPro,
    this.onAction,
    this.onHazardMode,
  });

  final BimSimulationController controller;
  final CameraControllerPro cameraPro;
  final void Function(String action)? onAction;
  final void Function(String hazard)? onHazardMode;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final showLabels = w >= 1100;
    final shortLabels = w >= 820 && w < 1100;
    final compact = w < 820;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final center = controller.sceneCenter;
        final radius = controller.sceneRadius;
        final mode = controller.viewMode;
        final cross = controller.crossSectionEnabled;
        final grid = controller.showStructuralGrid;

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 18,
          blurSigma: 20,
          opacity: 0.40,
          borderOpacity: 0.14,
          child: Row(
            children: [
              if (!compact) ...[
                _ToolbarTitle(short: shortLabels),
                const SizedBox(width: 12),
                const _Divider(),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Group(
                        label: 'Navigation',
                        color: AppColors.info,
                        compact: compact,
                        children: [
                          _ToolBtn(
                            icon: Icons.restart_alt,
                            label: showLabels ? 'Reset View' : (shortLabels ? 'Reset' : ''),
                            tooltip:
                                'Return camera to default engineering position.',
                            color: AppColors.info,
                            active: false,
                            onTap: () {
                              cameraPro.reset();
                              controller.fitCamera(viewportWidth: w);
                              onAction?.call('reset');
                            },
                          ),
                          _ToolBtn(
                            icon: Icons.fit_screen,
                            label: showLabels ? 'Zoom Fit' : (shortLabels ? 'Fit' : ''),
                            tooltip: 'Fit complete structure in viewport.',
                            color: AppColors.info,
                            active: false,
                            onTap: () {
                              controller.fitCamera(viewportWidth: w);
                              onAction?.call('fit');
                            },
                          ),
                          _ToolBtn(
                            icon: Icons.add,
                            label: showLabels ? 'Zoom In' : (shortLabels ? 'Zoom+' : ''),
                            tooltip: 'Zoom in to inspect details.',
                            color: AppColors.info,
                            active: false,
                            onTap: () {
                              cameraPro.zoomIn();
                              onAction?.call('zoom_in');
                            },
                          ),
                          _ToolBtn(
                            icon: Icons.remove,
                            label: showLabels ? 'Zoom Out' : (shortLabels ? 'Zoom-' : ''),
                            tooltip: 'Zoom out to see the full system.',
                            color: AppColors.info,
                            active: false,
                            onTap: () {
                              cameraPro.zoomOut();
                              onAction?.call('zoom_out');
                            },
                          ),
                        ],
                      ),
                      const _GroupDivider(),
                      _Group(
                        label: 'View modes',
                        color: const Color(0xFF8B5CF6),
                        compact: compact,
                        children: [
                          _ToolBtn(
                            icon: Icons.account_tree,
                            label: showLabels
                                ? 'Structural View'
                                : (shortLabels ? 'Structural' : ''),
                            tooltip:
                                'Show primary load-resisting structural elements only.',
                            color: const Color(0xFF8B5CF6),
                            active: mode == BimVisualizationMode.structural,
                            onTap: () {
                              controller.setViewMode(BimVisualizationMode.structural);
                              cameraPro.applyPreset(CameraPreset.structural, center, radius);
                            },
                          ),
                          _ToolBtn(
                            icon: Icons.unfold_more,
                            label: showLabels
                                ? 'Exploded View'
                                : (shortLabels ? 'Exploded' : ''),
                            tooltip:
                                'Separate structural layers for assembly understanding.',
                            color: const Color(0xFF8B5CF6),
                            active: mode == BimVisualizationMode.exploded,
                            onTap: () => controller.setViewMode(BimVisualizationMode.exploded),
                          ),
                          _ToolBtn(
                            icon: cross ? Icons.cut : Icons.cut_outlined,
                            label: showLabels
                                ? 'Section View'
                                : (shortLabels ? 'Section' : ''),
                            tooltip:
                                'Cut through structure to inspect internal elements.',
                            color: const Color(0xFF8B5CF6),
                            active: cross,
                            onTap: controller.toggleCrossSection,
                          ),
                          _ToolBtn(
                            icon: Icons.grid_on,
                            label: showLabels ? 'Grid View' : (shortLabels ? 'Grid' : ''),
                            tooltip: 'Show structural grid and reference lines.',
                            color: const Color(0xFF8B5CF6),
                            active: grid,
                            onTap: controller.toggleStructuralGrid,
                          ),
                        ],
                      ),
                      const _GroupDivider(),
                      _Group(
                        label: 'Engineering analysis',
                        color: AppColors.orange,
                        compact: compact,
                        children: [
                          _ToolBtn(
                            icon: Icons.link,
                            label: showLabels
                                ? 'Connections'
                                : (shortLabels ? 'Connections' : ''),
                            tooltip:
                                'Highlight structural connections and anchorage points.',
                            color: AppColors.orange,
                            active: mode == BimVisualizationMode.connection,
                            onTap: () => controller.setViewMode(BimVisualizationMode.connection),
                          ),
                          _ToolBtn(
                            icon: Icons.timeline,
                            label:
                                showLabels ? 'Load Path' : (shortLabels ? 'Load Path' : ''),
                            tooltip:
                                'Visualize load transfer from roof to foundation.',
                            color: AppColors.orange,
                            active: mode == BimVisualizationMode.loadTransfer,
                            onTap: () => controller.setViewMode(BimVisualizationMode.loadTransfer),
                          ),
                          _ToolBtn(
                            icon: Icons.layers,
                            label: showLabels ? 'Foundation' : (shortLabels ? 'Foundation' : ''),
                            tooltip: 'Focus on foundation elements and bearing system.',
                            color: AppColors.orange,
                            active: mode == BimVisualizationMode.foundation,
                            onTap: () => controller.setViewMode(BimVisualizationMode.foundation),
                          ),
                        ],
                      ),
                      const _GroupDivider(),
                      _Group(
                        label: 'Hazards',
                        color: AppColors.success,
                        compact: compact,
                        children: [
                          _ToolBtn(
                            icon: Icons.warning_amber,
                            label: showLabels
                                ? 'Earthquake Mode'
                                : (shortLabels ? 'Quake' : ''),
                            tooltip:
                                'Simulate earthquake effects and visualize response.',
                            color: AppColors.success,
                            active: mode == BimVisualizationMode.earthquake ||
                                mode == BimVisualizationMode.seismic,
                            onTap: () {
                              controller.setViewMode(BimVisualizationMode.earthquake);
                              onHazardMode?.call('earthquake');
                            },
                          ),
                          _ToolBtn(
                            icon: Icons.waves,
                            label: showLabels ? 'Flood Mode' : (shortLabels ? 'Flood' : ''),
                            tooltip:
                                'Simulate flood exposure and water interaction.',
                            color: AppColors.success,
                            active: mode == BimVisualizationMode.flood,
                            onTap: () {
                              controller.setViewMode(BimVisualizationMode.flood);
                              onHazardMode?.call('flood');
                            },
                          ),
                          _ToolBtn(
                            icon: Icons.air,
                            label: showLabels ? 'Wind Mode' : (shortLabels ? 'Wind' : ''),
                            tooltip:
                                'Simulate wind loads and uplift-sensitive components.',
                            color: AppColors.success,
                            active: mode == BimVisualizationMode.wind,
                            onTap: () {
                              controller.setViewMode(BimVisualizationMode.wind);
                              onHazardMode?.call('wind');
                            },
                          ),
                          _ToolBtn(
                            icon: Icons.landslide,
                            label: showLabels
                                ? 'Landslide Mode'
                                : (shortLabels ? 'Slide' : ''),
                            tooltip:
                                'Simulate slope/earth pressure effects (where applicable).',
                            color: AppColors.success,
                            active: mode == BimVisualizationMode.landslide,
                            onTap: () {
                              controller.setViewMode(BimVisualizationMode.landslide);
                              onHazardMode?.call('landslide');
                            },
                          ),
                        ],
                      ),
                      const _GroupDivider(),
                      _Group(
                        label: 'Capture',
                        color: AppColors.hazard,
                        compact: compact,
                        children: [
                          _ToolBtn(
                            icon: Icons.camera_alt_outlined,
                            label: showLabels ? 'Screenshot' : (shortLabels ? 'Shot' : ''),
                            tooltip: 'Capture a screenshot for reports and inspection records.',
                            color: AppColors.hazard,
                            active: false,
                            onTap: () => onAction?.call('screenshot'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white24,
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

class _ToolbarTitle extends StatelessWidget {
  const _ToolbarTitle({required this.short});
  final bool short;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Digital Twin Engineering Workspace',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            height: 1.1,
          ),
        ),
        if (!short)
          Text(
            'Interactive Construction Visualization & Structural Analysis',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              height: 1.15,
            ),
          ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.label,
    required this.color,
    required this.children,
    required this.compact,
  });

  final String label;
  final Color color;
  final List<Widget> children;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!compact) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        ...children,
      ],
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showLabel = label.trim().isNotEmpty;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: HoverLift(
        enabled: true,
        scale: 1.05,
        lift: 5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? AppColors.orange
                  : Colors.white.withValues(alpha: 0.14),
              width: active ? 2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
            color: Colors.white.withValues(alpha: active ? 0.12 : 0.06),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: showLabel ? 12 : 10,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 20),
                  if (showLabel) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
