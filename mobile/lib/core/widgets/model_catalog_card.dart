import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class ModelCatalogCard extends StatelessWidget {
  const ModelCatalogCard({
    super.key,
    required this.modelId,
    required this.name,
    required this.description,
    this.imageAsset,
    this.resilienceScore,
    this.costLabel,
    this.difficulty,
    this.hazardTags = const [],
    this.onTap,
  });

  final String modelId;
  final String name;
  final String description;
  final String? imageAsset;
  final int? resilienceScore;
  final String? costLabel;
  final String? difficulty;
  final List<String> hazardTags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.push('/model/$modelId'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: _Thumbnail(asset: imageAsset, name: name),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hazardTags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: hazardTags
                          .take(3)
                          .map((h) => Chip(
                                label: Text(h),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (resilienceScore != null)
                        _Metric(
                          icon: Icons.shield_outlined,
                          label: 'Resilience',
                          value: '$resilienceScore%',
                          color: AppColors.success,
                        ),
                      if (costLabel != null) ...[
                        const SizedBox(width: 12),
                        _Metric(
                          icon: Icons.payments_outlined,
                          label: 'Cost',
                          value: costLabel!,
                          color: AppColors.navy,
                        ),
                      ],
                      if (difficulty != null) ...[
                        const SizedBox(width: 12),
                        _Metric(
                          icon: Icons.construction_outlined,
                          label: 'Level',
                          value: difficulty!,
                          color: AppColors.orange,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onTap ?? () => context.push('/model/$modelId'),
                      child: const Text('View details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.asset, required this.name});

  final String? asset;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.muted,
      child: asset != null
          ? Image.asset(
              asset!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyMid],
        ),
      ),
      child: Center(
        child: Icon(Icons.apartment_rounded, size: 48, color: Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontSize: 12,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
