import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/widgets/government_header.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../bim/engineering_constraint_engine.dart';
import '../engine/bim_simulation_controller.dart';
import '../engine/bim_visualization_mode.dart';
import '../engine/rendering/bim_viewport.dart';
import 'bim_toolbar.dart';

String _validationSummary(ConstraintValidationResult? result) {
  if (result == null) return 'Validation pending.';
  if (result.passed && !result.hasIssues) {
    return 'All engineering constraints passed.';
  }
  final parts = [...result.errors, ...result.warnings];
  return parts.isEmpty
      ? (result.passed ? 'Passed' : 'Review required')
      : parts.join('\n');
}

/// Fullscreen BIM workspace — viewer is always primary; panels are overlays only.
class BimEngineeringWorkspace extends StatefulWidget {
  const BimEngineeringWorkspace({super.key, required this.controller});

  final BimSimulationController controller;

  @override
  State<BimEngineeringWorkspace> createState() =>
      _BimEngineeringWorkspaceState();
}

class _BimEngineeringWorkspaceState extends State<BimEngineeringWorkspace>
    with SingleTickerProviderStateMixin {
  static const double _drawerWidth = 390;

  bool _leftOpen = false;
  bool _rightOpen = false;
  bool _timelineOpen = false;
  bool _playbackVisible = true;
  double _playbackIdleSec = 0;
  late final Ticker _idleTicker;
  int _leftTab = 0;
  int _rightTab = 0;

  BimSimulationController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _idleTicker = createTicker(_onIdleTick)..start();
    _c.addListener(_onController);
  }

  @override
  void dispose() {
    _idleTicker.dispose();
    _c.removeListener(_onController);
    super.dispose();
  }

  void _onIdleTick(Duration elapsed) {
    if (!_playbackVisible || _c.isPlaying) return;
    final dt = elapsed.inMicroseconds / 1e6;
    _playbackIdleSec += dt;
    if (_playbackIdleSec >= 5 && mounted) {
      setState(() => _playbackVisible = false);
      _playbackIdleSec = 0;
    }
  }

  void _onController() {
    if (mounted) setState(() {});
    if (_c.isPlaying) _showPlayback();
  }

  void _showPlayback() {
    setState(() {
      _playbackVisible = true;
      _playbackIdleSec = 0;
    });
  }

  void _onUserInteraction() {
    _showPlayback();
  }

  void _closeDrawers() {
    setState(() {
      _leftOpen = false;
      _rightOpen = false;
      _timelineOpen = false;
    });
  }

  Future<void> _openMobileSheet(String id) async {
    _onUserInteraction();
    final mobile = AppBreakpoints.isMobile(context);
    if (!mobile) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scroll) => _SheetShell(
          title: _sheetTitle(id),
          child: _sheetBody(id, scroll),
        ),
      ),
    );
  }

  String _sheetTitle(String id) => switch (id) {
        'left' => 'Components & stages',
        'right' => 'Engineering workspace',
        'timeline' => 'Construction timeline',
        _ => 'Panel',
      };

  Widget _sheetBody(String id, ScrollController scroll) {
    return switch (id) {
      'left' => _LeftPanelContent(
          controller: _c,
          tab: _leftTab,
          onTab: (i) => setState(() => _leftTab = i),
          scroll: scroll,
        ),
      'right' => _RightPanelContent(
          controller: _c,
          tab: _rightTab,
          onTab: (i) => setState(() => _rightTab = i),
          scroll: scroll,
        ),
      'timeline' => _TimelinePanel(controller: _c, scroll: scroll),
      _ => const SizedBox.shrink(),
    };
  }

  void _dockAction(String action) {
    _onUserInteraction();
    final mobile = AppBreakpoints.isMobile(context);

    switch (action) {
      case 'components':
      case 'stages':
      case 'docs':
        if (action == 'components') _leftTab = 0;
        if (action == 'stages') _leftTab = 1;
        if (action == 'docs') _leftTab = 2;
        if (mobile) {
          _openMobileSheet('left');
        } else {
          setState(() {
            _rightOpen = false;
            _timelineOpen = false;
            _leftOpen = true;
          });
        }
        break;
      case 'analysis':
      case 'hazards':
      case 'materials':
      case 'inspector':
        if (action == 'analysis') _rightTab = 0;
        if (action == 'hazards') _rightTab = 1;
        if (action == 'materials') _rightTab = 2;
        if (action == 'inspector') _rightTab = 3;
        if (mobile) {
          _openMobileSheet('right');
        } else {
          setState(() {
            _leftOpen = false;
            _timelineOpen = false;
            _rightOpen = true;
          });
        }
        break;
      case 'timeline':
        if (mobile) {
          _openMobileSheet('timeline');
        } else {
          setState(() {
            _leftOpen = false;
            _rightOpen = false;
            _timelineOpen = !_timelineOpen;
          });
        }
        break;
      case 'playback':
        _showPlayback();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final mobile = AppBreakpoints.isMobile(context);
    final stage = _c.currentStage;
    final headerH = mobile
        ? 56.0
        : (AppBreakpoints.isTablet(context) ? 64.0 : 72.0);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: tokens.viewerBackground,
        body: Listener(
          onPointerDown: (_) => _onUserInteraction(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Primary layer — fullscreen viewer (never shrunk by drawers).
              RepaintBoundary(
                child: BimViewport(
                  controller: _c,
                  showEmbeddedToolbar: false,
                ),
              ),

              // Stage context HUD (overlay).
              if (stage != null)
                Positioned(
                  left: 12,
                  top: headerH + 72,
                  right: mobile ? 72 : 220,
                  child: IgnorePointer(
                    child: _StageHud(stageTitle: stage.title, explanation: stage.explanation),
                  ),
                ),

              // Floating header.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GovernmentHeader(
                  title: 'Digital Twin — ${_c.displayName}',
                  showBack: true,
                  preferredHeight: headerH,
                ),
              ),

              // Floating viewer toolbar.
              Positioned(
                top: headerH + 6,
                left: 8,
                right: 8,
                child: BimToolbar(
                  controller: _c,
                  cameraPro: _c.cameraPro,
                ),
              ),

              // Cross-section quick control (top-right).
              Positioned(
                top: headerH + 14,
                right: 12,
                child: _GlassIconBtn(
                  icon: _c.crossSectionEnabled ? Icons.cut : Icons.cut_outlined,
                  tooltip: 'Cross section',
                  onTap: _c.toggleCrossSection,
                ),
              ),

              // Action dock.
              Positioned(
                top: headerH + (mobile ? 58 : 68),
                right: 12,
                child: mobile
                    ? _MobileFabDock(onAction: _dockAction)
                    : _DesktopDock(onAction: _dockAction),
              ),

              // Scrim behind drawers (viewer stays visible).
              if (!mobile && (_leftOpen || _rightOpen || _timelineOpen))
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeDrawers,
                    child: Container(color: context.appTokens.overlayScrim),
                  ),
                ),

              // Left drawer (overlay).
              if (!mobile)
                _SideDrawer(
                  open: _leftOpen,
                  fromLeft: true,
                  width: _drawerWidth,
                  title: 'Project',
                  onClose: () => setState(() => _leftOpen = false),
                  child: _LeftPanelContent(
                    controller: _c,
                    tab: _leftTab,
                    onTab: (i) => setState(() => _leftTab = i),
                  ),
                ),

              // Right drawer (overlay).
              if (!mobile)
                _SideDrawer(
                  open: _rightOpen,
                  fromLeft: false,
                  width: _drawerWidth,
                  title: 'Engineering',
                  onClose: () => setState(() => _rightOpen = false),
                  child: _RightPanelContent(
                    controller: _c,
                    tab: _rightTab,
                    onTab: (i) => setState(() => _rightTab = i),
                  ),
                ),

              // Timeline drawer — slides from bottom; never consumes page height.
              if (!mobile)
                _BottomTimelineDrawer(
                  open: _timelineOpen,
                  onClose: () => setState(() => _timelineOpen = false),
                  child: _TimelinePanel(controller: _c),
                ),

              // Floating playback (bottom-center, glass).
              Positioned(
                left: 12,
                right: 12,
                bottom: mobile ? 20 : 16,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    opacity: _playbackVisible || _c.isPlaying ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: IgnorePointer(
                      ignoring: !_playbackVisible && !_c.isPlaying,
                      child: _BimPlaybackDock(
                        controller: _c,
                        onInteraction: _showPlayback,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageHud extends StatelessWidget {
  const _StageHud({required this.stageTitle, required this.explanation});

  final String stageTitle;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 12,
      blurSigma: 16,
      opacity: 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stageTitle,
            style: TextStyle(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: tokens.textSecondary, fontSize: 11, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _GlassIconBtn extends StatelessWidget {
  const _GlassIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: tokens.card.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: tokens.textPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}

class _DesktopDock extends StatelessWidget {
  const _DesktopDock({required this.onAction});

  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      borderRadius: 16,
      blurSigma: 18,
      opacity: 0.38,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DockBtn(icon: Icons.account_tree_outlined, label: 'Components', onTap: () => onAction('components')),
          _DockBtn(icon: Icons.view_timeline_outlined, label: 'Stages', onTap: () => onAction('stages')),
          _DockBtn(icon: Icons.menu_book_outlined, label: 'Docs', onTap: () => onAction('docs')),
          const Divider(height: 12),
          _DockBtn(icon: Icons.analytics_outlined, label: 'Analysis', onTap: () => onAction('analysis')),
          _DockBtn(icon: Icons.warning_amber_outlined, label: 'Hazards', onTap: () => onAction('hazards')),
          _DockBtn(icon: Icons.layers_outlined, label: 'Materials', onTap: () => onAction('materials')),
          _DockBtn(icon: Icons.search, label: 'Inspector', onTap: () => onAction('inspector')),
          const Divider(height: 12),
          _DockBtn(icon: Icons.timeline, label: 'Timeline', onTap: () => onAction('timeline')),
          _DockBtn(icon: Icons.play_circle_outline, label: 'Playback', onTap: () => onAction('playback')),
        ],
      ),
    );
  }
}

class _MobileFabDock extends StatefulWidget {
  const _MobileFabDock({required this.onAction});

  final void Function(String action) onAction;

  @override
  State<_MobileFabDock> createState() => _MobileFabDockState();
}

class _MobileFabDockState extends State<_MobileFabDock> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _mini(Icons.account_tree_outlined, 'Components', 'components'),
          _mini(Icons.analytics_outlined, 'Analysis', 'analysis'),
          _mini(Icons.timeline, 'Timeline', 'timeline'),
          _mini(Icons.play_circle_outline, 'Playback', 'playback'),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          backgroundColor: AppColors.orange,
          onPressed: () => setState(() => _open = !_open),
          child: Icon(_open ? Icons.close : Icons.menu),
        ),
      ],
    );
  }

  Widget _mini(IconData icon, String label, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: AppColors.navy.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                label,
                style: TextStyle(color: context.appTokens.textOnGlass, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: action,
            backgroundColor: AppColors.navy,
            onPressed: () {
              setState(() => _open = false);
              widget.onAction(action);
            },
            child: Icon(icon, color: context.appTokens.textOnGlass, size: 20),
          ),
        ],
      ),
    );
  }
}

