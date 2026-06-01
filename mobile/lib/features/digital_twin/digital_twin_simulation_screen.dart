import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../bim_simulation/engine/bim_scene_registry.dart';
import '../bim_simulation/ui/bim_simulation_screen.dart';
import '../construction/construction_guide_screen.dart';
import 'construction_stage_controller.dart';
import 'digital_twin_engine.dart';
import 'digital_twin_viewport.dart';
import 'domain/digital_twin_manifest.dart';
import 'narration_controller.dart';

/// BIM 4D screen using generated GLB assets + procedural fallback.
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
  final NarrationController _narration = NarrationController();
  Timer? _tick;
  String? _selectedComponent;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _narration.init();
    final m = await DigitalTwinEngine.loadManifest(widget.modelId);
    final stages = ConstructionStageController(m);
    stages.addListener(_onTick);
    _stages = stages;
    if (mounted) setState(() => _manifest = m);
  }

  void _onTick() {
    final stages = _stages;
    if (stages == null) return;
    final stage = stages.currentStage;
    if (stage != null) {
      _narration.onStageEnter(stage, stages.stageProgress);
    }
    if (mounted) setState(() {});
  }

  void _startTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _stages?.advance(0.05);
    });
  }

  void _stopTicker() {
    _tick?.cancel();
    _tick = null;
  }

  @override
  void dispose() {
    _stages?.removeListener(_onTick);
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

    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF4),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BIM 4D Digital Twin', style: TextStyle(fontSize: 16)),
            Text(m.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.warning_amber),
            tooltip: 'Hazard simulation',
            onSelected: stages.setHazardMode,
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
            height: MediaQuery.of(context).size.height * 0.42,
            child: DigitalTwinViewport(controller: stages),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (stage != null) ...[
                  Text(stage.engineeringPrinciple,
                      style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.mutedForeground)),
                  const SizedBox(height: 12),
                  _section('Construction activity', stage.constructionActivity),
                  _section('Inspection checklist', stage.inspectionChecklist),
                  if (stage.commonMistakes.isNotEmpty)
                    _chips('Common mistakes', stage.commonMistakes, Colors.red.shade100),
                  if (stage.resilienceBenefits.isNotEmpty)
                    _chips('Resilience benefits', stage.resilienceBenefits, Colors.green.shade100),
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
                      label: Text(id.replaceAll('_', ' '), style: const TextStyle(fontSize: 10)),
                      onPressed: () => setState(() => _selectedComponent = id),
                    );
                  }).toList(),
                ),
                _TimelineControls(
                  controller: stages,
                  onPlayChanged: (playing) {
                    if (playing) {
                      stages.togglePlay();
                      _startTicker();
                    } else {
                      _stopTicker();
                      if (stages.isPlaying) stages.togglePlay();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          children: items.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 11)), backgroundColor: bg)).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TimelineControls extends StatelessWidget {
  const _TimelineControls({required this.controller, required this.onPlayChanged});

  final ConstructionStageController controller;
  final void Function(bool playing) onPlayChanged;

  @override
  Widget build(BuildContext context) {
    final total = controller.manifest.stages.length;
    final value = (controller.stageIndex + controller.stageProgress) / total;

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
            Text(doc['title']?.toString() ?? componentId,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ...doc.entries.where((e) => e.key != 'title').map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 12)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
