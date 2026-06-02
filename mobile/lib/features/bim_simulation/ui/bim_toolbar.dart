import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../bim/camera_controller_pro.dart';
import '../../bim_simulation/engine/bim_simulation_controller.dart';
import '../../bim_simulation/engine/bim_visualization_mode.dart';

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
    final center = controller.sceneCenter;
    final radius = controller.sceneRadius;

    return Material(
      color: AppColors.navy.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            _Btn(Icons.fit_screen, 'Fit', () {
              controller.fitCamera(viewportWidth: w);
              onAction?.call('fit');
            }),
            _Btn(Icons.restart_alt, 'Reset', () {
              cameraPro.reset();
              controller.fitCamera(viewportWidth: w);
              onAction?.call('reset');
            }),
            _Btn(Icons.add, 'Zoom+', () {
              cameraPro.zoomIn();
              onAction?.call('zoom_in');
            }),
            _Btn(Icons.remove, 'Zoom-', () {
              cameraPro.zoomOut();
              onAction?.call('zoom_out');
            }),
            const _Divider(),
            _Btn(Icons.vertical_align_top, 'Top', () {
              cameraPro.applyPreset(CameraPreset.top, center, radius);
            }),
            _Btn(Icons.view_agenda, 'Front', () {
              cameraPro.applyPreset(CameraPreset.front, center, radius);
            }),
            _Btn(Icons.view_week, 'Side', () {
              cameraPro.applyPreset(CameraPreset.side, center, radius);
            }),
            _Btn(Icons.view_in_ar, 'Iso', () {
              cameraPro.applyPreset(CameraPreset.isometric, center, radius);
            }),
            _Btn(Icons.account_tree, 'Struct', () {
              controller.setViewMode(BimVisualizationMode.structural);
              cameraPro.applyPreset(CameraPreset.structural, center, radius);
            }),
            const _Divider(),
            _Btn(Icons.unfold_more, 'Explode', () {
              controller.setViewMode(BimVisualizationMode.exploded);
            }),
            _Btn(Icons.crop, 'Section', controller.toggleCrossSection),
            _Btn(Icons.timeline, 'Load', () {
              controller.setViewMode(BimVisualizationMode.loadTransfer);
            }),
            _Btn(Icons.link, 'Conn', () {
              controller.setViewMode(BimVisualizationMode.connection);
            }),
            _Btn(Icons.grid_on, 'Grid', controller.toggleStructuralGrid),
            _Btn(Icons.layers, 'Foundation', () {
              controller.setViewMode(BimVisualizationMode.foundation);
            }),
            const _Divider(),
            _Btn(Icons.warning_amber, 'Quake', () {
              controller.setViewMode(BimVisualizationMode.earthquake);
              onHazardMode?.call('earthquake');
            }),
            _Btn(Icons.waves, 'Flood', () {
              controller.setViewMode(BimVisualizationMode.flood);
              onHazardMode?.call('flood');
            }),
            _Btn(Icons.air, 'Wind', () {
              controller.setViewMode(BimVisualizationMode.wind);
              onHazardMode?.call('wind');
            }),
            _Btn(Icons.landslide, 'Slide', () {
              controller.setViewMode(BimVisualizationMode.landslide);
              onHazardMode?.call('landslide');
            }),
            _Btn(Icons.camera_alt_outlined, 'Shot', () {
              onAction?.call('screenshot');
            }),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn(this.icon, this.tip, this.onTap);

  final IconData icon;
  final String tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
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
