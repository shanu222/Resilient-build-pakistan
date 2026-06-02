import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/app_breakpoints.dart';
import '../navigation/app_breadcrumbs.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_extensions.dart';
import '../theme/theme_mode_controller.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/hover_lift.dart';

class GovernmentHeader extends ConsumerWidget implements PreferredSizeWidget {
  const GovernmentHeader({
    super.key,
    this.title = 'Resilient Build Pakistan',
    this.showHome = true,
    this.showBack = false,
    this.breadcrumbs,
    this.preferredHeight,
  });

  final String title;
  final bool showHome;
  final bool showBack;
  final List<BreadcrumbSegment>? breadcrumbs;
  final double? preferredHeight;

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight ?? 72);

  double _height(BuildContext context) {
    if (preferredHeight != null) return preferredHeight!;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final h = _height(context);
    final logoD = _logoDiameter(context);
    final spacing = AppBreakpoints.isMobile(context) ? 10.0 : 14.0;
    final mode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = context.appTokens;
    final bg = tokens.headerBackground;

    final path = GoRouterState.of(context).uri.path;
    final modelId = GoRouterState.of(context).pathParameters['id'];
    String? modelName;
    if (modelId != null) {
      modelName = ref.watch(houseByIdProvider(modelId)).valueOrNull?.name;
    }
    final crumbs = breadcrumbs ??
        breadcrumbsForPath(path, modelName: modelName);
    final canPop = Navigator.of(context).canPop();
    final showBackBtn = showBack || (canPop && !showHome);

    return Material(
      color: bg,
      elevation: 0,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: bg,
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
                if (showHome)
                  _HeaderIconButton(
                    tooltip: 'Home',
                    icon: Icons.home_outlined,
                    onPressed: () => context.go('/home'),
                  ),
                if (showBackBtn) ...[
                  const SizedBox(width: 4),
                  _HeaderIconButton(
                    tooltip: 'Back',
                    icon: Icons.arrow_back,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                ],
                const SizedBox(width: 8),
                _LogoCircle(
                  assetPath: 'assets/images/branding/govt_pakistan.png',
                  semanticsLabel: 'Government of Pakistan',
                  imageDiameter: logoD,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (crumbs.length > 1)
                        AppBreadcrumbBar(segments: crumbs),
                      Semantics(
                        header: true,
                        label: title,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: AppBreakpoints.isMobile(context) ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: tokens.textOnPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _LogoCircle(
                  assetPath: 'assets/images/branding/ndma.png',
                  semanticsLabel: 'NDMA Pakistan',
                  imageDiameter: logoD,
                ),
                const SizedBox(width: 8),
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
                            onChanged: (_) =>
                                ref.read(themeModeProvider.notifier).toggleLightDark(),
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      visualDensity: VisualDensity.compact,
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
    final tokens = context.appTokens;
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: tokens.textOnPrimary,
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
            errorBuilder: (_, __, ___) => Icon(
              Icons.image_not_supported_outlined,
              color: tokens.textSecondary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
