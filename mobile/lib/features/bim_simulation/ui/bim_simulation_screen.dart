import 'package:flutter/material.dart';

import '../engine/bim_simulation_controller.dart';
import '../services/bim_narration_service.dart';
import 'bim_engineering_workspace.dart';

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
    return BimEngineeringWorkspace(controller: _controller);
  }
}