class _DockBtn extends StatelessWidget {
  const _DockBtn({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: AppColors.navy),
        ),
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer({
    required this.open,
    required this.fromLeft,
    required this.width,
    required this.title,
    required this.onClose,
    required this.child,
  });

  final bool open;
  final bool fromLeft;
  final double width;
  final String title;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
  final top = (AppBreakpoints.isMobile(context) ? 56.0 : 72.0) + 8;

    return Positioned(
      top: top,
      bottom: 0,
      left: fromLeft ? 0 : null,
      right: fromLeft ? null : 0,
      child: AnimatedSlide(
        offset: open ? Offset.zero : Offset(fromLeft ? -1 : 1, 0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: open ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !open,
            child: Material(
              elevation: 12,
              color: tokens.card,
              child: SizedBox(
                width: width.clamp(350, 420),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 4, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomTimelineDrawer extends StatelessWidget {
  const _BottomTimelineDrawer({
    required this.open,
    required this.onClose,
    required this.child,
  });

  final bool open;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    const height = 320.0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        offset: open ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: open ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !open,
            child: Material(
              elevation: 16,
              color: tokens.card,
              child: SizedBox(
                height: height,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Construction timeline',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: tokens.card.withValues(alpha: 0.96),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelTabBar extends StatelessWidget {
  const _PanelTabBar({required this.labels, required this.index, required this.onTap});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(labels[i], style: const TextStyle(fontSize: 11)),
              selected: selected,
              onSelected: (_) => onTap(i),
            ),
          );
        }),
      ),
    );
  }
}

class _LeftPanelContent extends StatelessWidget {
  const _LeftPanelContent({
    required this.controller,
    required this.tab,
    required this.onTab,
    this.scroll,
  });

