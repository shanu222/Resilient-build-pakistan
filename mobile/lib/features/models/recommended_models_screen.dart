import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/widgets/model_catalog_card.dart';
import '../../core/widgets/responsive_page.dart';
import '../../data/models/house_model.dart';
import '../../providers/app_providers.dart';

class RecommendedModelsScreen extends ConsumerStatefulWidget {
  const RecommendedModelsScreen({super.key});

  @override
  ConsumerState<RecommendedModelsScreen> createState() =>
      _RecommendedModelsScreenState();
}

class _RecommendedModelsScreenState extends ConsumerState<RecommendedModelsScreen> {
  final _search = TextEditingController();
  String _query = '';
  _CatalogFilter _filter = _CatalogFilter.recommended;
  String? _hazardFilter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<HouseModel> _filterModels(List<HouseModel> models) {
    var list = models;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where(
            (m) =>
                m.name.toLowerCase().contains(q) ||
                m.engineeringSummary.toLowerCase().contains(q) ||
                m.category.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_hazardFilter != null) {
      list = list.where((m) => m.hazardsCovered.contains(_hazardFilter)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final recommendedAsync = ref.watch(recommendedModelsProvider);
    final allAsync = ref.watch(housesProvider);
    final columns = AppBreakpoints.catalogColumns(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.heroGradient),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: AppBreakpoints.pagePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resilient model library',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: context.appTokens.textOnHero,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Engineered housing systems for Pakistan\'s hazard context',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.appTokens.textOnHeroMuted,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _search,
                        style: TextStyle(color: context.appTokens.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search models…',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _search.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResponsivePage(
              scrollable: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  SegmentedButton<_CatalogFilter>(
                    segments: const [
                      ButtonSegment(
                        value: _CatalogFilter.recommended,
                        label: Text('Recommended'),
                        icon: Icon(Icons.recommend, size: 18),
                      ),
                      ButtonSegment(
                        value: _CatalogFilter.all,
                        label: Text('Full catalog'),
                        icon: Icon(Icons.grid_view, size: 18),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (s) => setState(() => _filter = s.first),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All hazards'),
                          selected: _hazardFilter == null,
                          onSelected: (_) => setState(() => _hazardFilter = null),
                        ),
                        ...['Flood', 'Earthquake', 'Wind', 'Landslide'].map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(h),
                              selected: _hazardFilter == h,
                              onSelected: (_) => setState(
                                () => _hazardFilter = _hazardFilter == h ? null : h,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _filter == _CatalogFilter.recommended
              ? _buildGrid(recommendedAsync, columns)
              : _buildGrid(allAsync, columns),
        ],
      ),
    );
  }

  Widget _buildGrid(AsyncValue<List<HouseModel>> async, int columns) {
    return async.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
      data: (models) {
        final filtered = _filterModels(models);
        if (filtered.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No models match your filters')),
          );
        }
        return SliverPadding(
          padding: AppBreakpoints.pagePadding(context),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 0.72 : 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final m = filtered[i];
                return ModelCatalogCard(
                  modelId: m.id,
                  name: m.name,
                  description: m.engineeringSummary,
                  thumbnailAsset: m.resolvedThumbnailAsset,
                  thumbnailPngFallback: m.thumbnailPngFallback,
                  thumbnailGradient: m.thumbnailGradient,
                  resilienceScore: m.resilienceScore,
                  costLabel: m.costCategory,
                  difficulty: m.complexity,
                  hazardTags: m.hazardsCovered,
                  onTap: () => context.push('/model/${m.id}'),
                );
              },
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }
}

enum _CatalogFilter { recommended, all }
