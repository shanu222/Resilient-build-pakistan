import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/widgets/government_header.dart';
import '../engine/bim_simulation_controller.dart';
import '../engine/bim_visualization_mode.dart';
import '../engine/rendering/bim_viewport.dart';
import '../services/bim_narration_service.dart';

/// Full-screen BIM 4D construction simulation (procedural engineering viewport).
class BimSimulationScreen extends StatefulWidget {
  const BimSimulationScreen({super.key, required this.modelId});

  final String modelId;

  @override
  State<BimSimulationScreen> createState() => _BimSimulationScreenState();
}

class _BimSimulationScreenState extends State<BimSimulationScreen> {
  late final BimSimulationController _controller;
  late final BimNarrationService _narration;
  int _lastNarratedStage = -1;

  @override
  void initState() {
    super.initState();
    _controller = BimSimulationController(modelId: widget.modelId);
    _narration = BimNarrationService();
    _init();
  }

  Future<void> _init() async {
    await _narration.init();
    await _controller.loadDefinition();
    _controller.addListener(_onStageChange);
    if (mounted) setState(() {});
  }

  void _onStageChange() {
    final si = _controller.stageIndex;
    if (si != _lastNarratedStage && _controller.stageProgress < 0.08) {
      _lastNarratedStage = si;
      final stage = _controller.currentStage;
      if (stage != null) {
        _narration.speakStage(stage.narration);
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStageChange);
    _controller.dispose();
    _narration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _controller.currentStage;

    final tokens = context.appTokens;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: tokens.viewerBackground,
        appBar: GovernmentHeader(
          title: 'Digital Twin — ${_controller.displayName}',
          showBack: true,
          preferredHeight: 64,
        ),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.42,
              child: Stack(
                children: [
                  BimViewport(controller: _controller),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: tokens.card.withValues(alpha: 0.92),
                      ),
                      icon: Icon(
                        _controller.crossSectionEnabled ? Icons.cut : Icons.cut_outlined,
                        color: tokens.textPrimary,
                      ),
                      onPressed: _controller.toggleCrossSection,
                      tooltip: 'Cross section',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  if (stage != null) ...[
                    Text(
                      stage.explanation,
                      style: TextStyle(
                        fontSize: 14,
                        color: tokens.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: stage.highlights
                          .map(
                            (h) => Chip(
                              label: Text(h, style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (_controller.selectedComponentId != null) ...[
                    const SizedBox(height: 12),
                    _EngineeringPanel(
                      componentId: _controller.selectedComponentId!,
                      docs: _controller.componentDocs,
                    ),
                  ],
                  if (_controller.stageIndex == _controller.stages.length - 1 &&
                      _controller.stageProgress > 0.85) ...[
                    const SizedBox(height: 12),
                    _ResilienceSummaryCard(data: _controller.resilienceSummary),
                  ],
                  const SizedBox(height: 12),
                  _ViewModeChips(
                    controller: _controller,
                    mode: _controller.viewMode,
                    onMode: _controller.setViewMode,
                  ),
                  const SizedBox(height: 12),
                  _TimelineControls(controller: _controller),
                  const SizedBox(height: 8),
                  _StageList(controller: _controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeChips extends StatelessWidget {
  const _ViewModeChips({
    required this.controller,
    required this.mode,
    required this.onMode,
  });

  final BimSimulationController controller;
  final BimVisualizationMode mode;
  final ValueChanged<BimVisualizationMode> onMode;

  List<BimVisualizationMode> get _modes {
    return BimVisualizationMode.values.where((m) {
      if (m == BimVisualizationMode.flood ||
          m == BimVisualizationMode.hydraulic) {
        return controller.isElevatedFlood ||
            controller.isAmphibious ||
            controller.isRaisedPlinth;
      }
      if (m == BimVisualizationMode.buoyancy) {
        return controller.isAmphibious;
      }
      if (m == BimVisualizationMode.thermal) {
        return controller.isFlyAsh ||
            controller.isPrefabricated ||
            controller.isRatTrapBond ||
            controller.isReinforcedAdobe ||
            controller.isTimberFrameLath;
      }
      if (m == BimVisualizationMode.reinforcement) {
        return controller.isReinforcedAdobe;
      }
      if (m == BimVisualizationMode.cavityWall ||
          m == BimVisualizationMode.materialComparison) {
        return controller.isRatTrapBond;
      }
      if (m == BimVisualizationMode.modularAssembly) {
        return controller.isPrefabricated;
      }
      if (m == BimVisualizationMode.blockAssembly) {
        return controller.isAdvancedInterlocking;
      }
      if (m == BimVisualizationMode.earthPressure ||
          m == BimVisualizationMode.landslide ||
          m == BimVisualizationMode.groundwater) {
        return controller.isGeogrid;
      }
      if (m == BimVisualizationMode.bambooFrame) {
        return controller.isCementBamboo;
      }
      if (m == BimVisualizationMode.steelFrame ||
          m == BimVisualizationMode.connection) {
        return controller.isLightGaugeSteel;
      }
      if (m == BimVisualizationMode.timberBand) {
        return controller.isLohKaat;
      }
      if (m == BimVisualizationMode.timberSkeleton) {
        return controller.isTimberFrameLath;
      }
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _modes.map((m) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(m.label, style: const TextStyle(fontSize: 10)),
              selected: mode == m,
              onSelected: (_) => onMode(m),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineControls extends StatelessWidget {
  const _TimelineControls({required this.controller});

  final BimSimulationController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    controller.setStage(
                      (controller.stageIndex - 1).clamp(0, 999),
                    );
                  },
                  icon: const Icon(Icons.skip_previous),
                ),
                FloatingActionButton(
                  mini: false,
                  backgroundColor: AppColors.orange,
                  onPressed: controller.togglePlay,
                  child: Icon(
                    controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (controller.stageIndex < controller.stages.length - 1) {
                      controller.setStage(controller.stageIndex + 1);
                    }
                  },
                  icon: const Icon(Icons.skip_next),
                ),
                Expanded(
                  child: Slider(
                    value: controller.globalProgress,
                    onChanged: (v) {
                      controller.isPlaying = false;
                      controller.setScrub(v);
                    },
                  ),
                ),
                Text('${(controller.playbackSpeed).toStringAsFixed(1)}x'),
              ],
            ),
            Row(
              children: [
                const Text('Speed', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: controller.playbackSpeed,
                    min: 0.5,
                    max: 2,
                    divisions: 3,
                    onChanged: controller.setPlaybackSpeed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageList extends StatelessWidget {
  const _StageList({required this.controller});

  final BimSimulationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Construction Timeline',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...controller.stages.map((s) {
          final active = s.index == controller.stageIndex;
          return ListTile(
            dense: true,
            selected: active,
            selectedTileColor: AppColors.orange.withValues(alpha: 0.1),
            title: Text(s.title, style: const TextStyle(fontSize: 13)),
            subtitle: Text(s.timelineLabel, style: const TextStyle(fontSize: 11)),
            trailing: s.index < controller.stageIndex
                ? const Icon(Icons.check, color: AppColors.success, size: 18)
                : null,
            onTap: () => controller.setStage(s.index),
          );
        }),
      ],
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
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc['title']?.toString() ?? componentId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...doc.entries.map((e) {
              if (e.key == 'title') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${_label(e.key)}: ${e.value}',
                  style: const TextStyle(fontSize: 13),
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
    final rows = _labels.entries
        .where((e) => data.containsKey(e.key) && e.key != 'overall')
        .map((e) => _scoreRow(e.value, data[e.key]))
        .toList();

    return Card(
      color: AppColors.navy,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resilience Score',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            ...rows,
            if (data['overall'] != null) ...[
              const Divider(color: Colors.white24),
              _scoreRow('Overall', data['overall'], bold: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(String label, dynamic value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
          Text(
            '$value/100',
            style: TextStyle(
              color: Colors.white,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
