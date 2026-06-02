import 'package:flutter/material.dart';

import 'app_theme_extensions.dart';

/// Semantic text styles — always use tokens (never hardcode Colors.white/black).
extension AppThemeTextStyles on BuildContext {
  AppThemeTokens get _t => appTokens;

  TextStyle get primaryText => TextStyle(color: _t.textPrimary);
  TextStyle get secondaryText => TextStyle(color: _t.textSecondary);
  TextStyle get mutedText => TextStyle(color: _t.textMuted);
  TextStyle get onPrimaryText => TextStyle(color: _t.textOnPrimary);
  TextStyle get onGlassText => TextStyle(color: _t.textOnGlass);
  TextStyle get onGlassMutedText => TextStyle(color: _t.textOnGlassMuted);
  TextStyle get heroTitle => TextStyle(color: _t.textOnHero, fontWeight: FontWeight.w800);
  TextStyle get heroSubtitle => TextStyle(color: _t.textOnHeroMuted);

  TextStyle primary({double? fontSize, FontWeight? fontWeight}) =>
      TextStyle(color: _t.textPrimary, fontSize: fontSize, fontWeight: fontWeight);

  TextStyle secondary({double? fontSize, FontWeight? fontWeight}) =>
      TextStyle(color: _t.textSecondary, fontSize: fontSize, fontWeight: fontWeight);

  TextStyle muted({double? fontSize, FontWeight? fontWeight}) =>
      TextStyle(color: _t.textMuted, fontSize: fontSize, fontWeight: fontWeight);
}
