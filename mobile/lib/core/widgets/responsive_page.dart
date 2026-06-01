import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';

/// Centers content with max width and consistent page padding.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.scrollable = true,
    this.backgroundColor,
  });

  final Widget child;
  final bool scrollable;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final padding = AppBreakpoints.pagePadding(context);
    final maxW = AppBreakpoints.contentMaxWidth(context);

    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (!scrollable) {
      return ColoredBox(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        child: content,
      );
    }

    return ColoredBox(
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: content,
      ),
    );
  }
}
