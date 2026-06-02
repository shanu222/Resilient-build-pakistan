import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base, {required Brightness brightness}) {
    final primary =
        brightness == Brightness.dark ? AppColors.darkForeground : AppColors.foreground;
    final secondary = brightness == Brightness.dark
        ? AppColors.darkMutedForeground
        : AppColors.mutedForeground;

    final plus = GoogleFonts.plusJakartaSansTextTheme(base);
    return plus.copyWith(
      displayLarge: plus.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      displayMedium: plus.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: plus.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: plus.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: plus.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: plus.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: plus.bodyLarge?.copyWith(
        color: primary,
        height: 1.5,
      ),
      bodyMedium: plus.bodyMedium?.copyWith(
        color: secondary,
        height: 1.45,
      ),
      bodySmall: plus.bodySmall?.copyWith(
        color: secondary,
        height: 1.4,
      ),
      labelLarge: plus.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.2,
      ),
      labelMedium: plus.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: plus.labelSmall?.copyWith(
        color: secondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
