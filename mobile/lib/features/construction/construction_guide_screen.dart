import 'dart:async';

import 'package:flutter/material.dart';
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
    extends ConsumerState<LegacyConstructionGuideScreen> {
  List<Map<String, dynamic>> _stages = [];
  Timer? _playTimer;

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
    _playTimer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    final sim = ref.read(constructionSimulationProvider);
    if (sim.isPlaying) {
      _playTimer?.cancel();
      ref.read(constructionSimulationProvider.notifier).togglePlay();
      return;
    }
    ref.read(constructionSimulationProvider.notifier).togglePlay();
    _playTimer = Timer.periodic(
      Duration(milliseconds: (1500 / sim.playbackSpeed).round()),
      (_) {
        final s = ref.read(constructionSimulationProvider);
        if (s.currentStageIndex >= _stages.length - 1) {
          _playTimer?.cancel();
          ref.read(constructionSimulationProvider.notifier).togglePlay();
          return;
        }
        ref
            .read(constructionSimulationProvider.notifier)
            .setStage(s.currentStageIndex + 1);
      },
    );
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
