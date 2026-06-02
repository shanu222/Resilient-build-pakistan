import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/model_thumbnail.dart';
import '../../core/widgets/responsive_page.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/house_model.dart';
import '../../data/models/resilience_dimensions.dart';
import '../../providers/app_providers.dart';
import '../library/engineering_manual_screen.dart';
import '../pdf/pdf_viewer_screen.dart';

class ModelDetailsScreen extends ConsumerWidget {
  const ModelDetailsScreen({super.key, required this.modelId});

  final String modelId;

  static const _timelineStages = [
    'Site layout',
    'Excavation',
    'Foundation',
    'Reinforcement',
    'Columns',
    'Beams',
    'Walls',
    'Openings',
    'Bands',
    'Roof structure',
    'Roof cover',
    'Finishing',
    'Complete',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseAsync = ref.watch(houseByIdProvider(modelId));
    final scoresAsync = ref.watch(resilienceScoresProvider(modelId));

    return houseAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (house) {
        if (house == null) {
          return const Scaffold(body: Center(child: Text('Model not found')));
        }
        return _ModelDetailBody(house: house, scoresAsync: scoresAsync);
      },
    );
  }
}

class _ModelDetailBody extends StatelessWidget {
  const _ModelDetailBody({required this.house, required this.scoresAsync});

  final HouseModel house;
  final AsyncValue<ResilienceDimensions> scoresAsync;

  @override
  Widget build(BuildContext context) {
    final c1 = Color(int.parse(house.thumbnailGradient[0].replaceFirst('#', '0xFF')));
    final c2 = Color(int.parse(house.thumbnailGradient[1].replaceFirst('#', '0xFF')));
    final isWide = AppBreakpoints.isDesktop(context);
    final columns = isWide ? 3 : 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(house: house, c1: c1, c2: c2),
          ),
          SliverToBoxAdapter(
            child: ResponsivePage(
              scrollable: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _MetaChip(Icons.category_outlined, house.category),
                      _MetaChip(Icons.payments_outlined, house.costCategory),
                      _MetaChip(Icons.construction_outlined, house.complexity),
                      _MetaChip(Icons.schedule, '${house.constructionDurationDays} days'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Resilience performance',
                    subtitle: 'Engineering scores across hazard dimensions',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  scoresAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (scores) => GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: isWide ? 1.6 : 1.4,
                      children: scores.entries.toList().asMap().entries.map((e) {
                        return AnimatedFadeSlide(
                          index: e.key,
                          child: _ResilienceScoreCard(
                            label: e.value.key,
                            score: e.value.value,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Hazard suitability',
                    subtitle: 'Primary hazards this model is engineered to resist',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  scoresAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (scores) => _HazardPerformanceSection(
                      house: house,
                      scores: scores,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Construction timeline',
                    subtitle: '15-stage engineering Digital Twin — 8×6 m interlocking hollow block house',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TimelinePreview(stages: ModelDetailsScreen._timelineStages),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Engineering overview',
                    subtitle: 'Structural system and construction approach',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Text(
                        house.engineeringSummary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BulletSection(
                    title: 'Advantages',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                    items: house.advantages,
                  ),
                  _BulletSection(
                    title: 'Limitations',
                    icon: Icons.info_outline,
                    color: AppColors.orange,
                    items: house.limitations,
                  ),
                  _BulletSection(
                    title: 'Resilience features',
                    icon: Icons.shield_outlined,
                    color: AppColors.navy,
                    items: house.resilienceFeatures,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => EngineeringManualScreen(
                            initialSearch: house.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Engineering guidelines (manual)'),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _DigitalTwinCta(houseId: house.id),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.house, required this.c1, required this.c2});

  final HouseModel house;
  final Color c1;
  final Color c2;

  static double _heroHeight(BuildContext context) {
    if (AppBreakpoints.isDesktop(context)) return 320;
    if (AppBreakpoints.isTablet(context)) return 280;
    return 220;
  }

  @override
  Widget build(BuildContext context) {
    final height = _heroHeight(context);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ModelThumbnail(
            modelId: house.id,
            thumbnailAsset: house.resolvedThumbnailAsset,
            thumbnailPngFallback: house.thumbnailPngFallback,
            gradientFallback: [c1, c2],
            fit: BoxFit.cover,
            animate: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: AppBreakpoints.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IconButton(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              house.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: house.hazardsCovered
                                  .map(
                                    (h) => Chip(
                                      label: Text(h, style: const TextStyle(fontSize: 11)),
                                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                                      labelStyle: const TextStyle(color: Colors.white),
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${house.resilienceScore}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Resilience',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResilienceScoreCard extends StatelessWidget {
  const _ResilienceScoreCard({required this.label, required this.score});

  final String label;
  final int score;

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.orange;
    return AppColors.hazard;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            Text(
              '$score%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                color: _color,
                backgroundColor: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HazardPerformanceSection extends StatelessWidget {
  const _HazardPerformanceSection({required this.house, required this.scores});

  final HouseModel house;
  final ResilienceDimensions scores;

  @override
  Widget build(BuildContext context) {
    final items = <(String, int, bool)>[
      ('Flood', scores.floodResistance, house.hazardsCovered.any((h) => h.toLowerCase().contains('flood'))),
      ('Earthquake', scores.earthquakeResistance, house.hazardsCovered.any((h) => h.toLowerCase().contains('earth'))),
      ('Wind', scores.windResistance, house.hazardsCovered.any((h) => h.toLowerCase().contains('wind'))),
      ('Landslide', scores.landslideResistance, house.hazardsCovered.any((h) => h.toLowerCase().contains('land'))),
    ];

    return Column(
      children: items.asMap().entries.map((e) {
        final (name, score, covered) = e.value;
        return AnimatedFadeSlide(
          index: e.key,
          child: Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Icon(
                    covered ? Icons.verified : Icons.remove_circle_outline,
                    color: covered ? AppColors.success : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: Theme.of(context).textTheme.titleSmall),
                            Text(
                              covered ? '$score%' : 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: covered ? AppColors.navy : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        if (covered) ...[
                          const SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: score / 100,
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.orange,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimelinePreview extends StatelessWidget {
  const _TimelinePreview({required this.stages});

  final List<String> stages;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: stages.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) {
              return AnimatedFadeSlide(
                index: i,
                delayMs: 30,
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: i == stages.length - 1
                        ? AppColors.successLight
                        : AppColors.muted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: i == stages.length - 1 ? AppColors.success : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: i == stages.length - 1 ? AppColors.success : AppColors.navy,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          stages[i],
                          style: const TextStyle(fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 6, color: color),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.navy),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
    );
  }
}

class _DigitalTwinCta extends StatelessWidget {
  const _DigitalTwinCta({required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/bim/$houseId'),
              icon: const Icon(Icons.view_in_ar, size: 24),
              label: const Text(
                'Enter Digital Twin Mode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
