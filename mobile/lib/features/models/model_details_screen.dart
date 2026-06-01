import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/house_model.dart';
import '../../data/models/resilience_dimensions.dart';
import '../bim_simulation/engine/bim_scene_registry.dart';
import '../../providers/app_providers.dart';
import '../pdf/pdf_viewer_screen.dart';

class ModelDetailsScreen extends ConsumerStatefulWidget {
  const ModelDetailsScreen({super.key, required this.modelId});

  final String modelId;

  @override
  ConsumerState<ModelDetailsScreen> createState() => _ModelDetailsScreenState();
}

class _ModelDetailsScreenState extends ConsumerState<ModelDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final houseAsync = ref.watch(houseByIdProvider(widget.modelId));
    final scoresAsync = ref.watch(resilienceScoresProvider(widget.modelId));

    return houseAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (house) {
        if (house == null) {
          return const Scaffold(body: Center(child: Text('Model not found')));
        }
        final c1 = Color(int.parse(house.thumbnailGradient[0].replaceFirst('#', '0xFF')));
        final c2 = Color(int.parse(house.thumbnailGradient[1].replaceFirst('#', '0xFF')));

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [c1, c2])),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.home_work, size: 100, color: Colors.white.withValues(alpha: 0.5)),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.success,
                            child: Text(
                              '${house.resilienceScore}%',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Engineering'),
                    Tab(text: 'Materials'),
                    Tab(text: 'Build'),
                    Tab(text: 'Files'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _overviewTab(house, scoresAsync),
                _engineeringTab(house),
                _materialsTab(house),
                _constructionTab(house),
                _downloadsTab(house),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: 'Start Construction Guide',
                icon: Icons.chevron_right,
                    onPressed: () {
                      final path = BimSceneRegistry.hasBimSimulation(house.id)
                          ? '/bim/${house.id}'
                          : '/construction/${house.id}';
                      context.push(path);
                    },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _overviewTab(HouseModel house, AsyncValue<ResilienceDimensions> scoresAsync) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(house.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: house.hazardsCovered.map((h) => Chip(label: Text(h))).toList(),
        ),
        const SizedBox(height: 16),
        scoresAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (scores) => SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: scores.entries.map((e) {
                return SizedBox(
                  width: 90,
                  child: SfRadialGauge(
                    axes: [
                      RadialAxis(
                        maximum: 100,
                        showLabels: false,
                        showTicks: false,
                        pointers: [
                          RangePointer(value: e.value.toDouble(), color: AppColors.orange),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Text('${e.value}', style: const TextStyle(fontSize: 12)),
                            angle: 90,
                            positionFactor: 0.2,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        _section('Advantages', Icons.check_circle, AppColors.success, house.advantages),
        _section('Limitations', Icons.cancel, AppColors.orange, house.limitations, bullet: '!'),
        _section('Resilience Features', Icons.shield, AppColors.navy, house.resilienceFeatures),
      ],
    );
  }

  Widget _engineeringTab(HouseModel house) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(house.engineeringSummary),
          ),
        ),
      ],
    );
  }

  Widget _materialsTab(HouseModel house) {
    return FutureBuilder(
      future: ref.read(jsonRepoProvider).getMaterials(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final all = snap.data!['materials'] as List;
        final filtered =
            all.where((m) => house.materialIds.contains(m['id'])).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final m = filtered[i] as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(m['name'] as String),
                subtitle: Text(m['engineeringPurpose'] as String),
              ),
            );
          },
        );
      },
    );
  }

  Widget _constructionTab(HouseModel house) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Duration: ${house.constructionDurationDays} days'),
                Text('Total cost: PKR ${house.totalEstimatedCostPkr}'),
                Text('Category: ${house.costCategory}'),
                const SizedBox(height: 12),
                const Text('11-stage BIM simulation in Construction Guide.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _downloadsTab(HouseModel house) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PdfViewerScreen(
                  assetPath: house.pdfAsset,
                  title: house.name,
                ),
              ),
            );
          },
          child: const Text('Construction Guidelines PDF'),
        ),
      ],
    );
  }

  Widget _section(String title, IconData icon, Color color, List<String> items,
      {String bullet = '✓'}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$bullet ', style: TextStyle(color: color)),
                    Expanded(child: Text(a, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
