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
    required this.textOnHero,
    required this.textOnHeroMuted,
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
    required this.chipForeground,
    required this.textOnGlass,
    required this.textOnGlassMuted,
    required this.playbackSurface,
    required this.overlayScrim,
    required this.shadow,
    required this.navInactive,
    required this.navActive,
    required this.fillSubtle,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnPrimary;
  /// Text on navy gradient hero sections (always high-contrast).
  final Color textOnHero;
  final Color textOnHeroMuted;
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
  final Color chipForeground;
  /// Text on glass panels over the viewer (theme-aware).
  final Color textOnGlass;
  final Color textOnGlassMuted;
  final Color playbackSurface;
  final Color overlayScrim;
  final Color shadow;
  final Color navInactive;
  final Color navActive;
  final Color fillSubtle;

  static const light = AppThemeTokens(
    textPrimary: AppColors.foreground,
    textSecondary: AppColors.mutedForeground,
    textMuted: Color(0xFF64748B),
    textOnPrimary: Color(0xFFFFFFFF),
    textOnHero: Color(0xFFFFFFFF),
    textOnHeroMuted: Color(0xD9FFFFFF),
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
    glassBorder: Color(0x330F172A),
    headerBackground: AppColors.navy,
    viewerBackground: Color(0xFFE8EEF4),
    chipBackground: AppColors.muted,
    chipForeground: AppColors.foreground,
    textOnGlass: AppColors.foreground,
    textOnGlassMuted: AppColors.mutedForeground,
    playbackSurface: Color(0xE60A2342),
    overlayScrim: Color(0x660F172A),
    shadow: Color(0x2E0F172A),
    navInactive: Color(0xFFCBD5E1),
    navActive: Color(0xFFFFFFFF),
    fillSubtle: Color(0x0F0F172A),
  );

  static const dark = AppThemeTokens(
    textPrimary: AppColors.darkForeground,
    textSecondary: AppColors.darkMutedForeground,
    textMuted: Color(0xFF9CA3AF),
    textOnPrimary: Color(0xFFFFFFFF),
    textOnHero: Color(0xFFFFFFFF),
    textOnHeroMuted: Color(0xD9FFFFFF),
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
    chipForeground: AppColors.darkForeground,
    textOnGlass: Color(0xFFF1F5F9),
    textOnGlassMuted: Color(0xB3E2E8F0),
    playbackSurface: Color(0xE6081A33),
    overlayScrim: Color(0x99000000),
    shadow: Color(0x66000000),
    navInactive: Color(0xFFCBD5E1),
    navActive: Color(0xFFFFFFFF),
    fillSubtle: Color(0x14FFFFFF),
  );

  @override
  AppThemeTokens copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnPrimary,
    Color? textOnHero,
    Color? textOnHeroMuted,
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
    Color? chipForeground,
    Color? textOnGlass,
    Color? textOnGlassMuted,
    Color? playbackSurface,
    Color? overlayScrim,
    Color? shadow,
    Color? navInactive,
    Color? navActive,
    Color? fillSubtle,
  }) {
    return AppThemeTokens(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnHero: textOnHero ?? this.textOnHero,
      textOnHeroMuted: textOnHeroMuted ?? this.textOnHeroMuted,
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
      chipForeground: chipForeground ?? this.chipForeground,
      textOnGlass: textOnGlass ?? this.textOnGlass,
      textOnGlassMuted: textOnGlassMuted ?? this.textOnGlassMuted,
      playbackSurface: playbackSurface ?? this.playbackSurface,
      overlayScrim: overlayScrim ?? this.overlayScrim,
      shadow: shadow ?? this.shadow,
      navInactive: navInactive ?? this.navInactive,
      navActive: navActive ?? this.navActive,
      fillSubtle: fillSubtle ?? this.fillSubtle,
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
      textOnHero: Color.lerp(textOnHero, other.textOnHero, t)!,
      textOnHeroMuted: Color.lerp(textOnHeroMuted, other.textOnHeroMuted, t)!,
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
      chipForeground: Color.lerp(chipForeground, other.chipForeground, t)!,
      textOnGlass: Color.lerp(textOnGlass, other.textOnGlass, t)!,
      textOnGlassMuted: Color.lerp(textOnGlassMuted, other.textOnGlassMuted, t)!,
      playbackSurface: Color.lerp(playbackSurface, other.playbackSurface, t)!,
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      fillSubtle: Color.lerp(fillSubtle, other.fillSubtle, t)!,
    );
  }
}

extension AppThemeTokensContext on BuildContext {
  AppThemeTokens get appTokens =>
      Theme.of(this).extension<AppThemeTokens>() ?? AppThemeTokens.light;
}
