import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';
import '../theme/app_colors.dart';

class GovernmentHeader extends StatelessWidget implements PreferredSizeWidget {
  const GovernmentHeader({
    super.key,
    this.title = 'Resilient Build Pakistan',
  });

  final String title;

  static const _bg = Color(0xFF0B2345);

  double _height(BuildContext context) {
    if (AppBreakpoints.isDesktop(context)) return 72;
    if (AppBreakpoints.isTablet(context)) return 64;
    return 56;
  }

  double _logoDiameter(BuildContext context) {
    if (AppBreakpoints.isDesktop(context)) return 44;
    if (AppBreakpoints.isTablet(context)) return 36;
    return 32;
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final h = _height(context);
    final logoD = _logoDiameter(context);
    final spacing = AppBreakpoints.isMobile(context) ? 10.0 : 14.0;

    return Material(
      color: _bg,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: _bg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Row(
              children: [
                _LogoCircle(
                  assetPath: 'assets/images/branding/govt_pakistan.png',
                  semanticsLabel: 'Government of Pakistan',
                  imageDiameter: logoD,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    label: 'Resilient Build Pakistan',
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: AppBreakpoints.isMobile(context) ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _LogoCircle(
                  assetPath: 'assets/images/branding/ndma.png',
                  semanticsLabel: 'NDMA Pakistan',
                  imageDiameter: logoD,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({
    required this.assetPath,
    required this.semanticsLabel,
    required this.imageDiameter,
  });

  final String assetPath;
  final String semanticsLabel;
  final double imageDiameter;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: imageDiameter,
            height: imageDiameter,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.mutedForeground,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