  final BimSimulationController controller;
  final int tab;
  final ValueChanged<int> onTab;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PanelTabBar(
          labels: const ['Components', 'Stages', 'Docs'],
          index: tab,
          onTap: onTab,
        ),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: [
              _ComponentTree(controller: controller, scroll: scroll),
              _TimelinePanel(controller: controller, scroll: scroll, compact: true),
              _DocumentationPanel(controller: controller, scroll: scroll),
            ],
          ),
        ),
      ],
    );
  }
}

class _RightPanelContent extends StatelessWidget {
  const _RightPanelContent({
    required this.controller,
    required this.tab,
    required this.onTab,
    this.scroll,
  });

  final BimSimulationController controller;
  final int tab;
  final ValueChanged<int> onTab;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PanelTabBar(
          labels: const ['Analysis', 'Hazards', 'Materials', 'Inspector'],
          index: tab,
          onTap: onTab,
        ),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: [
              _AnalysisTab(controller: controller, scroll: scroll),
              _HazardsTab(controller: controller, scroll: scroll),
              _MaterialsTab(controller: controller, scroll: scroll),
              _InspectorTab(controller: controller, scroll: scroll),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComponentTree extends StatelessWidget {
  const _ComponentTree({required this.controller, this.scroll});

  final BimSimulationController controller;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final ids = controller.componentDocs.keys.toList()..sort();
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(8),
      itemCount: ids.length,
      itemBuilder: (context, i) {
        final id = ids[i];
        final doc = controller.componentDocs[id] as Map<String, dynamic>?;
        final title = doc?['title']?.toString() ?? id;
        final selected = controller.selectedComponentId == id;
        return ListTile(
          dense: true,
          selected: selected,
          title: Text(title, style: const TextStyle(fontSize: 13)),
          subtitle: Text(id, style: const TextStyle(fontSize: 10)),
          onTap: () => controller.selectComponent(id),
        );
      },
    );
  }
}

