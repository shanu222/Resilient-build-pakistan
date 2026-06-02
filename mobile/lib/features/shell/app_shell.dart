import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/widgets/government_footer.dart';
import '../../core/widgets/government_header.dart';
import '../../shared/widgets/glass_sidebar.dart';

/// Adaptive shell: bottom nav (mobile) · glass sidebar (desktop).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _paths = ['/home', '/location/current', '/models', '/library'];

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Home', '🏠'),
    (Icons.location_on_outlined, Icons.location_on, 'Location', '📍'),
    (Icons.home_work_outlined, Icons.home_work, 'Models', '🏗'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Library', '📚'),
  ];

  bool _hideNav(String path) =>
      path.startsWith('/bim/') || path.contains('/guidelines');

  int _indexForPath(String path) {
    if (path.startsWith('/location')) return 1;
    if (path.startsWith('/model') || path == '/models') return 2;
    if (path.startsWith('/library') ||
        path.startsWith('/materials') ||
        path.startsWith('/downloads')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final hideNav = _hideNav(path);
    final index = _indexForPath(path);
    final useRail = !hideNav && AppBreakpoints.isDesktop(context);

    if (useRail) {
      return Scaffold(
        appBar: const GovernmentHeader(),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  GlassSidebar(
                    selectedIndex: index,
                    onSelect: (i) => context.go(_paths[i]),
                    items: _destinations
                        .map(
                          (d) => GlassSidebarItem(
                            icon: d.$1,
                            selectedIcon: d.$2,
                            label: d.$3,
                            emoji: d.$4,
                          ),
                        )
                        .toList(),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
            const GovernmentFooter(version: '1.0.0+1'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const GovernmentHeader(),
      body: Column(
        children: [
          Expanded(child: child),
          const GovernmentFooter(version: '1.0.0+1'),
        ],
      ),
      bottomNavigationBar: hideNav
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(_paths[i]),
              destinations: _destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2),
                      label: d.$3,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
