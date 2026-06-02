import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme_extensions.dart';
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
    final tokens = context.appTokens;
    final enableHover = kIsWeb;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: _hovered ? 8 : 2,
      shadowColor: tokens.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _hovered ? AppColors.orange.withValues(alpha: 0.35) : tokens.border,
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
                          color: tokens.shadow,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
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
                            iconColor: tokens.success,
                          ),
                        if (widget.costLabel != null) ...[
                          const SizedBox(width: 12),
                          _Metric(
                            icon: Icons.payments_outlined,
                            label: 'Cost',
                            value: widget.costLabel!,
                            iconColor: tokens.primary,
                          ),
                        ],
                        if (widget.difficulty != null) ...[
                          const SizedBox(width: 12),
                          _Metric(
                            icon: Icons.construction_outlined,
                            label: 'Level',
                            value: widget.difficulty!,
                            iconColor: tokens.warning,
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
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: tokens.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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
