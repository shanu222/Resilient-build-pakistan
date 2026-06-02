import 'package:flutter/material.dart';

/// NDMA-inspired national resilience design tokens.
abstract final class AppColors {
  // Brand
  /// Government Blue (primary)
  static const navy = Color(0xFF0A2342);
  /// Deep Navy (darker panels)
  static const navyLight = Color(0xFF081A33);
  static const navyMid = Color(0xFF1E3A5F);
  /// Engineering Orange (secondary/CTA)
  static const orange = Color(0xFFF47C20);
  static const orangeLight = Color(0xFFFF9D4D);
  static const steel = Color(0xFF64748B);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFEF3C7);
  static const hazard = Color(0xFFEF4444);
  static const hazardLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);

  // Surfaces
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF0F172A);
  static const muted = Color(0xFFE8EDF3);
  static const mutedForeground = Color(0xFF64748B);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const viewerBg = Color(0xFF1E293B);

  // Dark surfaces
  static const darkBackground = Color(0xFF0B1120);
  static const darkCard = Color(0xFF111827);
  static const darkPanel = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF263246);
  static const darkForeground = Color(0xFFE5E7EB);
  static const darkMutedForeground = Color(0xFF9CA3AF);

  // Glass
  static const glassLight = Color(0xBFFFFFFF); // rgba(255,255,255,0.75)
  static const glassDark = Color(0xA6111827); // rgba(17,24,39,0.65)

  // Gradients
  static const heroGradient = [navy, navyMid];
  static const accentGradient = [orange, orangeLight];
}
