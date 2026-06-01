import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_page_transitions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../bim_simulation/engine/bim_simulation_controller.dart';
import '../../bim_simulation/engine/rendering/bim_viewport.dart';
import '../construction_stage_controller.dart';
import '../digital_twin_viewport.dart';
import '../domain/digital_twin_manifest.dart';
import 'hazard_simulation_overlay.dart';

export 'hazard_simulation_overlay.dart' show HazardSimulationOverlay;

enum TwinViewLayer { glb, structural, exploded, crossSection, loadTransfer }

/// Production Digital Twin workspace — L: engineering · C: BIM · R: controls · Bottom: progress.
class DigitalTwinWorkspace extends StatefulWidget {
  const DigitalTwinWorkspace({
    super.key,
    required this.manifest,
    required this.stages,
    required this.viewLayer,
    required this.onViewLayerChanged,
    required this.showProcedural,
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
  bool _engineeringOpen = false;

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
    final showBottomBar = isMobile || isTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _CompactHeader(
            manifest: widget.manifest,
            stage: stage,
            stageNum: stageNum,
            total: total,
            compact: !isMobile,
          ),
          Expanded(
            child: isMobile
                ? _mobileLayout(stage, hazard, hazardDetail)
                : isTablet
                    ? _tabletLayout(stage, hazard, hazardDetail, progress)
                    : _desktopLayout(stage, hazard, hazardDetail, progress),
          ),
          if (showBottomBar)
            _BottomNarrationBar(
              stage: stage,
              progress: progress,
              stageNum: stageNum,
              total: total,
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

  Widget _desktopLayout(
    DigitalTwinStage? stage,
    String hazard,
    String? hazardDetail,
    double progress,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 240,
          child: _EngineeringPanel(
            manifest: widget.manifest,
            stage: stage,
            selectedComponent: widget.selectedComponent,
            onComponentSelected: widget.onComponentSelected,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 9,
          child: _viewer(widget.showProcedural, hazard, hazardDetail),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 240,
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
      ],
    );
  }

  Widget _tabletLayout(
    DigitalTwinStage? stage,
    String hazard,
    String? hazardDetail,
    double progress,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: _viewer(widget.showProcedural, hazard, hazardDetail),
        ),
        SizedBox(
          width: 260,
          child: Column(
            children: [
              Expanded(
                flex: 3,
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
                  compact: true,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                flex: 4,
                child: _EngineeringPanel(
                  manifest: widget.manifest,
                  stage: stage,
                  selectedComponent: widget.selectedComponent,
                  onComponentSelected: widget.onComponentSelected,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout(DigitalTwinStage? stage, String hazard, String? hazardDetail) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _viewer(widget.showProcedural, hazard, hazardDetail),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconChip(
                icon: Icons.menu_book_outlined,
                label: 'Guide',
                onTap: () => setState(() => _engineeringOpen = true),
              ),
              const SizedBox(width: 8),
              _IconChip(
                icon: Icons.tune,
                label: 'Controls',
                onTap: () => _showMobileControls(context),
              ),
            ],
          ),
        ),
        if (_engineeringOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _engineeringOpen = false),
              child: ColoredBox(
                color: Colors.black54,
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
    return Material(
      color: AppColors.navy,
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manifest.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      stage?.title ?? 'Digital Twin',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
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
            children: TwinViewLayer.values.map((layer) {
              final selected = viewLayer == layer;
              return ChoiceChip(
                label: Text(_layerLabel(layer), style: const TextStyle(fontSize: 11)),
                selected: selected,
                onSelected: (_) => onViewLayerChanged(layer),
              );
            }).toList(),
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

  static String _layerLabel(TwinViewLayer layer) => switch (layer) {
        TwinViewLayer.glb => '3D',
        TwinViewLayer.structural => 'Structural',
        TwinViewLayer.exploded => 'Exploded',
        TwinViewLayer.crossSection => 'Section',
        TwinViewLayer.loadTransfer => 'Load path',
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
    return Material(
      color: AppColors.navy.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
