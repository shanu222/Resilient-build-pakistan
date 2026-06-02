import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme_extensions.dart';

/// WCAG contrast validation for theme token pairs.
abstract final class ThemeContrastValidator {
  static const double minAaNormal = 4.5;
  static const double minAaLarge = 3.0;

  static double luminance(Color c) {
    double channel(double v) {
      v /= 255;
      return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  }

  static double contrastRatio(Color fg, Color bg) {
    final l1 = luminance(fg);
    final l2 = luminance(bg);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool passesAa(Color fg, Color bg, {bool largeText = false}) {
    return contrastRatio(fg, bg) >= (largeText ? minAaLarge : minAaNormal);
  }

  static List<ContrastIssue> auditTokens(AppThemeTokens tokens) {
    final issues = <ContrastIssue>[];

    void check(String name, Color fg, Color bg, {bool large = false}) {
      final ratio = contrastRatio(fg, bg);
      final min = large ? minAaLarge : minAaNormal;
      if (ratio < min) {
        issues.add(ContrastIssue(name: name, ratio: ratio, required: min, fg: fg, bg: bg));
      }
    }

    check('textPrimary on surface', tokens.textPrimary, tokens.surface);
    check('textSecondary on surface', tokens.textSecondary, tokens.surface);
    check('textMuted on surface', tokens.textMuted, tokens.surface);
    check('textPrimary on card', tokens.textPrimary, tokens.card);
    check('textOnGlass on surfaceGlass', tokens.textOnGlass, tokens.surfaceGlass);
    check('textOnGlassMuted on surfaceGlass', tokens.textOnGlassMuted, tokens.surfaceGlass);
    check('textOnPrimary on primary', tokens.textOnPrimary, tokens.primary);
    check('textOnPrimary on headerBackground', tokens.textOnPrimary, tokens.headerBackground);
    check('navInactive on headerBackground', tokens.navInactive, tokens.headerBackground);
    check('chipForeground on chipBackground', tokens.chipForeground, tokens.chipBackground);

    return issues;
  }
}

class ContrastIssue {
  const ContrastIssue({
    required this.name,
    required this.ratio,
    required this.required,
    required this.fg,
    required this.bg,
  });

  final String name;
  final double ratio;
  final double required;
  final Color fg;
  final Color bg;
}
