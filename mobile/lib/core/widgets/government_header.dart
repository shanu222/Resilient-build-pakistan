import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../layout/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/theme_mode_controller.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/hover_lift.dart';

class GovernmentHeader extends ConsumerWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final h = _height(context);
    final logoD = _logoDiameter(context);
    final spacing = AppBreakpoints.isMobile(context) ? 10.0 : 14.0;
    final mode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                const SizedBox(width: 10),
                // Theme toggle: placed beside NDMA logo as requested.
                HoverLift(
                  child: SizedBox(
                    height: 44,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      borderRadius: 999,
                      blurSigma: 18,
                      opacity: isDark ? 0.55 : 0.30,
                      borderOpacity: isDark ? 0.16 : 0.12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ModeDot(
                            selected: mode != ThemeMode.dark,
                            icon: Icons.wb_sunny_outlined,
                          ),
                          const SizedBox(width: 6),
                          _ModeDot(
                            selected: mode == ThemeMode.dark,
                            icon: Icons.nightlight_round,
                          ),
                          const SizedBox(width: 4),
                          Switch.adaptive(
                            value: mode == ThemeMode.dark,
                            onChanged: (_) => ref.read(themeModeProvider.notifier).toggleLightDark(),
                            activeColor: AppColors.orange,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeDot extends StatelessWidget {
  const _ModeDot({required this.selected, required this.icon});
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange.withValues(alpha: 0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, size: 16, color: Colors.white),
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

