import 'package:flutter/material.dart';

/// Consistent spacing scale for national-grade UI.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  static const cardPadding = EdgeInsets.all(md);
  static const sectionGap = lg;
  static const itemGap = sm;
}
