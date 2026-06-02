import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/widgets/model_thumbnail.dart';
import '../../core/widgets/responsive_page.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/hazard_profile.dart';
import '../../data/models/house_model.dart';
import '../../providers/app_providers.dart';

class LocationAnalysisScreen extends ConsumerStatefulWidget {
  const LocationAnalysisScreen({super.key, required this.locationId});

  final String locationId;

  @override
  ConsumerState<LocationAnalysisScreen> createState() =>
      _LocationAnalysisScreenState();
}

class _LocationAnalysisScreenState extends ConsumerState<LocationAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = ref.read(locationProvider);
      if (loc.profile == null) {
        await ref.read(locationProvider.notifier).analyzeCurrent();
      }
    });
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'High':
        return AppColors.hazard;
      case 'Medium':
        return AppColors.orange;
      default:
        return AppColors.success;
    }
  }

  String _recommendationExplanation(HazardProfile profile) {
    final highHazards = profile.metrics.where((m) => m.score >= 60).map((m) => m.name).toList();
    if (highHazards.isEmpty) {
      return 'This district shows moderate hazard exposure. Models are ranked by regional suitability, resilience score, and construction practicality for Pakistan\'s diverse terrain.';
    }
    return 'Primary drivers: ${highHazards.join(', ')}. Recommended models prioritize structural systems proven for these hazards — elevated plinths, seismic bands, reinforced masonry, and flood-resilient foundations where applicable.';
  }

  String _terrainSummary(HazardProfile profile) {
    final slope = profile.terrainSlopePercent;
    if (slope >= 15) {
      return 'Steep terrain (${slope.toStringAsFixed(0)}% slope) — consider geogrid retaining, stepped foundations, and landslide-resistant detailing.';
    }
    if (slope >= 8) {
      return 'Moderate slope (${slope.toStringAsFixed(0)}%) — standard foundations with enhanced drainage and slope stability checks.';
    }
    return 'Relatively flat terrain (${slope.toStringAsFixed(0)}% slope) — suitable for conventional and elevated resilient systems with standard footing design.';
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locationProvider);
    final profile = loc.profile;
    final modelsAsync = ref.watch(recommendedModelsProvider);

    if (loc.isLoading || profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final columns = AppBreakpoints.isDesktop(context) ? 2 : 1;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _DistrictHero(profile: profile)),
          SliverToBoxAdapter(
            child: ResponsivePage(
              scrollable: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  AnimatedFadeSlide(
                    child: Builder(
                      builder: (context) {
                        final tokens = context.appTokens;
                        return Card(
                          color: AppColors.navy,
                          child: Padding(
                            padding: AppSpacing.cardPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall site suitability',
                                  style: TextStyle(
                                    color: tokens.textOnHeroMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${profile.suitabilityScore}%',
                                      style: TextStyle(
                                        color: tokens.textOnHero,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        profile.suitabilitySummary,
                                        style: TextStyle(
                                          color: tokens.textOnHeroMuted,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: profile.suitabilityScore / 100,
                                    minHeight: 8,
                                    backgroundColor: tokens.textOnHero.withValues(alpha: 0.24),
                                    color: AppColors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'District profile',
                    subtitle: 'Regional context for resilient construction planning',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedFadeSlide(
                    index: 1,
                    child: Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          children: [
                            _ProfileRow(Icons.map_outlined, 'Province / region', profile.regionName),
                            const Divider(height: AppSpacing.lg),
                            _ProfileRow(Icons.cloud_outlined, 'Climate zone', profile.climate),
                            const Divider(height: AppSpacing.lg),
                            _ProfileRow(Icons.terrain, 'Terrain summary', _terrainSummary(profile)),
                            const Divider(height: AppSpacing.lg),
                            _ProfileRow(Icons.water, 'River proximity', profile.riverProximityNote),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Hazard assessment',
                    subtitle: 'Multi-hazard scores driving model recommendations',
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: AppBreakpoints.pagePadding(context),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: columns == 2 ? 2.2 : 2.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final m = profile.metrics[i];
                  return AnimatedFadeSlide(
                    index: i,
                    child: _HazardScoreCard(metric: m, levelColor: _levelColor(m.level)),
                  );
                },
                childCount: profile.metrics.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResponsivePage(
              scrollable: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Recommendation logic',
                    subtitle: 'How models are ranked for this location',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedFadeSlide(
                    index: 2,
                    child: Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Text(
                          _recommendationExplanation(profile),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Recommended model ranking',
                    subtitle: 'Top resilient housing systems for this district',
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          modelsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              )),
            ),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('$e'))),
            data: (models) => SliverPadding(
              padding: AppBreakpoints.pagePadding(context),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i >= models.length.clamp(0, 5)) return null;
                    return AnimatedFadeSlide(
                      index: i,
                      child: _RankedModelTile(rank: i + 1, model: models[i]),
                    );
                  },
                  childCount: models.length.clamp(0, 5),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResponsivePage(
              scrollable: false,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  if (profile.historicalEvents.isNotEmpty) ...[
                    const SectionHeader(title: 'Historical events'),
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: profile.historicalEvents.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.history, size: 16, color: AppColors.orange),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: Text(e, style: Theme.of(context).textTheme.bodySmall)),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  PrimaryButton(
                    label: 'Explore full model catalog',
                    icon: Icons.chevron_right,
                    onPressed: () => context.push('/models'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistrictHero extends StatelessWidget {
  const _DistrictHero({required this.profile});

  final HazardProfile profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
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
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: tokens.textOnHero),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: tokens.textOnHero,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          profile.regionName,
                          style: TextStyle(color: tokens.textOnHeroMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  StatPill(
                    label: 'Suitability',
                    value: '${profile.suitabilityScore}%',
                    icon: Icons.verified_outlined,
                    color: AppColors.success,
                  ),
                  StatPill(
                    label: 'Terrain',
                    value: '${profile.terrainSlopePercent.toStringAsFixed(0)}% slope',
                    icon: Icons.terrain,
                    color: AppColors.navy,
                  ),
                  StatPill(
                    label: 'Coordinates',
                    value: '${profile.latitude.toStringAsFixed(2)}°, ${profile.longitude.toStringAsFixed(2)}°',
                    icon: Icons.place_outlined,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.orange),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.appTokens.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _HazardScoreCard extends StatelessWidget {
  const _HazardScoreCard({required this.metric, required this.levelColor});

  final HazardMetric metric;
  final Color levelColor;

  IconData _icon(String type) => switch (type) {
        'flood' => Icons.waves,
        'earthquake' => Icons.sensors,
        'landslide' => Icons.terrain,
        'glof' => Icons.water_drop,
        'wind' => Icons.air,
        _ => Icons.warning_amber_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(
                    int.parse(metric.colorHex.replaceFirst('#', '0xFF')),
                  ).withValues(alpha: 0.12),
                  child: Icon(
                    _icon(metric.type),
                    size: 18,
                    color: Color(int.parse(metric.colorHex.replaceFirst('#', '0xFF'))),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(metric.name, style: Theme.of(context).textTheme.titleSmall),
                ),
                Text(
                  metric.level,
                  style: TextStyle(color: levelColor, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '${metric.score}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: levelColor,
                      ),
                ),
                Text(' / 100', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: metric.score / 100,
              borderRadius: BorderRadius.circular(4),
              color: levelColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RankedModelTile extends StatelessWidget {
  const _RankedModelTile({required this.rank, required this.model});

  final int rank;
  final HouseModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/model/${model.id}'),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ModelThumbnail(
                        modelId: model.id,
                        thumbnailAsset: model.resolvedThumbnailAsset,
                        thumbnailPngFallback: model.thumbnailPngFallback,
                        fit: BoxFit.cover,
                        animate: false,
                      ),
                    ),
                    Positioned(
                      top: -4,
                      left: -4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            rank == 1 ? AppColors.orange : AppColors.navy,
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            color: context.appTokens.textOnPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(model.name, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      '${model.resilienceScore}% resilience · ${model.costCategory}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.appTokens.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
