import 'dart:async';

import 'package:flutter/material.dart';

import '../bim_simulation/engine/bim_scene_registry.dart';
import '../bim_simulation/engine/bim_simulation_controller.dart';
import '../bim_simulation/engine/bim_visualization_mode.dart';
import '../bim_simulation/ui/bim_simulation_screen.dart';
import '../construction/construction_guide_screen.dart';
import 'construction_stage_controller.dart';
import 'digital_twin_engine.dart';
import 'domain/digital_twin_manifest.dart';
import 'narration_controller.dart';
import 'widgets/digital_twin_workspace.dart';

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
  Timer? _hazardTick;
  String? _selectedComponent;
  TwinViewLayer _viewLayer = TwinViewLayer.glb;
  double _hazardAnimPhase = 0;

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

    if (mounted) {
      setState(() => _manifest = m);
      _syncHazardTicker();
    }
  }

  void _syncHazardTicker() {
    _hazardTick?.cancel();
    if (_stages?.hazardMode != 'none') {
      _hazardTick = Timer.periodic(const Duration(milliseconds: 50), (_) {
        _hazardAnimPhase = (_hazardAnimPhase + 0.015) % 1.0;
        if (mounted) setState(() {});
      });
    }
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
    if (stages.hazardMode != 'none') {
      _hazardAnimPhase = (_hazardAnimPhase + 0.015) % 1.0;
    }
    if (mounted) setState(() {});
  }

  void _applyViewLayer(TwinViewLayer layer) {
    setState(() => _viewLayer = layer);
    final bim = _bim;
    if (bim == null) return;
    switch (layer) {
      case TwinViewLayer.glb:
        bim.viewMode = BimVisualizationMode.normal;
        bim.crossSectionEnabled = false;
      case TwinViewLayer.structural:
        bim.viewMode = BimVisualizationMode.structural;
        bim.crossSectionEnabled = false;
      case TwinViewLayer.exploded:
        bim.viewMode = BimVisualizationMode.exploded;
        bim.crossSectionEnabled = false;
      case TwinViewLayer.crossSection:
        bim.viewMode = BimVisualizationMode.normal;
        bim.crossSectionEnabled = true;
      case TwinViewLayer.loadTransfer:
        bim.viewMode = BimVisualizationMode.loadTransfer;
        bim.crossSectionEnabled = false;
    }
    if (mounted) setState(() {});
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
    _hazardTick?.cancel();
    _narration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_manifest == null || _stages == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showProcedural = _viewLayer != TwinViewLayer.glb && _bim != null;

    return DigitalTwinWorkspace(
      manifest: _manifest!,
      stages: _stages!,
      hazardAnimPhase: _hazardAnimPhase,
      viewLayer: _viewLayer,
      onViewLayerChanged: _applyViewLayer,
      showProcedural: showProcedural,
      bim: _bim,
      selectedComponent: _selectedComponent,
      onComponentSelected: (id) => setState(() => _selectedComponent = id),
      onPlayChanged: (playing) {
        final stages = _stages!;
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
        _stages!.setPlaybackSpeed(s);
        _bim?.playbackSpeed = s;
      },
      onHazardSelected: (mode) {
        _stages!.setHazardMode(mode);
        _hazardAnimPhase = 0;
        _syncHazardTicker();
        final bim = _bim;
        if (bim == null) return;
        switch (mode) {
          case 'earthquake':
            bim.viewMode = BimVisualizationMode.earthquake;
          case 'flood':
            bim.viewMode = BimVisualizationMode.flood;
          case 'landslide':
            bim.viewMode = BimVisualizationMode.landslide;
          default:
            bim.viewMode = BimVisualizationMode.normal;
        }
        if (mounted) setState(() {});
      },
    );
  }
}
