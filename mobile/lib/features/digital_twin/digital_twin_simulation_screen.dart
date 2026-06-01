import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../bim_simulation/engine/bim_scene_registry.dart';
import '../bim_simulation/engine/bim_simulation_controller.dart';
import '../bim_simulation/engine/bim_visualization_mode.dart';
import '../bim_simulation/engine/rendering/bim_viewport.dart';
import '../bim_simulation/ui/bim_simulation_screen.dart';
import '../construction/construction_guide_screen.dart';
import 'construction_stage_controller.dart';
import 'digital_twin_engine.dart';
import 'digital_twin_viewport.dart';
import 'domain/digital_twin_manifest.dart';
import 'narration_controller.dart';

enum _TwinViewLayer { glb, structural, exploded, crossSection, loadTransfer }

/// GLB construction sequence + procedural engineering views (offline).
class DigitalTwinSimulationScreen extends StatefulWidget {
  const DigitalTwinSimulationScreen({super.key, required this.modelId});

  final String modelId;

  static Future<Widget> forModel(String modelId) async {
    if (await DigitalTwinEngine.hasAssets(modelId)) {
      return DigitalTwinSimulationScreen(modelId: modelId);
    }
    if (BimSceneRegistry.hasBimSimulation(modelId)) {
      return BimSimulationScreen(modelId: modelId);
    }
    return LegacyConstructionGuideScreen(modelId: modelId);
  }

  @override
  State<DigitalTwinSimulationScreen> createState() =>
      _DigitalTwinSimulationScreenState();
}

class _DigitalTwinSimulationScreenState extends State<DigitalTwinSimulationScreen> {
  DigitalTwinManifest? _manifest;
  ConstructionStageController? _stages;
  BimSimulationController? _bim;
  final NarrationController _narration = NarrationController();
  Timer? _tick;
  String? _selectedComponent;
  _TwinViewLayer _viewLayer = _TwinViewLayer.glb;

  bool get _hasProceduralBim => BimSceneRegistry.hasBimSimulation(widget.modelId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _narration.init();
    final m = await DigitalTwinEngine.loadManifest(widget.modelId);
    final stages = ConstructionStageController(m);
    stages.addListener(_onStageTick);
    _stages = stages;

    if (_hasProceduralBim) {
      final bim = BimSimulationController(modelId: widget.modelId);
      await bim.loadDefinition();
      bim.addListener(_syncBimStage);
      _bim = bim;
    }

    if (mounted) setState(() => _manifest = m);
  }

  void _syncBimStage() {
    final stages = _stages;
    final bim = _bim;
    if (stages == null || bim == null) return;
    if (bim.stageIndex != stages.stageIndex) {
      bim.setStage(stages.stageIndex);
    }
  }

  void _onStageTick() {
    final stages = _stages;
    if (stages == null) return;
    final stage = stages.currentStage;
    if (stage != null) {
      _narration.onStageEnter(stage, stages.stageProgress);
    }
    final bim = _bim;
    if (bim != null && bim.stageIndex != stages.stageIndex) {
      bim.setStage(stages.stageIndex);
    }
    if (mounted) setState(() {});
  }

  void _applyViewLayer(_TwinViewLayer layer) {
    setState(() => _viewLayer = layer);
    final bim = _bim;
    if (bim == null) return;
    switch (layer) {
      case _TwinViewLayer.glb:
        bim.viewMode = BimVisualizationMode.normal;
        bim.crossSectionEnabled = false;
      case _TwinViewLayer.structural:
        bim.viewMode = BimVisualizationMode.structural;
        bim.crossSectionEnabled = false;
      case _TwinViewLayer.exploded:
        bim.viewMode = BimVisualizationMode.exploded;
        bim.crossSectionEnabled = false;
      case _TwinViewLayer.crossSection:
        bim.viewMode = BimVisualizationMode.normal;
        bim.crossSectionEnabled = true;
      case _TwinViewLayer.loadTransfer:
        bim.viewMode = BimVisualizationMode.loadTransfer;
        bim.crossSectionEnabled = false;
    }
    bim.notifyListeners();
  }

