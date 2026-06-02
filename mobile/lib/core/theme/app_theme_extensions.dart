import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic theme tokens — use via `context.appTokens` (never hardcode page colors).
@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
    required this.surface,
    required this.card,
    required this.border,
    required this.primary,
    required this.warning,
    required this.success,
    required this.info,
    required this.glassBackground,
    required this.glassBorder,
    required this.headerBackground,
    required this.viewerBackground,
    required this.chipBackground,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color textOnPrimary;
  final Color surface;
  final Color card;
  final Color border;
  final Color primary;
  final Color warning;
  final Color success;
  final Color info;
  final Color glassBackground;
  final Color glassBorder;
  final Color headerBackground;
  final Color viewerBackground;
  final Color chipBackground;

  static const light = AppThemeTokens(
    textPrimary: AppColors.foreground,
    textSecondary: AppColors.mutedForeground,
    textOnPrimary: Colors.white,
    surface: AppColors.surface,
    card: AppColors.card,
    border: AppColors.border,
    primary: AppColors.navy,
    warning: Color(0xFFF59E0B),
    success: AppColors.success,
    info: AppColors.info,
    glassBackground: AppColors.glassLight,
    glassBorder: Color(0x26FFFFFF),
    headerBackground: AppColors.navy,
    viewerBackground: Color(0xFFE8EEF4),
    chipBackground: AppColors.muted,
  );

  static const dark = AppThemeTokens(
    textPrimary: AppColors.darkForeground,
    textSecondary: AppColors.darkMutedForeground,
    textOnPrimary: Colors.white,
    surface: AppColors.darkBackground,
    card: AppColors.darkCard,
    border: AppColors.darkBorder,
    primary: AppColors.navy,
    warning: Color(0xFFF59E0B),
    success: AppColors.success,
    info: AppColors.info,
    glassBackground: AppColors.glassDark,
    glassBorder: Color(0x33FFFFFF),
    headerBackground: AppColors.navyLight,
    viewerBackground: Color(0xFF0F172A),
    chipBackground: AppColors.darkPanel,
  );

  @override
  AppThemeTokens copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnPrimary,
    Color? surface,
    Color? card,
    Color? border,
    Color? primary,
    Color? warning,
    Color? success,
    Color? info,
    Color? glassBackground,
    Color? glassBorder,
    Color? headerBackground,
    Color? viewerBackground,
    Color? chipBackground,
  }) {
    return AppThemeTokens(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      headerBackground: headerBackground ?? this.headerBackground,
      viewerBackground: viewerBackground ?? this.viewerBackground,
      chipBackground: chipBackground ?? this.chipBackground,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      viewerBackground: Color.lerp(viewerBackground, other.viewerBackground, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
    );
  }
}

extension AppThemeTokensContext on BuildContext {
  AppThemeTokens get appTokens =>
      Theme.of(this).extension<AppThemeTokens>() ?? AppThemeTokens.light;
}
