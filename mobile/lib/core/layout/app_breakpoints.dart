import 'package:flutter/material.dart';

/// Responsive breakpoints (production spec).
///
/// Mobile: 0–767 · Tablet: 768–1199 · Desktop: 1200+
abstract final class AppBreakpoints {
  static const mobile = 768.0;
  static const tablet = 1200.0;
  static const largeDesktop = 1440.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= largeDesktop;

  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= largeDesktop) return 1280;
    if (w >= tablet) return 1080;
    if (w >= mobile) return 960;
    return w;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isLargeDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static int catalogColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tablet) return 3;
    if (w >= mobile) return 2;
    return 1;
  }
}