class _DocumentationPanel extends StatelessWidget {
  const _DocumentationPanel({required this.controller, this.scroll});

  final BimSimulationController controller;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final stage = controller.currentStage;
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.all(12),
      children: [
        if (stage != null) ...[
          Text(stage.explanation, style: const TextStyle(fontSize: 13, height: 1.45)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: stage.highlights
                .map((h) => Chip(label: Text(h, style: const TextStyle(fontSize: 11))))
                .toList(),
          ),
        ] else
          const Text('Load a model to view stage documentation.'),
      ],
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({
    required this.controller,
    this.scroll,
    this.compact = false,
  });

  final BimSimulationController controller;
  final ScrollController? scroll;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      padding: EdgeInsets.all(compact ? 4 : 8),
      itemCount: controller.stages.length,
      itemBuilder: (context, i) {
        final s = controller.stages[i];
        final active = s.index == controller.stageIndex;
        return ListTile(
          dense: true,
          selected: active,
          selectedTileColor: AppColors.orange.withValues(alpha: 0.12),
          title: Text(s.title, style: const TextStyle(fontSize: 13)),
          subtitle: Text(s.timelineLabel, style: const TextStyle(fontSize: 11)),
          trailing: s.index < controller.stageIndex
              ? const Icon(Icons.check, color: AppColors.success, size: 18)
              : null,
          onTap: () => controller.setStage(s.index),
        );
      },
    );
  }
}

class _AnalysisTab extends StatelessWidget {
  const _AnalysisTab({required this.controller, this.scroll});

  final BimSimulationController controller;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Engineering analysis',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _validationSummary(controller.validationResult),
          style: TextStyle(color: tokens.textSecondary, fontSize: 13),
        ),
        if (controller.stageIndex == controller.stages.length - 1 &&
            controller.stageProgress > 0.85) ...[
          const SizedBox(height: 12),
          _ResilienceSummaryCard(data: controller.resilienceSummary),
        ],
      ],
    );
  }
}

class _HazardsTab extends StatelessWidget {
  const _HazardsTab({required this.controller, this.scroll});

