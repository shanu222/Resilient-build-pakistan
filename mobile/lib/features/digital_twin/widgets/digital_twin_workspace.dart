import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:math' as math;

import '../../../core/theme/app_page_transitions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../bim_simulation/engine/bim_simulation_controller.dart';
import '../../bim_simulation/engine/rendering/bim_viewport.dart';
import '../construction_stage_controller.dart';
import '../digital_twin_viewport.dart';
import '../domain/bim_component_registry.dart';
import '../domain/digital_twin_manifest.dart';
import 'hazard_simulation_overlay.dart';

export 'hazard_simulation_overlay.dart' show HazardSimulationOverlay;

enum TwinViewLayer {
  glb,
  structural,
  exploded,
  crossSection,
  loadTransfer,
  connections,
  grid,
  blockAssembly,
}

/// Production Digital Twin workspace — L: engineering · C: BIM · R: controls · Bottom: progress.
class DigitalTwinWorkspace extends StatefulWidget {
  const DigitalTwinWorkspace({
    super.key,
    required this.manifest,
    required this.stages,
    required this.viewLayer,
    required this.onViewLayerChanged,
    required this.showProcedural,
    this.registry,
    this.bim,
    this.selectedComponent,
    this.onComponentSelected,
    required this.onPlayChanged,
    required this.onSpeedChanged,
    required this.onHazardSelected,
    this.hazardAnimPhase = 0,
  });

  final DigitalTwinManifest manifest;
  final ConstructionStageController stages;
  final TwinViewLayer viewLayer;
  final ValueChanged<TwinViewLayer> onViewLayerChanged;
  final bool showProcedural;
  final BimComponentRegistry? registry;
  final BimSimulationController? bim;
  final String? selectedComponent;
  final ValueChanged<String>? onComponentSelected;
  final void Function(bool playing) onPlayChanged;
  final void Function(double speed) onSpeedChanged;
  final void Function(String mode) onHazardSelected;
  final double hazardAnimPhase;

  bool get hasProcedural => bim != null;

  @override
  State<DigitalTwinWorkspace> createState() => _DigitalTwinWorkspaceState();
}

class _DigitalTwinWorkspaceState extends State<DigitalTwinWorkspace> {
  bool _engineeringOpen = false; // used for mobile sheet
  bool _workspaceOpen = false; // desktop/tablet engineering workspace drawer
  bool _timelineOpen = false; // desktop/tablet timeline drawer
  bool _inspectorOpen = false; // desktop/tablet inspector drawer
  bool _componentsOpen = false; // desktop/tablet components drawer

  static const double _desktopDrawerWidth = 390;
  static const double _tabletDrawerWidth = 340;
  double _drawerWidth = _desktopDrawerWidth;

