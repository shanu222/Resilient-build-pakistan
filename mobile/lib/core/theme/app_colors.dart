import 'package:flutter/material.dart';

/// NDMA-inspired national resilience design tokens.
abstract final class AppColors {
  // Brand
  static const navy = Color(0xFF0B1F3A);
  static const navyLight = Color(0xFF1A3358);
  static const navyMid = Color(0xFF2A4365);
  static const orange = Color(0xFFE85D04);
  static const orangeLight = Color(0xFFF48C06);
  static const steel = Color(0xFF64748B);

  // Semantic
  static const success = Color(0xFF15803D);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFEF3C7);
  static const hazard = Color(0xFFB91C1C);
  static const hazardLight = Color(0xFFFEE2E2);

  // Surfaces
  static const background = Color(0xFFF4F6F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF0F172A);
  static const muted = Color(0xFFE8EDF3);
  static const mutedForeground = Color(0xFF64748B);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const viewerBg = Color(0xFF1E293B);

  // Gradients
  static const heroGradient = [navy, navyMid];
  static const accentGradient = [orange, orangeLight];
}
