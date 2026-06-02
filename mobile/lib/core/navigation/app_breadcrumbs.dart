import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme_extensions.dart';

class BreadcrumbSegment {
  const BreadcrumbSegment({required this.label, this.path});

  final String label;
  final String? path;
}

List<BreadcrumbSegment> breadcrumbsForPath(String path, {String? modelName}) {
  final segments = <BreadcrumbSegment>[
    const BreadcrumbSegment(label: 'Home', path: '/home'),
  ];

  if (path.startsWith('/location') || path == '/home') {
    if (path != '/home') {
      segments.add(const BreadcrumbSegment(label: 'Location'));
    }
    return segments;
  }

  if (path.startsWith('/models') || path.startsWith('/model')) {
    segments.add(const BreadcrumbSegment(label: 'Models', path: '/models'));
    if (path.startsWith('/model/') && modelName != null) {
      segments.add(BreadcrumbSegment(label: modelName));
    }
    return segments;
  }

  if (path.startsWith('/library') ||
      path.startsWith('/materials') ||
      path.startsWith('/downloads')) {
    segments.add(const BreadcrumbSegment(label: 'Library', path: '/library'));
    return segments;
  }

  if (path.startsWith('/bim/')) {
    segments.add(const BreadcrumbSegment(label: 'Models', path: '/models'));
    if (modelName != null) {
      segments.add(BreadcrumbSegment(label: modelName, path: null));
      segments.add(const BreadcrumbSegment(label: 'Digital Twin'));
    }
    return segments;
  }

  if (path.contains('/guidelines')) {
    segments.add(const BreadcrumbSegment(label: 'Models', path: '/models'));
    if (modelName != null) {
      segments.add(BreadcrumbSegment(label: modelName, path: null));
      segments.add(const BreadcrumbSegment(label: 'Guidelines'));
    }
    return segments;
  }

  return segments;
}

class AppBreadcrumbBar extends StatelessWidget {
  const AppBreadcrumbBar({super.key, required this.segments});

  final List<BreadcrumbSegment> segments;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    if (segments.length <= 1) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.chevron_right, size: 16, color: tokens.textOnPrimary.withValues(alpha: 0.6)),
              ),
            _Crumb(
              segment: segments[i],
              isLast: i == segments.length - 1,
              tokens: tokens,
            ),
          ],
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({
    required this.segment,
    required this.isLast,
    required this.tokens,
  });

  final BreadcrumbSegment segment;
  final bool isLast;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: tokens.textOnPrimary.withValues(alpha: isLast ? 1.0 : 0.75),
      fontSize: 11,
      fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
    );

    if (!isLast && segment.path != null) {
      return InkWell(
        onTap: () => context.go(segment.path!),
        child: Text(segment.label, style: style),
      );
    }
    return Text(segment.label, style: style);
  }
}