  final BimSimulationController controller;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.all(8),
      children: [
        _ViewModeChips(controller: controller),
        const SizedBox(height: 12),
        const Text(
          'Environmental and hazard visualization modes update the procedural scene in real time.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  const _MaterialsTab({required this.controller, this.scroll});

  final BimSimulationController controller;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final entries = controller.componentDocs.entries.toList();
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final doc = e.value as Map<String, dynamic>?;
        if (doc == null) return const SizedBox.shrink();
        return ListTile(
          dense: true,
          title: Text(doc['title']?.toString() ?? e.key, style: const TextStyle(fontSize: 13)),
          subtitle: Text(
            doc['material']?.toString() ?? doc['type']?.toString() ?? e.key,
            style: const TextStyle(fontSize: 11),
          ),
          onTap: () => controller.selectComponent(e.key),
        );
      },
    );
  }
}

class _InspectorTab extends StatelessWidget {
  const _InspectorTab({required this.controller, this.scroll});

  final BimSimulationController controller;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final id = controller.selectedComponentId;
    if (id == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tap a component in the 3D view or component tree to inspect.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.all(8),
      children: [
        _EngineeringPanel(componentId: id, docs: controller.componentDocs),
        const SizedBox(height: 8),
        const Text('Compliance', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          _validationSummary(controller.validationResult),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _ViewModeChips extends StatelessWidget {
  const _ViewModeChips({required this.controller});

  final BimSimulationController controller;

  List<BimVisualizationMode> _modes() {
    return BimVisualizationMode.values.where((m) {
      if (m == BimVisualizationMode.flood ||
          m == BimVisualizationMode.hydraulic) {
        return controller.isElevatedFlood ||
            controller.isAmphibious ||
            controller.isRaisedPlinth;
      }
      if (m == BimVisualizationMode.buoyancy) return controller.isAmphibious;
      if (m == BimVisualizationMode.thermal) {
        return controller.isFlyAsh ||
            controller.isPrefabricated ||
            controller.isRatTrapBond ||
            controller.isReinforcedAdobe ||
            controller.isTimberFrameLath;
      }
      if (m == BimVisualizationMode.reinforcement) return controller.isReinforcedAdobe;
      if (m == BimVisualizationMode.cavityWall ||
          m == BimVisualizationMode.materialComparison) {
        return controller.isRatTrapBond;
      }
      if (m == BimVisualizationMode.modularAssembly) return controller.isPrefabricated;
      if (m == BimVisualizationMode.blockAssembly) return controller.isAdvancedInterlocking;
      if (m == BimVisualizationMode.earthPressure ||
          m == BimVisualizationMode.landslide ||
          m == BimVisualizationMode.groundwater) {
        return controller.isGeogrid;
      }
      if (m == BimVisualizationMode.bambooFrame) return controller.isCementBamboo;
      if (m == BimVisualizationMode.steelFrame ||
          m == BimVisualizationMode.connection) {
        return controller.isLightGaugeSteel;
      }
      if (m == BimVisualizationMode.timberBand) return controller.isLohKaat;
      if (m == BimVisualizationMode.timberSkeleton) return controller.isTimberFrameLath;
      if (m == BimVisualizationMode.drainage) {
        return controller.isEarthbag ||
            controller.isElevatedFlood ||
            controller.isRaisedPlinth ||
            controller.isGeogrid ||
            controller.isLohKaat;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mode = controller.viewMode;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _modes().map((m) {
        return FilterChip(
          label: Text(m.label, style: const TextStyle(fontSize: 10)),
          selected: mode == m,
          onSelected: (_) => controller.setViewMode(m),
        );
      }).toList(),
    );
  }
}

class _BimPlaybackDock extends StatelessWidget {
  const _BimPlaybackDock({
    required this.controller,
    required this.onInteraction,
  });

  final BimSimulationController controller;
  final VoidCallback onInteraction;

  @override
  Widget build(BuildContext context) {
    final mobile = AppBreakpoints.isMobile(context);
    final tokens = context.appTokens;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final total = controller.stages.length;
        final stageNum = controller.stageIndex + 1;
        final value = controller.globalProgress;
        final speed = controller.playbackSpeed;
        final labelStyle = TextStyle(
          color: tokens.textOnGlassMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        );
        final iconColor = tokens.textOnGlass;

        return GlassCard(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          borderRadius: 16,
          blurSigma: 22,
          opacity: 0.42,
          borderOpacity: 0.12,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: mobile ? double.infinity : 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      total == 0 ? 'No stages' : 'Stage $stageNum / $total',
                      style: labelStyle,
                    ),
                    const Spacer(),
                    Text(
                      '${(value * 100).round()}% · ${speed.toStringAsFixed(speed == speed.roundToDouble() ? 0 : 2)}×',
                      style: labelStyle.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: AppColors.orange,
                    inactiveTrackColor: tokens.textOnGlass.withValues(alpha: 0.18),
                    thumbColor: AppColors.orange,
                  ),
                  child: Slider(
                    value: value.clamp(0, 1),
                    onChanged: (v) {
                      onInteraction();
                      controller.setScrub(v);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Previous',
                      onPressed: controller.stageIndex > 0
                          ? () {
                              onInteraction();
                              controller.previousStage();
                            }
                          : null,
                      icon: Icon(Icons.skip_previous, color: iconColor),
                    ),
                    IconButton(
                      tooltip: controller.isPlaying ? 'Pause' : 'Play',
                      onPressed: () {
                        onInteraction();
                        controller.togglePlay();
                      },
                      icon: Icon(
                        controller.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: AppColors.orange,
                        size: mobile ? 40 : 44,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next',
                      onPressed: controller.stageIndex < total - 1
                          ? () {
                              onInteraction();
                              controller.nextStage();
                            }
                          : null,
                      icon: Icon(Icons.skip_next, color: iconColor),
                    ),
                    IconButton(
                      tooltip: 'Restart',
                      onPressed: () {
                        onInteraction();
                        controller.restart();
                      },
                      icon: Icon(Icons.restart_alt, color: iconColor),
                    ),
                    if (!mobile)
                      IconButton(
                        tooltip: 'Stop',
                        onPressed: () {
                          onInteraction();
                          controller.stop();
                        },
                        icon: Icon(Icons.stop_circle_outlined, color: iconColor),
                      ),
                    const SizedBox(width: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        dropdownColor: tokens.primary,
                        value: speed.clamp(0.25, 4.0),
                        style: TextStyle(
                          color: tokens.textOnGlass,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        items: const [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0]
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text('${v}x'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          onInteraction();
                          controller.setPlaybackSpeed(v);
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

class _EngineeringPanel extends StatelessWidget {
  const _EngineeringPanel({required this.componentId, required this.docs});

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
              doc['title']?.toString() ?? componentId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...doc.entries.map((e) {
              if (e.key == 'title') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${_label(e.key)}: ${e.value}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _label(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _ResilienceSummaryCard extends StatelessWidget {
  const _ResilienceSummaryCard({required this.data});

  final Map<String, dynamic> data;

  static const _labels = {
    'earthquakeResistance': 'Earthquake Resistance',
    'floodResistance': 'Flood Resistance',
    'windResistance': 'Wind Resistance',
    'thermalEfficiency': 'Thermal Efficiency',
    'thermalPerformance': 'Thermal Performance',
    'constructionSpeed': 'Construction Speed',
    'materialEfficiency': 'Material Efficiency',
    'sustainability': 'Sustainability',
    'moistureResistance': 'Moisture Resistance',
    'durability': 'Durability',
    'adaptability': 'Adaptability',
    'slopeStability': 'Slope Stability',
    'drainagePerformance': 'Drainage Performance',
    'landslideResistance': 'Landslide Resistance',
    'overall': 'Overall',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final rows = _labels.entries
        .where((e) => data.containsKey(e.key) && e.key != 'overall')
        .map((e) => _scoreRow(e.value, data[e.key]))
        .toList();

    return Card(
      color: AppColors.navy,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resilience score',
              style: TextStyle(
                color: tokens.textOnGlass,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...rows,
            if (data['overall'] != null) ...[
              Divider(color: tokens.textOnGlass.withValues(alpha: 0.24)),
              _scoreRow('Overall', data['overall'], bold: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(String label, dynamic value, {bool bold = false}) {
    return Builder(
      builder: (context) {
        final onGlass = context.appTokens.textOnGlass;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: onGlass.withValues(alpha: 0.85))),
              Text(
                '$value/100',
                style: TextStyle(
                  color: onGlass,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
