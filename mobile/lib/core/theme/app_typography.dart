import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) {
    final plus = GoogleFonts.plusJakartaSansTextTheme(base);
    return plus.copyWith(
      displayLarge: plus.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -0.5,
      ),
      displayMedium: plus.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
      ),
      headlineLarge: plus.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
      ),
      headlineMedium: plus.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
      titleLarge: plus.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
      titleMedium: plus.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
      bodyLarge: plus.bodyLarge?.copyWith(
        color: AppColors.foreground,
        height: 1.5,
      ),
      bodyMedium: plus.bodyMedium?.copyWith(
        color: AppColors.mutedForeground,
        height: 1.45,
      ),
      bodySmall: plus.bodySmall?.copyWith(
        color: AppColors.mutedForeground,
        height: 1.4,
      ),
      labelLarge: plus.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: plus.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.mutedForeground,
      ),
      labelSmall: plus.labelSmall?.copyWith(
        color: AppColors.mutedForeground,
        letterSpacing: 0.3,
      ),
    );
  }
}
