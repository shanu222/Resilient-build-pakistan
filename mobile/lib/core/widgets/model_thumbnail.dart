import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// Exploded-view model preview with WebP → PNG → gradient placeholder fallback.
class ModelThumbnail extends StatefulWidget {
  const ModelThumbnail({
    super.key,
    required this.modelId,
    this.thumbnailAsset,
    this.thumbnailPngFallback,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.gradientFallback,
    this.animate = true,
  });

  final String modelId;
  final String? thumbnailAsset;
  final String? thumbnailPngFallback;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final List<Color>? gradientFallback;
  final bool animate;

  @override
  State<ModelThumbnail> createState() => _ModelThumbnailState();
}

class _ModelThumbnailState extends State<ModelThumbnail> {
  bool _usePngFallback = false;
  bool _showPlaceholder = false;

  String? get _primary =>
      widget.thumbnailAsset ?? 'assets/images/models/${widget.modelId}.webp';

  String get _png =>
      widget.thumbnailPngFallback ?? 'assets/images/models/${widget.modelId}.png';

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.zero;
    Widget child;

    if (_showPlaceholder) {
      child = _Placeholder(gradient: widget.gradientFallback);
    } else {
      final path = _usePngFallback ? _png : _primary!;
      child = Image.asset(
        path,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) {
          if (!_usePngFallback) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _usePngFallback = true);
            });
            return const SizedBox.expand();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showPlaceholder = true);
          });
          return const SizedBox.expand();
        },
      );
    }

    child = ClipRRect(borderRadius: radius, child: child);

    if (widget.animate) {
      child = child
          .animate()
          .fadeIn(duration: 420.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(1.03, 1.03),
            end: const Offset(1, 1),
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          );
    }

    return child;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.gradient});

  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = gradient ??
        const [AppColors.navy, AppColors.navyMid];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.view_in_ar_outlined,
          size: 48,
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
