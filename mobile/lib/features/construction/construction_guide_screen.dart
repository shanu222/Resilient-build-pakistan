import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../bim_simulation/engine/bim_scene_registry.dart';
import '../bim_simulation/ui/bim_simulation_screen.dart';
import 'model_viewer_widget.dart';

class ConstructionGuideScreen extends ConsumerStatefulWidget {
  const ConstructionGuideScreen({super.key, required this.modelId});

  final String modelId;

  @override
  ConsumerState<ConstructionGuideScreen> createState() =>
      _ConstructionGuideScreenState();
}

class _ConstructionGuideScreenState
    extends ConsumerState<ConstructionGuideScreen> {
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
    if (BimSceneRegistry.hasBimSimulation(widget.modelId)) {
      return BimSimulationScreen(modelId: widget.modelId);
    }

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
                  title: Text(
                    house.name,
                    style: const TextStyle(fontSize: 14),
                  ),
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
                      const Text(
                        'Interactive Construction Guide',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              ModelViewerWidget(
                                modelPath: modelPath,
                                stageName: stage['name'] as String,
                                explodedView: sim.explodedView,
                                crossSection: sim.crossSection,
                                viewMode: sim.viewMode.name,
                                onComponentTap: (id) =>
                                    context.push('/engineering/$id'),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    _iconBtn(Icons.rotate_right, () {}),
                                    _iconBtn(
                                      sim.explodedView
                                          ? Icons.layers
                                          : Icons.layers_outlined,
                                      () => ref
                                          .read(constructionSimulationProvider
                                              .notifier)
                                          .toggleExploded(),
                                    ),
                                    _iconBtn(
                                      Icons.architecture,
                                      () => context.push('/engineering/column'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _viewChip('Structural', SimulationViewMode.structural),
                          _viewChip('Materials', SimulationViewMode.materials),
                          _viewChip('Normal', SimulationViewMode.normal),
                        ],
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(stage['name'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(stage['duration'] as String,
                                      style: const TextStyle(
                                          color: AppColors.mutedForeground)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(value: progress),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: sim.currentStageIndex > 0
                                        ? () => ref
                                            .read(constructionSimulationProvider
                                                .notifier)
                                            .setStage(sim.currentStageIndex - 1)
                                        : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  FloatingActionButton.large(
                                    onPressed: _togglePlay,
                                    backgroundColor: AppColors.orange,
                                    child: Icon(
                                      sim.isPlaying ? Icons.pause : Icons.play_arrow,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: sim.currentStageIndex <
                                            _stages.length - 1
                                        ? () => ref
                                            .read(constructionSimulationProvider
                                                .notifier)
                                            .setStage(sim.currentStageIndex + 1)
                                        : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Playback Speed'),
                                  Expanded(
                                    child: Slider(
                                      value: sim.playbackSpeed,
                                      min: 0.5,
                                      max: 2,
                                      divisions: 3,
                                      label: '${sim.playbackSpeed}x',
                                      onChanged: (v) => ref
                                          .read(constructionSimulationProvider
                                              .notifier)
                                          .setSpeed(v),
                                    ),
                                  ),
                                  Text('${sim.playbackSpeed}x'),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => ref
                                    .read(constructionSimulationProvider.notifier)
                                    .reset(),
                                icon: const Icon(Icons.replay),
                                label: const Text('Reset'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Text('Construction Timeline',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List.generate(_stages.length, (i) {
                        final p = _stages[i];
                        final active = i == sim.currentStageIndex;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: active ? AppColors.orange : AppColors.border,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            onTap: () => ref
                                .read(constructionSimulationProvider.notifier)
                                .setStage(i),
                            leading: CircleAvatar(
                              radius: 6,
                              backgroundColor: Color(
                                int.parse(
                                  (p['color'] as String).replaceFirst('#', '0xFF'),
                                ),
                              ),
                            ),
                            title: Text(p['name'] as String),
                            trailing: i < sim.currentStageIndex
                                ? const Icon(Icons.check, color: AppColors.success)
                                : Text(p['duration'] as String,
                                    style: const TextStyle(fontSize: 12)),
                          ),
                        );
                      }),
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phase Details: ${stage['name']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap any component in the 3D view to see engineering specifications, failure modes, and inspection checklists.',
                                style: TextStyle(
                                    color: AppColors.mutedForeground, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () =>
                                    context.push('/engineering/column'),
                                child: const Text('View Engineering Details'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
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

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _viewChip(String label, SimulationViewMode mode) {
    final sim = ref.watch(constructionSimulationProvider);
    final selected = sim.viewMode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: selected,
        onSelected: (_) =>
            ref.read(constructionSimulationProvider.notifier).setViewMode(mode),
      ),
    );
  }
}
