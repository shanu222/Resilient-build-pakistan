import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic theme tokens — use via `context.appTokens` (never hardcode page colors).
@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnPrimary,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceGlass,
    required this.card,
    required this.border,
    required this.primary,
    required this.warning,
    required this.success,
    required this.danger,
    required this.info,
    required this.glassBackground,
    required this.glassBorder,
    required this.headerBackground,
    required this.viewerBackground,
    required this.chipBackground,
    required this.textOnGlass,
    required this.textOnGlassMuted,
    required this.playbackSurface,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnPrimary;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceGlass;
  final Color card;
  final Color border;
  final Color primary;
  final Color warning;
  final Color success;
  final Color danger;
  final Color info;
  final Color glassBackground;
  final Color glassBorder;
  final Color headerBackground;
  final Color viewerBackground;
  final Color chipBackground;
  /// Labels on dark glass playback / HUD overlays.
  final Color textOnGlass;
  final Color textOnGlassMuted;
  final Color playbackSurface;

  static const light = AppThemeTokens(
    textPrimary: AppColors.foreground,
    textSecondary: AppColors.mutedForeground,
    textMuted: Color(0xFF94A3B8),
    textOnPrimary: Color(0xFFFFFFFF),
    surface: AppColors.surface,
    surfaceElevated: AppColors.surfaceElevated,
    surfaceGlass: AppColors.glassLight,
    card: AppColors.card,
    border: AppColors.border,
    primary: AppColors.navy,
    warning: AppColors.warning,
    success: AppColors.success,
    danger: AppColors.hazard,
    info: AppColors.info,
    glassBackground: AppColors.glassLight,
    glassBorder: Color(0x26FFFFFF),
    headerBackground: AppColors.navy,
    viewerBackground: Color(0xFFE8EEF4),
    chipBackground: AppColors.muted,
    textOnGlass: Color(0xFFFFFFFF),
    textOnGlassMuted: Color(0xB3FFFFFF),
    playbackSurface: Color(0xC70A2342),
  );

  static const dark = AppThemeTokens(
    textPrimary: AppColors.darkForeground,
    textSecondary: AppColors.darkMutedForeground,
    textMuted: Color(0xFF6B7280),
    textOnPrimary: Color(0xFFFFFFFF),
    surface: AppColors.darkBackground,
    surfaceElevated: AppColors.darkCard,
    surfaceGlass: AppColors.glassDark,
    card: AppColors.darkCard,
    border: AppColors.darkBorder,
    primary: AppColors.navy,
    warning: AppColors.warning,
    success: AppColors.success,
    danger: AppColors.hazard,
    info: AppColors.info,
    glassBackground: AppColors.glassDark,
    glassBorder: Color(0x33FFFFFF),
    headerBackground: AppColors.navyLight,
    viewerBackground: Color(0xFF0F172A),
    chipBackground: AppColors.darkPanel,
    textOnGlass: Color(0xFFFFFFFF),
    textOnGlassMuted: Color(0xB3FFFFFF),
    playbackSurface: Color(0xC7081A33),
  );

  @override
  AppThemeTokens copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnPrimary,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceGlass,
    Color? card,
    Color? border,
    Color? primary,
    Color? warning,
    Color? success,
    Color? danger,
    Color? info,
    Color? glassBackground,
    Color? glassBorder,
    Color? headerBackground,
    Color? viewerBackground,
    Color? chipBackground,
    Color? textOnGlass,
    Color? textOnGlassMuted,
    Color? playbackSurface,
  }) {
    return AppThemeTokens(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      card: card ?? this.card,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      headerBackground: headerBackground ?? this.headerBackground,
      viewerBackground: viewerBackground ?? this.viewerBackground,
      chipBackground: chipBackground ?? this.chipBackground,
      textOnGlass: textOnGlass ?? this.textOnGlass,
      textOnGlassMuted: textOnGlassMuted ?? this.textOnGlassMuted,
      playbackSurface: playbackSurface ?? this.playbackSurface,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      viewerBackground: Color.lerp(viewerBackground, other.viewerBackground, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      textOnGlass: Color.lerp(textOnGlass, other.textOnGlass, t)!,
      textOnGlassMuted: Color.lerp(textOnGlassMuted, other.textOnGlassMuted, t)!,
      playbackSurface: Color.lerp(playbackSurface, other.playbackSurface, t)!,
    );
  }
}

extension AppThemeTokensContext on BuildContext {
  AppThemeTokens get appTokens =>
      Theme.of(this).extension<AppThemeTokens>() ?? AppThemeTokens.light;
}