  @override
  Widget build(BuildContext context) {
    final stage = widget.stages.currentStage;
    final total = widget.manifest.stages.length;
    final stageNum = widget.stages.stageIndex + 1;
    final progress = total == 0
        ? 0.0
        : (widget.stages.stageIndex + widget.stages.stageProgress) / total;
    final hazard = widget.stages.hazardMode;
    final hazardDetail = widget.manifest.hazardSimulations[hazard]?['explanation'] as String?;

    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final isDesktop = !(isMobile || isTablet);
    final tokens = context.appTokens;
    final drawerTargetWidth = isDesktop ? _desktopDrawerWidth : _tabletDrawerWidth;
    _drawerWidth = _drawerWidth.clamp(
      280,
      math.max(280, MediaQuery.sizeOf(context).width * 0.55),
    );
    if (_drawerWidth < drawerTargetWidth - 10 || _drawerWidth > drawerTargetWidth + 160) {
      // Keep width reasonable when switching breakpoints.
      _drawerWidth = drawerTargetWidth;
    }

    // Viewer focus: panels never consume permanent space.
    // Use drawers/sheets instead of side columns.

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fullscreen viewer is always dominant.
          RepaintBoundary(
            child: _viewer(widget.showProcedural, hazard, hazardDetail),
          ),

          // Header overlays viewer (doesn't shrink it).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _CompactHeader(
              manifest: widget.manifest,
              stage: stage,
              stageNum: stageNum,
              total: total,
              compact: !isMobile,
            ),
          ),

          // Floating HUD / progress (overlay, not below viewer).
          Positioned(
            left: 12,
            bottom: 12,
            child: _FloatingProgressHud(
              stage: stage,
              progress: progress,
              stageNum: stageNum,
              total: total,
              compact: isMobile,
            ),
          ),

          // Floating playback dock (bidirectional scrubber + transport + speed).
          Positioned(
            left: 12,
            right: 12,
            bottom: isMobile ? 18 : 16,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _PlaybackDock(
                stages: widget.stages,
                onPlayChanged: widget.onPlayChanged,
                onSpeedChanged: widget.onSpeedChanged,
                onPrev: widget.stages.previousStage,
                onNext: widget.stages.nextStage,
                onRestart: widget.stages.restart,
                onStop: widget.stages.stop,
              ),
            ),
          ),

          // Floating analysis summary (top-right).
          Positioned(
            top: isMobile ? 118 : 110,
            right: 12,
            child: _AnalysisSummaryCard(
              tokens: tokens,
              hazardModes: widget.manifest.hazardSimulations.keys.toList(),
            ),
          ),

          // Floating action dock (professional workspace dock).
          Positioned(
            top: isMobile ? 72 : 82,
            right: 12,
            child: isMobile
                ? _MobileFabDock(
                    onAction: (action) => _openMobileAction(action),
                  )
                : _DesktopDock(
                    onAction: (action) => setState(() => _openDesktopAction(action)),
                  ),
          ),

          // Desktop/tablet drawers.
          if (!isMobile) ...[
            _RightDrawer(
              open: _workspaceOpen,
              width: _drawerWidth,
              onClose: () => setState(() => _workspaceOpen = false),
              onResize: (w) => setState(() => _drawerWidth = w),
              title: 'Engineering workspace',
              child: _EngineeringWorkspace(
                tokens: tokens,
                manifest: widget.manifest,
                stages: widget.stages,
                stage: stage,
                progress: progress,
                selectedComponent: widget.selectedComponent,
                onComponentSelected: widget.onComponentSelected,
              ),
            ),
            _RightDrawer(
              open: _timelineOpen,
              width: isDesktop ? _desktopDrawerWidth : _tabletDrawerWidth,
              onClose: () => setState(() => _timelineOpen = false),
              title: 'Timeline',
              child: _TimelinePanel(
                tokens: tokens,
                manifest: widget.manifest,
                stages: widget.stages,
              ),
            ),
            _RightDrawer(
              open: _inspectorOpen,
              width: isDesktop ? _desktopDrawerWidth : _tabletDrawerWidth,
              onClose: () => setState(() => _inspectorOpen = false),
              title: 'Inspector',
              child: _InspectorPanel(
                tokens: tokens,
                manifest: widget.manifest,
                stage: stage,
                hazardMode: widget.stages.hazardMode,
                selectedComponent: widget.selectedComponent,
                registry: widget.registry,
              ),
            ),
            _RightDrawer(
              open: _componentsOpen,
              width: isDesktop ? _desktopDrawerWidth : _tabletDrawerWidth,
              onClose: () => setState(() => _componentsOpen = false),
              title: 'Components',
              child: _ComponentTreePanel(
                tokens: tokens,
                manifest: widget.manifest,
                registry: widget.registry,
                selectedComponent: widget.selectedComponent,
                onComponentSelected: widget.onComponentSelected,
              ),
            ),
          ],

          // Mobile engineering bottom sheet (existing behavior preserved).
          if (isMobile && _engineeringOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _engineeringOpen = false),
                child: ColoredBox(
                  color: context.appTokens.overlayScrim,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.55,
                      minChildSize: 0.35,
                      maxChildSize: 0.9,
                      builder: (_, scroll) => Material(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: _EngineeringPanel(
                                manifest: widget.manifest,
                                stage: stage,
                                selectedComponent: widget.selectedComponent,
                                onComponentSelected: widget.onComponentSelected,
                                scrollController: scroll,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _viewer(bool procedural, String hazard, String? hazardDetail) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.viewerBg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          procedural && widget.bim != null
              ? BimViewport(controller: widget.bim!)
              : DigitalTwinViewport(
                  controller: widget.stages,
                  hazardOverlay: HazardSimulationOverlay(
                    mode: hazard,
                    explanation: hazardDetail,
                    progress: widget.hazardAnimPhase,
                  ),
                ),
        ],
      ),
    );
  }

  void _showMobileControls(BuildContext context) {
    final total = widget.manifest.stages.length;
    final progress = total == 0
        ? 0.0
        : (widget.stages.stageIndex + widget.stages.stageProgress) / total;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.5,
          child: _ControlPanel(
            manifest: widget.manifest,
            stages: widget.stages,
            viewLayer: widget.viewLayer,
            onViewLayerChanged: widget.onViewLayerChanged,
            hasProcedural: widget.hasProcedural,
            onPlayChanged: widget.onPlayChanged,
            onSpeedChanged: widget.onSpeedChanged,
            onHazardSelected: widget.onHazardSelected,
            progress: progress,
          ),
        ),
      ),
    );
  }

  void _openDesktopAction(_WorkspaceAction action) {
    // Only one drawer open at a time (professional workspace behavior).
    _workspaceOpen = false;
    _timelineOpen = false;
    _inspectorOpen = false;
    _componentsOpen = false;

    switch (action) {
      case _WorkspaceAction.analysis:
        _workspaceOpen = true;
      case _WorkspaceAction.timeline:
        _timelineOpen = true;
      case _WorkspaceAction.inspector:
        _inspectorOpen = true;
      case _WorkspaceAction.components:
        _componentsOpen = true;
      case _WorkspaceAction.documentation:
        _workspaceOpen = true;
      case _WorkspaceAction.measurements:
        _workspaceOpen = true;
      case _WorkspaceAction.simulation:
        _workspaceOpen = true;
    }
  }

  void _openMobileAction(_WorkspaceAction action) {
    switch (action) {
      case _WorkspaceAction.timeline:
        _showTimelineSheet(context);
      case _WorkspaceAction.inspector:
        _showInspectorSheet(context);
      case _WorkspaceAction.components:
        _engineeringOpen = false;
        _showComponentsSheet(context);
      default:
        _engineeringOpen = true;
    }
  }

  void _showTimelineSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.72,
        child: _TimelinePanel(
          tokens: ctx.appTokens,
          manifest: widget.manifest,
          stages: widget.stages,
        ),
      ),
    );
  }

  void _showInspectorSheet(BuildContext context) {
    final stage = widget.stages.currentStage;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.55,
        child: _InspectorPanel(
          tokens: ctx.appTokens,
          manifest: widget.manifest,
          stage: stage,
          hazardMode: widget.stages.hazardMode,
          selectedComponent: widget.selectedComponent,
          registry: widget.registry,
        ),
      ),
    );
  }

  void _showComponentsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.72,
        child: _ComponentTreePanel(
          tokens: ctx.appTokens,
          manifest: widget.manifest,
          registry: widget.registry,
          selectedComponent: widget.selectedComponent,
          onComponentSelected: (id) {
            widget.onComponentSelected?.call(id);
            Navigator.maybePop(ctx);
          },
        ),
      ),
    );
  }
}

