import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme_extensions.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.blurSigma = 20,
    this.opacity,
    this.borderOpacity,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final double? opacity;
  final double? borderOpacity;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = tokens.surfaceGlass;
    final o = opacity ?? (isDark ? 0.72 : 0.82);
    final b = borderOpacity ?? (isDark ? 0.22 : 0.18);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bg.withValues(alpha: o),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: tokens.glassBorder.withValues(alpha: b),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: tokens.overlayScrim.withValues(alpha: isDark ? 0.45 : 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