  void _startTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _stages?.advance(0.05);
      _bim?.tick(0.05);
      _bim?.advanceEnvironmentalEffects(0.05);
    });
  }

  void _stopTicker() {
    _tick?.cancel();
    _tick = null;
  }

  @override
  void dispose() {
    _stages?.removeListener(_onStageTick);
    _bim?.removeListener(_syncBimStage);
    _bim?.dispose();
    _stopTicker();
    _narration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_manifest == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final m = _manifest!;
    final stages = _stages!;
    final stage = stages.currentStage;
    final showProcedural = _viewLayer != _TwinViewLayer.glb && _bim != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF4),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Digital Twin Mode', style: TextStyle(fontSize: 16)),
            Text(
              m.displayName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.warning_amber),
            tooltip: 'Hazard simulation',
            onSelected: (mode) {
              stages.setHazardMode(mode);
              if (mode == 'earthquake') {
                _bim?.viewMode = BimVisualizationMode.earthquake;
              } else if (mode == 'flood') {
                _bim?.viewMode = BimVisualizationMode.flood;
              } else if (mode == 'landslide') {
                _bim?.viewMode = BimVisualizationMode.landslide;
              } else {
                _bim?.viewMode = BimVisualizationMode.normal;
              }
              _bim?.notifyListeners();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'none', child: Text('Normal')),
              if (m.hazardSimulations.containsKey('earthquake'))
                const PopupMenuItem(value: 'earthquake', child: Text('Earthquake')),
              if (m.hazardSimulations.containsKey('flood'))
                const PopupMenuItem(value: 'flood', child: Text('Flood')),
              if (m.hazardSimulations.containsKey('wind'))
                const PopupMenuItem(value: 'wind', child: Text('Wind')),
              if (m.hazardSimulations.containsKey('landslide'))
                const PopupMenuItem(value: 'landslide', child: Text('Landslide')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: showProcedural
                ? BimViewport(controller: _bim!)
                : DigitalTwinViewport(controller: stages),
          ),
          if (_hasProceduralBim)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: _TwinViewLayer.values.map((layer) {
                  final selected = _viewLayer == layer;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_layerLabel(layer), style: const TextStyle(fontSize: 11)),
                      selected: selected,
                      onSelected: (_) => _applyViewLayer(layer),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (stage != null) ...[
                  Text(
                    stage.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.engineeringPrinciple,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section('Construction activity', stage.constructionActivity),
                  _section('Inspection checklist', stage.inspectionChecklist),
                  if (stage.commonMistakes.isNotEmpty)
                    _chips('Common mistakes', stage.commonMistakes, Colors.red.shade100),
                  if (stage.resilienceBenefits.isNotEmpty)
                    _chips(
                      'Resilience benefits',
                      stage.resilienceBenefits,
                      Colors.green.shade100,
                    ),
                ],
                if (_selectedComponent != null) ...[
                  const SizedBox(height: 12),
                  _ComponentCard(
                    componentId: _selectedComponent!,
                    docs: m.components,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: m.components.keys.map((id) {
                    return ActionChip(
                      label: Text(
                        id.replaceAll('_', ' '),
                        style: const TextStyle(fontSize: 10),
                      ),
                      onPressed: () => setState(() => _selectedComponent = id),
                    );
                  }).toList(),
                ),
                _TimelineControls(
                  controller: stages,
                  onPlayChanged: (playing) {
                    if (playing) {
                      if (!stages.isPlaying) stages.togglePlay();
                      _bim?.isPlaying = true;
                      _startTicker();
                    } else {
                      _stopTicker();
                      if (stages.isPlaying) stages.togglePlay();
                      _bim?.isPlaying = false;
                    }
                  },
                  onSpeedChanged: (s) {
                    stages.setPlaybackSpeed(s);
                    _bim?.playbackSpeed = s;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _layerLabel(_TwinViewLayer layer) => switch (layer) {
        _TwinViewLayer.glb => 'GLB 3D',
        _TwinViewLayer.structural => 'Structural',
        _TwinViewLayer.exploded => 'Exploded',
        _TwinViewLayer.crossSection => 'Cross-section',
        _TwinViewLayer.loadTransfer => 'Load path',
      };

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(body, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _chips(String title, List<String> items, Color bg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: items
              .map(
                (t) => Chip(
                  label: Text(t, style: const TextStyle(fontSize: 11)),
                  backgroundColor: bg,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TimelineControls extends StatelessWidget {
  const _TimelineControls({
    required this.controller,
    required this.onPlayChanged,
    required this.onSpeedChanged,
  });

  final ConstructionStageController controller;
  final void Function(bool playing) onPlayChanged;
  final void Function(double speed) onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final total = controller.manifest.stages.length;
    final value = total == 0 ? 0.0 : (controller.stageIndex + controller.stageProgress) / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Slider(
              value: value.clamp(0, 1),
              onChanged: (v) => controller.scrub(v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => onPlayChanged(!controller.isPlaying),
                ),
                Text(controller.currentStage?.timelineLabel ?? ''),
                const SizedBox(width: 12),
                DropdownButton<double>(
                  value: controller.playbackSpeed,
                  items: const [
                    DropdownMenuItem(value: 0.5, child: Text('0.5×')),
                    DropdownMenuItem(value: 1.0, child: Text('1×')),
                    DropdownMenuItem(value: 1.5, child: Text('1.5×')),
                    DropdownMenuItem(value: 2.0, child: Text('2×')),
                  ],
                  onChanged: (s) {
                    if (s != null) {
                      controller.setPlaybackSpeed(s);
                      onSpeedChanged(s);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.componentId, required this.docs});

  final String componentId;
  final Map<String, dynamic> docs;

  @override
  Widget build(BuildContext context) {
    final doc = docs[componentId] as Map<String, dynamic>?;
    if (doc == null) return const SizedBox.shrink();
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc['title']?.toString() ?? componentId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...doc.entries.where((e) => e.key != 'title').map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