enum _WorkspaceAction {
  analysis,
  timeline,
  simulation,
  documentation,
  components,
  inspector,
  measurements,
}

class _PlaybackDock extends StatelessWidget {
  const _PlaybackDock({
    required this.stages,
    required this.onPlayChanged,
    required this.onSpeedChanged,
    required this.onPrev,
    required this.onNext,
    required this.onRestart,
    required this.onStop,
  });

  final ConstructionStageController stages;
  final void Function(bool playing) onPlayChanged;
  final void Function(double speed) onSpeedChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final tokens = context.appTokens;
    return AnimatedBuilder(
      animation: stages,
      builder: (context, _) {
        final total = stages.manifest.stages.length;
        final stageNum = stages.stageIndex + 1;
        final value = stages.progressNormalized;
        final speed = stages.playbackSpeed;
        final hazard = stages.hazardMode;
        final labelStyle = TextStyle(
          color: tokens.textOnGlassMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        );
        final iconColor = tokens.textOnGlass;

        return Material(
          color: tokens.playbackSurface,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('Stage $stageNum / $total', style: labelStyle),
                    const Spacer(),
                    Text(
                      '${(value * 100).round()}%  ·  ${speed.toStringAsFixed(speed == speed.roundToDouble() ? 0 : 2)}×  ·  ${hazard == "none" ? "Normal" : hazard}',
                      style: labelStyle.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('1', style: TextStyle(color: tokens.textOnGlassMuted, fontSize: 10)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: AppColors.orange,
                          inactiveTrackColor: tokens.textOnGlass.withValues(alpha: 0.18),
                          thumbColor: AppColors.orange,
                        ),
                        child: Slider(
                          value: value.clamp(0, 1),
                          onChanged: stages.scrub,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$total', style: TextStyle(color: tokens.textOnGlassMuted, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Previous stage',
                      onPressed: stages.stageIndex > 0 ? onPrev : null,
                      icon: Icon(Icons.skip_previous, color: iconColor),
                    ),
                    IconButton(
                      tooltip: stages.isPlaying ? 'Pause' : 'Play',
                      onPressed: () => onPlayChanged(!stages.isPlaying),
                      icon: Icon(
                        stages.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: AppColors.orange,
                        size: isMobile ? 40 : 44,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next stage',
                      onPressed: stages.stageIndex < total - 1 ? onNext : null,
                      icon: Icon(Icons.skip_next, color: iconColor),
                    ),
                    const SizedBox(width: 4),
                    if (!isMobile) ...[
                      IconButton(
                        tooltip: 'Restart',
                        onPressed: onRestart,
                        icon: Icon(Icons.restart_alt, color: iconColor),
                      ),
                      IconButton(
                        tooltip: 'Stop',
                        onPressed: onStop,
                        icon: Icon(Icons.stop_circle_outlined, color: iconColor),
                      ),
                    ],
                    const SizedBox(width: 6),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        dropdownColor: tokens.primary,
                        value: speed.clamp(0.25, 4.0),
                        style: TextStyle(
                          color: tokens.textOnGlass,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        iconEnabledColor: tokens.textOnGlassMuted,
                        items: const [
                          DropdownMenuItem(value: 0.25, child: Text('0.25×')),
                          DropdownMenuItem(value: 0.5, child: Text('0.5×')),
                          DropdownMenuItem(value: 1.0, child: Text('1×')),
                          DropdownMenuItem(value: 2.0, child: Text('2×')),
                          DropdownMenuItem(value: 4.0, child: Text('4×')),
                        ],
                        onChanged: (s) {
                          if (s == null) return;
                          stages.setPlaybackSpeed(s);
                          onSpeedChanged(s);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingProgressHud extends StatelessWidget {
  const _FloatingProgressHud({
    required this.stage,
    required this.progress,
    required this.stageNum,
    required this.total,
    required this.compact,
  });

  final DigitalTwinStage? stage;
  final double progress;
  final int stageNum;
  final int total;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Material(
      color: tokens.playbackSurface,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stage?.timelineLabel ?? 'Stage $stageNum of $total',
                style: TextStyle(
                  color: tokens.textOnGlassMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                stage?.title ?? 'Digital Twin',
                style: TextStyle(
                  color: tokens.textOnGlass,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 4,
                  backgroundColor: tokens.textOnGlass.withValues(alpha: 0.14),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              ),
              if (!compact && stage != null) ...[
                const SizedBox(height: 8),
                Text(
                  stage!.constructionActivity,
                  style: TextStyle(
                    color: tokens.textOnGlassMuted,
                    fontSize: 11,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopDock extends StatelessWidget {
  const _DesktopDock({required this.onAction});

  final void Function(_WorkspaceAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Material(
      color: tokens.playbackSurface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DockBtn(
              icon: Icons.analytics_outlined,
              label: 'Analysis',
              tooltip: 'Engineering overview & resilience analysis',
              onTap: () => onAction(_WorkspaceAction.analysis),
            ),
            const SizedBox(height: 8),
            _DockBtn(
              icon: Icons.calendar_month_outlined,
              label: 'Timeline',
              tooltip: 'Construction stages timeline',
              onTap: () => onAction(_WorkspaceAction.timeline),
            ),
            const SizedBox(height: 8),
            _DockBtn(
              icon: Icons.warning_amber_outlined,
              label: 'Simulation',
              tooltip: 'Hazard modes and simulation context',
              onTap: () => onAction(_WorkspaceAction.simulation),
            ),
            const SizedBox(height: 8),
            _DockBtn(
              icon: Icons.account_tree_outlined,
              label: 'Components',
              tooltip: 'Component tree & selection',
              onTap: () => onAction(_WorkspaceAction.components),
            ),
            const SizedBox(height: 8),
            _DockBtn(
              icon: Icons.search_outlined,
              label: 'Inspector',
              tooltip: 'Inspect selected component and stage context',
              onTap: () => onAction(_WorkspaceAction.inspector),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileFabDock extends StatefulWidget {
  const _MobileFabDock({required this.onAction});

  final void Function(_WorkspaceAction action) onAction;

  @override
  State<_MobileFabDock> createState() => _MobileFabDockState();
}

class _MobileFabDockState extends State<_MobileFabDock> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: _open
              ? Material(
                  key: const ValueKey('menu'),
                  color: AppColors.navy.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _MiniAction(
                          icon: Icons.analytics_outlined,
                          label: 'Analysis',
                          onTap: () {
                            setState(() => _open = false);
                            widget.onAction(_WorkspaceAction.analysis);
                          },
                        ),
                        _MiniAction(
                          icon: Icons.calendar_month_outlined,
                          label: 'Timeline',
                          onTap: () {
                            setState(() => _open = false);
                            widget.onAction(_WorkspaceAction.timeline);
                          },
                        ),
                        _MiniAction(
                          icon: Icons.account_tree_outlined,
                          label: 'Components',
                          onTap: () {
                            setState(() => _open = false);
                            widget.onAction(_WorkspaceAction.components);
                          },
                        ),
                        _MiniAction(
                          icon: Icons.search_outlined,
                          label: 'Inspector',
                          onTap: () {
                            setState(() => _open = false);
                            widget.onAction(_WorkspaceAction.inspector);
                          },
                        ),
                        _MiniAction(
                          icon: Icons.tune,
                          label: 'Controls',
                          onTap: () {
                            setState(() => _open = false);
                            widget.onAction(_WorkspaceAction.simulation);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'dt_fab',
          backgroundColor: AppColors.orange,
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close : Icons.menu),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: tokens.textOnGlass),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: tokens.textOnGlass,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockBtn extends StatelessWidget {
  const _DockBtn({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 132,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: tokens.textOnGlass.withValues(alpha: 0.06),
            border: Border.all(color: tokens.glassBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: tokens.textOnGlass,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightDrawer extends StatelessWidget {
  const _RightDrawer({
    required this.open,
    required this.width,
    required this.onClose,
    required this.child,
    this.title,
    this.onResize,
  });

  final bool open;
  final double width;
  final VoidCallback onClose;
  final Widget child;
  final String? title;
  final ValueChanged<double>? onResize;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        if (open)
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: ColoredBox(color: context.appTokens.overlayScrim),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          top: top + 58,
          bottom: 12,
          right: open ? 12 : -width - 24,
          width: width,
          child: Material(
            elevation: 8,
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _DrawerHeader(title: title ?? 'Engineering', onClose: onClose),
                const Divider(height: 1),
                Expanded(
                  child: Stack(
                    children: [
                      child,
                      if (onResize != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _ResizeHandle(onResize: onResize!),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({required this.onResize});
  final ValueChanged<double> onResize;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  double? _startX;
  double? _startW;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onHorizontalDragStart: (d) {
          _startX = d.globalPosition.dx;
          _startW = (context.findRenderObject() as RenderBox?)?.size.width;
        },
        onHorizontalDragUpdate: (d) {
          if (_startX == null) return;
          // Dragging left increases width.
          final delta = _startX! - d.globalPosition.dx;
          final base = _startW ?? 380;
          widget.onResize((base + delta).clamp(280, MediaQuery.sizeOf(context).width * 0.65));
        },
        child: Container(
          width: 10,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 3,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisSummaryCard extends StatelessWidget {
  const _AnalysisSummaryCard({
    required this.tokens,
    required this.hazardModes,
  });

  final AppThemeTokens tokens;
  final List<String> hazardModes;

  @override
  Widget build(BuildContext context) {
    final supported = hazardModes.where((h) => h != 'none').toList();
    return Material(
      color: tokens.glassBackground.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tokens.glassBorder.withValues(alpha: 0.65)),
          boxShadow: [
            BoxShadow(
              color: context.appTokens.overlayScrim.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis summary',
              style: TextStyle(
                color: tokens.textOnPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _kv(tokens, 'Overall', 'No data'),
            _kv(tokens, 'Earthquake', supported.contains('earthquake') ? 'Available' : '—'),
            _kv(tokens, 'Flood', supported.contains('flood') ? 'Available' : '—'),
            _kv(tokens, 'Wind', supported.contains('wind') ? 'Available' : '—'),
            _kv(tokens, 'Landslide', supported.contains('landslide') ? 'Available' : '—'),
            _kv(tokens, 'Thermal', 'No data'),
          ],
        ),
      ),
    );
  }

  Widget _kv(AppThemeTokens tokens, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: TextStyle(color: tokens.textOnPrimary.withValues(alpha: 0.75), fontSize: 11)),
          ),
          Text(v, style: TextStyle(color: tokens.textOnPrimary, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({
    required this.tokens,
    required this.manifest,
    required this.stages,
  });

  final AppThemeTokens tokens;
  final DigitalTwinManifest manifest;
  final ConstructionStageController stages;

  @override
  Widget build(BuildContext context) {
    if (manifest.stages.isEmpty) {
      return _EmptyPanel(
        title: 'No timeline available',
        body: 'Construction sequence unavailable for this model.',
        tokens: tokens,
        icon: Icons.calendar_month_outlined,
      );
    }
    return AnimatedBuilder(
      animation: stages,
      builder: (context, _) {
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: manifest.stages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final s = manifest.stages[i];
            final active = i == stages.stageIndex;
            return InkWell(
              onTap: () => stages.setStage(i),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: active
                      ? tokens.primary.withValues(alpha: 0.10)
                      : tokens.card.withValues(alpha: 0.85),
                  border: Border.all(
                    color: active
                        ? AppColors.orange.withValues(alpha: 0.9)
                        : tokens.border.withValues(alpha: 0.7),
                    width: active ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.orange.withValues(alpha: 0.9)
                            : tokens.chipBackground,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: active ? tokens.textOnPrimary : tokens.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.constructionActivity,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 11,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (active)
                      const Icon(Icons.play_arrow, color: AppColors.orange),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InspectorPanel extends StatelessWidget {
  const _InspectorPanel({
    required this.tokens,
    required this.manifest,
    required this.stage,
    required this.hazardMode,
    required this.selectedComponent,
    required this.registry,
  });

  final AppThemeTokens tokens;
  final DigitalTwinManifest manifest;
  final DigitalTwinStage? stage;
  final String hazardMode;
  final String? selectedComponent;
  final BimComponentRegistry? registry;

  @override
  Widget build(BuildContext context) {
    if (selectedComponent == null) {
      return _EmptyPanel(
        title: 'No component selected',
        body: 'Select a component from the Components panel to inspect details.',
        tokens: tokens,
        icon: Icons.search_outlined,
      );
    }
    final comp = registry?.byId(selectedComponent);
    final doc = manifest.components[selectedComponent] as Map<String, dynamic>?;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _InspectorRow(tokens: tokens, label: 'Component', value: comp?.name ?? selectedComponent!.replaceAll('_', ' ')),
        if (comp != null)
          _InspectorRow(tokens: tokens, label: 'Type', value: comp.type.name),
        _InspectorRow(tokens: tokens, label: 'Stage', value: stage?.title ?? '—'),
        _InspectorRow(tokens: tokens, label: 'Hazard mode', value: hazardMode == 'none' ? 'Normal' : hazardMode),
        const SizedBox(height: 12),
        Text('Details', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (comp != null && comp.engineeringNotes.trim().isNotEmpty) ...[
          _EmptyInline(tokens: tokens, body: comp.engineeringNotes),
          const SizedBox(height: 10),
        ],
        if (doc == null && (comp == null || comp.description.trim().isEmpty))
          _EmptyInline(tokens: tokens, body: 'No engineering data available for this component.')
        else ...[
          if (comp != null && comp.description.trim().isNotEmpty)
            _EmptyInline(tokens: tokens, body: comp.description),
          ...?doc?.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _InspectorRow(tokens: tokens, label: e.key, value: '${e.value}'),
            ),
          ),
        ],
      ],
    );
  }
}

class _InspectorRow extends StatelessWidget {
  const _InspectorRow({required this.tokens, required this.label, required this.value});
  final AppThemeTokens tokens;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(color: tokens.textSecondary, fontSize: 11)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 12)),
        ),
      ],
    );
  }
}

class _ComponentTreePanel extends StatelessWidget {
  const _ComponentTreePanel({
    required this.tokens,
    required this.manifest,
    required this.registry,
    required this.selectedComponent,
    required this.onComponentSelected,
  });

  final AppThemeTokens tokens;
  final DigitalTwinManifest manifest;
  final BimComponentRegistry? registry;
  final String? selectedComponent;
  final ValueChanged<String>? onComponentSelected;

  @override
  Widget build(BuildContext context) {
    final reg = registry ?? BimComponentRegistry.fromManifest(manifest);
    if (reg.components.isEmpty) {
      return _EmptyPanel(
        title: 'No components available',
        body: 'This model does not provide a component index.',
        tokens: tokens,
        icon: Icons.account_tree_outlined,
      );
    }

    final grouped = reg.grouped();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: grouped.entries.map((e) {
        return _TreeGroup(
          tokens: tokens,
          title: _typeLabel(e.key),
          childrenIds: e.value.map((c) => c.id).toList(),
          selected: selectedComponent,
          onSelect: onComponentSelected,
        );
      }).toList(),
    );
  }

  String _typeLabel(BimComponentType t) => switch (t) {
        BimComponentType.foundation => 'Foundation',
        BimComponentType.plinth => 'Plinth',
        BimComponentType.columns => 'Columns',
        BimComponentType.beams => 'Beams',
        BimComponentType.walls => 'Walls',
        BimComponentType.bands => 'Bands',
        BimComponentType.openings => 'Openings',
        BimComponentType.roofStructure => 'Roof structure',
        BimComponentType.roofCover => 'Roof cover',
        BimComponentType.drainage => 'Drainage',
        BimComponentType.reinforcement => 'Reinforcement',
        BimComponentType.connections => 'Connections',
        BimComponentType.other => 'Other',
      };
}

class _TreeGroup extends StatefulWidget {
  const _TreeGroup({
    required this.tokens,
    required this.title,
    required this.childrenIds,
    required this.selected,
    required this.onSelect,
  });

  final AppThemeTokens tokens;
  final String title;
  final List<String> childrenIds;
  final String? selected;
  final ValueChanged<String>? onSelect;

  @override
  State<_TreeGroup> createState() => _TreeGroupState();
}

class _TreeGroupState extends State<_TreeGroup> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.tokens.card.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.tokens.border.withValues(alpha: 0.75)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(color: widget.tokens.textPrimary, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    '${widget.childrenIds.length}',
                    style: TextStyle(color: widget.tokens.textSecondary, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  Icon(_open ? Icons.expand_less : Icons.expand_more, color: widget.tokens.textSecondary),
                ],
              ),
            ),
          ),
          if (_open)
            ...widget.childrenIds.map((id) {
              final active = id == widget.selected;
              return InkWell(
                onTap: () => widget.onSelect?.call(id),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.orange.withValues(alpha: 0.12)
                        : Colors.transparent,
                    border: Border(
                      top: BorderSide(color: widget.tokens.border.withValues(alpha: 0.55)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 16,
                        color: active ? AppColors.orange : widget.tokens.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          id.replaceAll('_', ' '),
                          style: TextStyle(
                            color: widget.tokens.textPrimary,
                            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _EngineeringWorkspace extends StatelessWidget {
  const _EngineeringWorkspace({
    required this.tokens,
    required this.manifest,
    required this.stages,
    required this.stage,
    required this.progress,
    required this.selectedComponent,
    required this.onComponentSelected,
  });

  final AppThemeTokens tokens;
  final DigitalTwinManifest manifest;
  final ConstructionStageController stages;
  final DigitalTwinStage? stage;
  final double progress;
  final String? selectedComponent;
  final ValueChanged<String>? onComponentSelected;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: TabBar(
              isScrollable: true,
              labelColor: tokens.textPrimary,
              unselectedLabelColor: tokens.textSecondary,
              indicatorColor: AppColors.orange,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Hazards'),
                Tab(text: 'Materials'),
                Tab(text: 'Notes'),
                Tab(text: 'Compliance'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: [
                _WorkspaceOverview(tokens: tokens, manifest: manifest, stage: stage, progress: progress),
                _WorkspaceHazards(tokens: tokens, stages: stages, manifest: manifest),
                _WorkspaceMaterials(tokens: tokens, manifest: manifest, selectedComponent: selectedComponent),
                _WorkspaceNotes(tokens: tokens, stage: stage),
                _WorkspaceCompliance(tokens: tokens),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceOverview extends StatelessWidget {
  const _WorkspaceOverview({
    required this.tokens,
    required this.manifest,
    required this.stage,
    required this.progress,
  });
  final AppThemeTokens tokens;
  final DigitalTwinManifest manifest;
  final DigitalTwinStage? stage;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Engineering overview', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        _EmptyInline(tokens: tokens, body: 'No resilience score data available in the current manifest.'),
        const SizedBox(height: 12),
        Text('Current stage', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.card.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.border.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stage?.title ?? '—', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 4,
                  backgroundColor: tokens.border.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stage?.engineeringPrinciple ?? 'No engineering data available.',
                style: TextStyle(color: tokens.textSecondary, fontSize: 12, height: 1.25),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkspaceHazards extends StatelessWidget {
  const _WorkspaceHazards({required this.tokens, required this.stages, required this.manifest});
  final AppThemeTokens tokens;
  final ConstructionStageController stages;
  final DigitalTwinManifest manifest;

  @override
  Widget build(BuildContext context) {
    final hazards = manifest.hazardSimulations.keys.toList();
    if (hazards.isEmpty) {
      return _EmptyPanel(
        title: 'No hazard simulations',
        body: 'This model does not provide hazard simulation metadata.',
        tokens: tokens,
        icon: Icons.warning_amber_outlined,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Hazard performance', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HazardChip(tokens: tokens, label: 'Normal', active: stages.hazardMode == 'none', onTap: () => stages.setHazardMode('none')),
            if (hazards.contains('earthquake'))
              _HazardChip(tokens: tokens, label: 'Earthquake', active: stages.hazardMode == 'earthquake', onTap: () => stages.setHazardMode('earthquake')),
            if (hazards.contains('flood'))
              _HazardChip(tokens: tokens, label: 'Flood', active: stages.hazardMode == 'flood', onTap: () => stages.setHazardMode('flood')),
            if (hazards.contains('wind'))
              _HazardChip(tokens: tokens, label: 'Wind', active: stages.hazardMode == 'wind', onTap: () => stages.setHazardMode('wind')),
            if (hazards.contains('landslide'))
              _HazardChip(tokens: tokens, label: 'Landslide', active: stages.hazardMode == 'landslide', onTap: () => stages.setHazardMode('landslide')),
          ],
        ),
        const SizedBox(height: 12),
        _EmptyInline(tokens: tokens, body: 'Detailed hazard scoring is not available in the current manifest.'),
      ],
    );
  }
}

class _HazardChip extends StatelessWidget {
  const _HazardChip({required this.tokens, required this.label, required this.active, required this.onTap});
  final AppThemeTokens tokens;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? AppColors.orange.withValues(alpha: 0.14) : tokens.chipBackground,
          border: Border.all(color: active ? AppColors.orange : tokens.border.withValues(alpha: 0.7), width: active ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900, fontSize: 12)),
      ),
    );
  }
}

class _WorkspaceMaterials extends StatelessWidget {
  const _WorkspaceMaterials({required this.tokens, required this.manifest, required this.selectedComponent});
  final AppThemeTokens tokens;
  final DigitalTwinManifest manifest;
  final String? selectedComponent;

  @override
  Widget build(BuildContext context) {
    if (selectedComponent == null) {
      return _EmptyPanel(
        title: 'No component selected',
        body: 'Select a component to view material information.',
        tokens: tokens,
        icon: Icons.layers_outlined,
      );
    }
    final doc = manifest.components[selectedComponent] as Map<String, dynamic>?;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Materials', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (doc == null)
          _EmptyInline(tokens: tokens, body: 'No material information available for this component.')
        else
          ...doc.entries.map((e) => _InspectorRow(tokens: tokens, label: e.key, value: '${e.value}')),
      ],
    );
  }
}

class _WorkspaceNotes extends StatelessWidget {
  const _WorkspaceNotes({required this.tokens, required this.stage});
  final AppThemeTokens tokens;
  final DigitalTwinStage? stage;

  @override
  Widget build(BuildContext context) {
    if (stage == null) {
      return _EmptyPanel(
        title: 'No stage active',
        body: 'Stage notes will appear when a stage is selected.',
        tokens: tokens,
        icon: Icons.note_outlined,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Engineering notes', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(stage!.explanation, style: TextStyle(color: tokens.textSecondary, height: 1.35)),
        const SizedBox(height: 12),
        Text('Inspection checklist', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (stage!.inspectionChecklist.trim().isEmpty)
          _EmptyInline(tokens: tokens, body: 'No inspection checklist provided for this stage.')
        else
          Text(stage!.inspectionChecklist, style: TextStyle(color: tokens.textSecondary, height: 1.35)),
      ],
    );
  }
}

class _WorkspaceCompliance extends StatelessWidget {
  const _WorkspaceCompliance({required this.tokens});
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return _EmptyPanel(
      title: 'Compliance information',
      body: 'No compliance data available for this model yet.',
      tokens: tokens,
      icon: Icons.verified_outlined,
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.body, required this.tokens, required this.icon});
  final String title;
  final String body;
  final AppThemeTokens tokens;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: tokens.textSecondary),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(body, style: TextStyle(color: tokens.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  const _EmptyInline({required this.tokens, required this.body});
  final AppThemeTokens tokens;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border.withValues(alpha: 0.7)),
      ),
      child: Text(body, style: TextStyle(color: tokens.textSecondary, height: 1.3)),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.manifest,
    required this.stage,
    required this.stageNum,
    required this.total,
    this.compact = false,
  });

  final DigitalTwinManifest manifest;
  final DigitalTwinStage? stage;
  final int stageNum;
  final int total;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Material(
      color: tokens.headerBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: compact ? AppSpacing.xs : AppSpacing.sm,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: tokens.textOnPrimary),
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manifest.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: tokens.textOnPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      stage?.title ?? 'Digital Twin',
                      style: TextStyle(color: tokens.textOnGlassMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                '$stageNum / $total',
                style: const TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.manifest,
    required this.stages,
    required this.viewLayer,
    required this.onViewLayerChanged,
    required this.hasProcedural,
    required this.onPlayChanged,
    required this.onSpeedChanged,
    required this.onHazardSelected,
    required this.progress,
    this.compact = false,
  });

  final DigitalTwinManifest manifest;
  final ConstructionStageController stages;
  final TwinViewLayer viewLayer;
  final ValueChanged<TwinViewLayer> onViewLayerChanged;
  final bool hasProcedural;
  final void Function(bool playing) onPlayChanged;
  final void Function(double speed) onSpeedChanged;
  final void Function(String mode) onHazardSelected;
  final double progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hazards = manifest.hazardSimulations.keys.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Construction timeline', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _StageList(stages: stages),
        const SizedBox(height: 12),
        _PlaybackRow(
          stages: stages,
          onPlayChanged: onPlayChanged,
          onSpeedChanged: onSpeedChanged,
        ),
        const SizedBox(height: 16),
        Text('View modes', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (hasProcedural)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final layer in _layersForModel(manifest.modelId))
                ChoiceChip(
                  label: Text(_layerLabel(layer), style: const TextStyle(fontSize: 11)),
                  selected: viewLayer == layer,
                  onSelected: (_) => onViewLayerChanged(layer),
                ),
            ],
          )
        else
          Text(
            'GLB construction sequence (3D)',
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 16),
        Text('Hazard simulation', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            ActionChip(
              label: const Text('Normal'),
              onPressed: () => onHazardSelected('none'),
            ),
            if (hazards.contains('earthquake'))
              ActionChip(
                label: const Text('Earthquake'),
                onPressed: () => onHazardSelected('earthquake'),
              ),
            if (hazards.contains('flood'))
              ActionChip(
                label: const Text('Flood'),
                onPressed: () => onHazardSelected('flood'),
              ),
            if (hazards.contains('wind'))
              ActionChip(
                label: const Text('Wind'),
                onPressed: () => onHazardSelected('wind'),
              ),
            if (hazards.contains('landslide'))
              ActionChip(
                label: const Text('Landslide'),
                onPressed: () => onHazardSelected('landslide'),
              ),
          ],
        ),
        if (!compact) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress.clamp(0, 1)),
          ),
        ],
      ],
    );
  }

  static List<TwinViewLayer> _layersForModel(String modelId) {
    const base = [
      TwinViewLayer.structural,
      TwinViewLayer.exploded,
      TwinViewLayer.crossSection,
      TwinViewLayer.loadTransfer,
      TwinViewLayer.connections,
      TwinViewLayer.grid,
    ];
    if (modelId == 'advanced_interlocking_brick_masonry') {
      return [...base, TwinViewLayer.blockAssembly];
    }
    return base;
  }

  static String _layerLabel(TwinViewLayer layer) => switch (layer) {
        TwinViewLayer.glb => '3D',
        TwinViewLayer.structural => 'Structural',
        TwinViewLayer.exploded => 'Exploded',
        TwinViewLayer.crossSection => 'Section',
        TwinViewLayer.loadTransfer => 'Load path',
        TwinViewLayer.connections => 'Connections',
        TwinViewLayer.grid => 'Grid',
        TwinViewLayer.blockAssembly => 'Blocks',
      };
}

class _StageList extends StatelessWidget {
  const _StageList({required this.stages});

  final ConstructionStageController stages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stages.manifest.stages.length,
        itemBuilder: (_, i) {
          final s = stages.manifest.stages[i];
          final active = i == stages.stageIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedStageChip(
              label: '${i + 1}',
              title: s.title,
              active: active,
              onTap: () => stages.setStage(i),
            ),
          );
        },
      ),
    );
  }
}

class _PlaybackRow extends StatelessWidget {
  const _PlaybackRow({
    required this.stages,
    required this.onPlayChanged,
    required this.onSpeedChanged,
  });

  final ConstructionStageController stages;
  final void Function(bool playing) onPlayChanged;
  final void Function(double speed) onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final total = stages.manifest.stages.length;
    final value = total == 0
        ? 0.0
        : (stages.stageIndex + stages.stageProgress) / total;

    return Column(
      children: [
        Slider(value: value.clamp(0, 1), onChanged: stages.scrub),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: stages.stageIndex > 0
                  ? () => stages.setStage(stages.stageIndex - 1)
                  : null,
            ),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.orange),
              icon: Icon(stages.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () => onPlayChanged(!stages.isPlaying),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: stages.stageIndex < total - 1
                  ? () => stages.setStage(stages.stageIndex + 1)
                  : null,
            ),
            DropdownButton<double>(
              value: stages.playbackSpeed,
              items: const [
                DropdownMenuItem(value: 0.5, child: Text('0.5×')),
                DropdownMenuItem(value: 1.0, child: Text('1×')),
                DropdownMenuItem(value: 1.5, child: Text('1.5×')),
                DropdownMenuItem(value: 2.0, child: Text('2×')),
              ],
              onChanged: (s) {
                if (s != null) {
                  stages.setPlaybackSpeed(s);
                  onSpeedChanged(s);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomNarrationBar extends StatelessWidget {
  const _BottomNarrationBar({
    required this.stage,
    required this.progress,
    required this.stageNum,
    required this.total,
  });

  final DigitalTwinStage? stage;
  final double progress;
  final int stageNum;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  stage?.timelineLabel ?? 'Stage $stageNum of $total',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.navy,
                      ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 4,
              ),
            ),
            if (stage != null) ...[
              const SizedBox(height: 8),
              Text(
                stage!.constructionActivity,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EngineeringPanel extends StatelessWidget {
  const _EngineeringPanel({
    required this.manifest,
    required this.stage,
    this.selectedComponent,
    this.onComponentSelected,
    this.scrollController,
  });

  final DigitalTwinManifest manifest;
  final DigitalTwinStage? stage;
  final String? selectedComponent;
  final ValueChanged<String>? onComponentSelected;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Text('Engineering information', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (stage != null) ...[
          _InfoBlock(
            icon: Icons.engineering_outlined,
            title: 'Engineering principle',
            body: stage!.engineeringPrinciple,
          ),
          _InfoBlock(
            icon: Icons.checklist_rtl_outlined,
            title: 'Inspection checklist',
            body: stage!.inspectionChecklist,
          ),
          if (stage!.commonMistakes.isNotEmpty)
            _TagSection(
              title: 'Common mistakes',
              items: stage!.commonMistakes,
              color: AppColors.hazardLight,
              textColor: AppColors.hazard,
            ),
          if (stage!.resilienceBenefits.isNotEmpty)
            _TagSection(
              title: 'Resilience benefits',
              items: stage!.resilienceBenefits,
              color: AppColors.successLight,
              textColor: AppColors.success,
            ),
        ],
        const SizedBox(height: 8),
        Text('Components', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: manifest.components.keys.map((id) {
            return FilterChip(
              label: Text(id.replaceAll('_', ' '), style: const TextStyle(fontSize: 11)),
              selected: selectedComponent == id,
              onSelected: (_) => onComponentSelected?.call(id),
            );
          }).toList(),
        ),
        if (selectedComponent != null) ...[
          const SizedBox(height: 12),
          _ComponentDetail(
            componentId: selectedComponent!,
            docs: manifest.components,
          ),
        ],
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.navy),
                ),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({
    required this.title,
    required this.items,
    required this.color,
    required this.textColor,
  });

  final String title;
  final List<String> items;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 11, color: textColor)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ComponentDetail extends StatelessWidget {
  const _ComponentDetail({required this.componentId, required this.docs});

  final String componentId;
  final Map<String, dynamic> docs;

  @override
  Widget build(BuildContext context) {
    final doc = docs[componentId] as Map<String, dynamic>?;
    if (doc == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc['title']?.toString() ?? componentId.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...doc.entries.where((e) => e.key != 'title').map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Material(
      color: tokens.playbackSurface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: tokens.textOnGlass, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: tokens.textOnGlass, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
