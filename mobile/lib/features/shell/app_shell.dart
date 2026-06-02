import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';

/// Adaptive shell: bottom nav (mobile) · navigation rail (tablet/desktop).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _paths = ['/home', '/models', '/library'];

  static const _destinations = [
    (Icons.location_on_outlined, Icons.location_on, 'Location'),
    (Icons.home_work_outlined, Icons.home_work, 'Models'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Library'),
  ];

  bool _hideNav(String path) => path.startsWith('/bim/');

  int _indexForPath(String path) {
    if (path.startsWith('/home') || path.startsWith('/location')) return 0;
    if (path.startsWith('/model') || path == '/models') return 1;
    if (path.startsWith('/library') ||
        path.startsWith('/materials') ||
        path.startsWith('/downloads')) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final hideNav = _hideNav(path);
    final index = _indexForPath(path);
    final useRail = !hideNav && AppBreakpoints.isDesktop(context);

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: AppBreakpoints.isLargeDesktop(context),
              minExtendedWidth: 200,
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(_paths[i]),
              labelType: AppBreakpoints.isLargeDesktop(context)
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield, color: AppColors.orange),
                    ),
                    if (AppBreakpoints.isLargeDesktop(context)) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Resilient Build',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Pakistan',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              destinations: _destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2),
                      label: Text(d.$3),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
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
