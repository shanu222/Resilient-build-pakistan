import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'model_thumbnail.dart';

class ModelCatalogCard extends StatefulWidget {
  const ModelCatalogCard({
    super.key,
    required this.modelId,
    required this.name,
    required this.description,
    this.thumbnailAsset,
    this.thumbnailPngFallback,
    this.thumbnailGradient,
    this.resilienceScore,
    this.costLabel,
    this.difficulty,
    this.hazardTags = const [],
    this.onTap,
  });

  final String modelId;
  final String name;
  final String description;
  final String? thumbnailAsset;
  final String? thumbnailPngFallback;
  final List<String>? thumbnailGradient;
  final int? resilienceScore;
  final String? costLabel;
  final String? difficulty;
  final List<String> hazardTags;
  final VoidCallback? onTap;

  @override
  State<ModelCatalogCard> createState() => _ModelCatalogCardState();
}

class _ModelCatalogCardState extends State<ModelCatalogCard> {
  bool _hovered = false;

  List<Color>? get _gradientFallback {
    final g = widget.thumbnailGradient;
    if (g == null || g.length < 2) return null;
    return [
      Color(int.parse(g[0].replaceFirst('#', '0xFF'))),
      Color(int.parse(g[1].replaceFirst('#', '0xFF'))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enableHover = kIsWeb;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: _hovered ? 8 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _hovered ? AppColors.orange.withValues(alpha: 0.35) : AppColors.border,
        ),
      ),
      child: MouseRegion(
        onEnter: enableHover ? (_) => setState(() => _hovered = true) : null,
        onExit: enableHover ? (_) => setState(() => _hovered = false) : null,
        child: InkWell(
          onTap: widget.onTap ?? () => context.push('/model/${widget.modelId}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: AnimatedScale(
                  scale: _hovered ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ModelThumbnail(
                      modelId: widget.modelId,
                      thumbnailAsset: widget.thumbnailAsset,
                      thumbnailPngFallback: widget.thumbnailPngFallback,
                      gradientFallback: _gradientFallback,
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.hazardTags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.hazardTags
                            .take(3)
                            .map(
                              (h) => Chip(
                                label: Text(h),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.resilienceScore != null)
                          _Metric(
                            icon: Icons.shield_outlined,
                            label: 'Resilience',
                            value: '${widget.resilienceScore}%',
                            color: AppColors.success,
                          ),
                        if (widget.costLabel != null) ...[
                          const SizedBox(width: 12),
                          _Metric(
                            icon: Icons.payments_outlined,
                            label: 'Cost',
                            value: widget.costLabel!,
                            color: AppColors.navy,
                          ),
                        ],
                        if (widget.difficulty != null) ...[
                          const SizedBox(width: 12),
                          _Metric(
                            icon: Icons.construction_outlined,
                            label: 'Level',
                            value: widget.difficulty!,
                            color: AppColors.orange,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onTap ?? () => context.push('/model/${widget.modelId}'),
                        child: const Text('View details'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
