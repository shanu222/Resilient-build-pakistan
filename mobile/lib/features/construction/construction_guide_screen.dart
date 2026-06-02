import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../bim_simulation/engine/bim_scene_registry.dart';
import '../bim_simulation/ui/bim_simulation_screen.dart';
import '../digital_twin/digital_twin_simulation_screen.dart';
import 'model_viewer_widget.dart';

/// Construction guide — GLB digital twin → procedural BIM → legacy GLB placeholder.
class ConstructionGuideScreen extends StatelessWidget {
  const ConstructionGuideScreen({super.key, required this.modelId});

  final String modelId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: DigitalTwinSimulationScreen.forModel(modelId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.data!;
      },
    );
  }
}

/// Legacy non-BIM construction UI (GLB path placeholders).
class LegacyConstructionGuideScreen extends ConsumerStatefulWidget {
  const LegacyConstructionGuideScreen({super.key, required this.modelId});

  final String modelId;

  @override
  ConsumerState<LegacyConstructionGuideScreen> createState() =>
      _LegacyConstructionGuideScreenState();
}

class _LegacyConstructionGuideScreenState
    extends ConsumerState<LegacyConstructionGuideScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _stages = [];
  Ticker? _playTicker;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

  Future<void> _loadStages() async {
    final steps = await ref.read(jsonRepoProvider).getConstructionSteps();
    final standard = (steps['standardStages'] as List).cast<Map<String, dynamic>>();
    setState(() => _stages = standard);
  }

  @override
  void dispose() {
    _playTicker?.dispose();
    super.dispose();
  }

  void _onPlayTick(Duration elapsed) {
    if (_lastTick == null) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final sim = ref.read(constructionSimulationProvider);
    final stepSec = (1.5 / sim.playbackSpeed).clamp(0.25, 8.0);
    _stageElapsed += dt;
    if (_stageElapsed < stepSec) return;
    _stageElapsed = 0;
    if (sim.currentStageIndex >= _stages.length - 1) {
      _stopPlayTicker();
      ref.read(constructionSimulationProvider.notifier).togglePlay();
      return;
    }
    ref
        .read(constructionSimulationProvider.notifier)
        .setStage(sim.currentStageIndex + 1);
  }

  double _stageElapsed = 0;

  void _stopPlayTicker() {
    _playTicker?.stop();
    _lastTick = null;
    _stageElapsed = 0;
  }

  void _togglePlay() {
    final sim = ref.read(constructionSimulationProvider);
    if (sim.isPlaying) {
      _stopPlayTicker();
      ref.read(constructionSimulationProvider.notifier).togglePlay();
      return;
    }
    ref.read(constructionSimulationProvider.notifier).togglePlay();
    _playTicker ??= createTicker(_onPlayTick);
    _lastTick = null;
    _stageElapsed = 0;
    _playTicker!.start();
  }

  @override
  Widget build(BuildContext context) {
    final houseAsync = ref.watch(houseByIdProvider(widget.modelId));
    final sim = ref.watch(constructionSimulationProvider);

    return houseAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (house) {
        if (house == null || _stages.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final stage = _stages[sim.currentStageIndex];
        final stageKey = stage['key'] as String;
        final modelPath =
            ref.read(jsonRepoProvider).getStageModelPath(house.id, stageKey);
        final progress = (sim.currentStageIndex + 1) / _stages.length;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 72,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(house.name, style: const TextStyle(fontSize: 14)),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.navy, AppColors.navyLight],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: ModelViewerWidget(
                            modelPath: modelPath,
                            stageName: stage['name'] as String,
                            explodedView: sim.explodedView,
                            crossSection: sim.crossSection,
                            viewMode: sim.viewMode.name,
                            onComponentTap: (id) =>
                                context.push('/engineering/$id'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: sim.currentStageIndex > 0
                                ? () => ref
                                    .read(constructionSimulationProvider.notifier)
                                    .setStage(sim.currentStageIndex - 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          FloatingActionButton(
                            onPressed: _togglePlay,
                            child: Icon(sim.isPlaying ? Icons.pause : Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: sim.currentStageIndex < _stages.length - 1
                                ? () => ref
                                    .read(constructionSimulationProvider.notifier)
                                    .setStage(sim.currentStageIndex + 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
