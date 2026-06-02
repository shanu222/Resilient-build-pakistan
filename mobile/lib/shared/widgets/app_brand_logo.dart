import 'package:flutter/material.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({
    super.key,
    this.size,
    this.semanticsLabel = 'Resilient Build Pakistan',
  });

  final double? size;
  final String semanticsLabel;

  static const assetPath =
      'assets/images/branding/resilient_build_pakistan_logo.png';

  double _defaultSize(BuildContext context) {
    if (AppBreakpoints.isDesktop(context)) return 72;
    if (AppBreakpoints.isTablet(context)) return 64;
    return 56;
  }

  @override
  Widget build(BuildContext context) {
    final s = size ?? _defaultSize(context);
    final tokens = context.appTokens;
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: Container(
        width: s,
        height: s,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: tokens.shadow,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, error, __) {
              // ignore: avoid_print
              print('WARN: failed to load brand logo ($assetPath): $error');
              return Icon(Icons.shield, color: AppColors.orange, size: s * 0.62);
            },
          ),
        ),
      ),
    );
  }
}

