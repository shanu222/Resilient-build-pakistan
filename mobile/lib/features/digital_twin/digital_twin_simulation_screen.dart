import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../bim_simulation/engine/bim_scene_registry.dart';
import '../bim_simulation/engine/bim_simulation_controller.dart';
import '../bim_simulation/engine/bim_visualization_mode.dart';
import '../construction/construction_guide_screen.dart';
import 'construction_stage_controller.dart';
import 'digital_twin_engine.dart';
import 'domain/bim_component_registry.dart';
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
  BimComponentRegistry? _registry;
  final NarrationController _narration = NarrationController();
  late final Ticker _ticker;
  Duration? _lastTick;
  String? _selectedComponent;
  TwinViewLayer _viewLayer = TwinViewLayer.structural;
  double _hazardAnimPhase = 0;

  bool get _hasProceduralBim => BimSceneRegistry.hasBimSimulation(widget.modelId);

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
    _load();
  }

  void _onTick(Duration elapsed) {
    final stages = _stages;
    if (!mounted || stages == null) return;
    if (_lastTick == null) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;

    // Runtime FPS estimate (best-effort, for HUD).
    stages.reportFrameTime(dt);

    // Playback simulation (single source of truth is ConstructionStageController).
    stages.advance(dt);

    // Hazard overlay animation should not interrupt playback.
    if (stages.hazardMode != 'none') {
      _hazardAnimPhase = (_hazardAnimPhase + dt * 0.30) % 1.0;
    }

    // BIM environmental effects (procedural viewport is already ticker-driven internally,
    // but these effects are lightweight and should follow the same dt).
    _bim?.advanceEnvironmentalEffects(dt);

    // Sync BIM + narration to stage state.
    _onStageTick();
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
      bim.addListener(_syncBimSelection);
      _bim = bim;
    }

    if (mounted) {
      _registry = _bim != null
          ? BimComponentRegistry.fromProceduralBim(_bim!)
          : BimComponentRegistry.fromManifest(m);
      setState(() => _manifest = m);
      if (_hasProceduralBim) {
        _applyViewLayer(TwinViewLayer.structural);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final size = MediaQuery.sizeOf(context);
          _bim?.fitCamera(
            viewportWidth: size.width,
            viewportHeight: size.height * 0.55,
          );
        });
      }
      _lastTick = null;
      _ticker.start();
    }
  }

  void _syncBimStage() {
    final stages = _stages;
    final bim = _bim;
    if (stages == null || bim == null) return;
    if (bim.stageIndex != stages.stageIndex ||
        (bim.stageProgress - stages.stageProgress).abs() > 0.02) {
      bim.setStage(stages.stageIndex, progress: stages.stageProgress);
    }
  }

  void _syncBimSelection() {
    final bim = _bim;
    if (bim == null) return;
    final picked = bim.selectedComponentId;
    if (picked != null && picked != _selectedComponent) {
      setState(() => _selectedComponent = picked);
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
    if (bim != null) {
      bim.setStage(stages.stageIndex, progress: stages.stageProgress);
      bim.isPlaying = stages.isPlaying;
      bim.playbackSpeed = stages.playbackSpeed;
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
        bim.showStructuralGrid = false;
      case TwinViewLayer.structural:
        bim.viewMode = BimVisualizationMode.structural;
        bim.crossSectionEnabled = false;
        bim.showStructuralGrid = false;
      case TwinViewLayer.exploded:
        bim.viewMode = BimVisualizationMode.exploded;
        bim.crossSectionEnabled = false;
        bim.showStructuralGrid = false;
      case TwinViewLayer.crossSection:
        bim.viewMode = BimVisualizationMode.normal;
        bim.crossSectionEnabled = true;
        bim.showStructuralGrid = false;
      case TwinViewLayer.loadTransfer:
        bim.viewMode = BimVisualizationMode.loadTransfer;
        bim.crossSectionEnabled = false;
        bim.showStructuralGrid = false;
      case TwinViewLayer.connections:
        bim.viewMode = BimVisualizationMode.connection;
        bim.crossSectionEnabled = false;
        bim.showStructuralGrid = false;
      case TwinViewLayer.grid:
        bim.viewMode = BimVisualizationMode.normal;
        bim.crossSectionEnabled = false;
        bim.showStructuralGrid = true;
      case TwinViewLayer.blockAssembly:
        bim.viewMode = BimVisualizationMode.blockAssembly;
        bim.crossSectionEnabled = false;
        bim.showStructuralGrid = false;
    }
    bim.notifyListeners();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _stages?.removeListener(_onStageTick);
    _bim?.removeListener(_syncBimStage);
    _bim?.removeListener(_syncBimSelection);
    _bim?.dispose();
    _ticker.dispose();
    _narration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_manifest == null || _stages == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showProcedural = _viewLayer != TwinViewLayer.glb && _bim != null;

    final stages = _stages!;

    Widget child = DigitalTwinWorkspace(
      manifest: _manifest!,
      stages: stages,
      registry: _registry,
      hazardAnimPhase: _hazardAnimPhase,
      viewLayer: _viewLayer,
      onViewLayerChanged: _applyViewLayer,
      showProcedural: showProcedural,
      bim: _bim,
      selectedComponent: _selectedComponent,
      onComponentSelected: (id) {
        setState(() => _selectedComponent = id);
        _bim?.selectComponent(id);
      },
      onPlayChanged: (playing) {
        if (playing) {
          stages.play();
        } else {
          stages.pause();
        }
        _bim?.isPlaying = stages.isPlaying;
      },
      onSpeedChanged: (s) {
        stages.setPlaybackSpeed(s);
        _bim?.playbackSpeed = s;
      },
      onHazardSelected: (mode) {
        stages.setHazardMode(mode);
        _hazardAnimPhase = 0;
        final bim = _bim;
        if (bim == null) return;
        switch (mode) {
          case 'earthquake':
            bim.viewMode = BimVisualizationMode.earthquake;
          case 'wind':
            bim.viewMode = BimVisualizationMode.wind;
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

    // Desktop keyboard shortcuts.
    // Build stability is higher priority than shortcuts; disable on Web if toolchain rejects key constants.
    if (!kIsWeb) {
      child = Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft):
              const DirectionalFocusIntent(TraversalDirection.left),
          SingleActivator(LogicalKeyboardKey.arrowRight):
              const DirectionalFocusIntent(TraversalDirection.right),
          SingleActivator(LogicalKeyboardKey.keyR): const _RestartIntent(),
          SingleActivator(LogicalKeyboardKey.keyF): const _FitIntent(),
          SingleActivator(LogicalKeyboardKey.keyG): const _GridIntent(),
          SingleActivator(LogicalKeyboardKey.keyE): const _ExplodedIntent(),
          SingleActivator(LogicalKeyboardKey.keyS): const _SectionIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                if (stages.isPlaying) {
                  stages.pause();
                } else {
                  stages.play();
                }
                _bim?.isPlaying = stages.isPlaying;
                return null;
              },
            ),
            DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
              onInvoke: (intent) {
                if (intent.direction == TraversalDirection.left) {
                  stages.previousStage();
                } else if (intent.direction == TraversalDirection.right) {
                  stages.nextStage();
                }
                return null;
              },
            ),
            _RestartIntent: CallbackAction<_RestartIntent>(
              onInvoke: (_) {
                stages.restart();
                return null;
              },
            ),
            _FitIntent: CallbackAction<_FitIntent>(
              onInvoke: (_) {
                final bim = _bim;
                if (bim == null) return null;
                final size = MediaQuery.sizeOf(context);
                bim.fitCamera(viewportWidth: size.width, viewportHeight: size.height);
                return null;
              },
            ),
            _GridIntent: CallbackAction<_GridIntent>(
              onInvoke: (_) {
                _bim?.toggleStructuralGrid();
                return null;
              },
            ),
            _ExplodedIntent: CallbackAction<_ExplodedIntent>(
              onInvoke: (_) {
                _applyViewLayer(TwinViewLayer.exploded);
                return null;
              },
            ),
            _SectionIntent: CallbackAction<_SectionIntent>(
              onInvoke: (_) {
                _applyViewLayer(TwinViewLayer.crossSection);
                return null;
              },
            ),
          },
          child: Focus(autofocus: true, child: child),
        ),
      );
    }

    return child;
  }
}

class _RestartIntent extends Intent {
  const _RestartIntent();
}

class _FitIntent extends Intent {
  const _FitIntent();
}

class _GridIntent extends Intent {
  const _GridIntent();
}

class _ExplodedIntent extends Intent {
  const _ExplodedIntent();
}

class _SectionIntent extends Intent {
  const _SectionIntent();
}
