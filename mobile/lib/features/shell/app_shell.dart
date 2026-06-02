import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/government_footer.dart';
import '../../core/widgets/government_header.dart';
import '../../shared/widgets/app_brand_logo.dart';
import '../../shared/widgets/glass_sidebar.dart';

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
    final extended = AppBreakpoints.isLargeDesktop(context);

    if (useRail) {
      return Scaffold(
        appBar: const GovernmentHeader(),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  GlassSidebar(
                    extended: extended,
                    selectedIndex: index,
                    onSelect: (i) => context.go(_paths[i]),
                    header: extended
                        ? const _SidebarBranding()
                        : const Center(child: AppBrandLogo(size: 56)),
                    items: _destinations
                        .map(
                          (d) => GlassSidebarItem(
                            icon: d.$1,
                            selectedIcon: d.$2,
                            label: d.$3,
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

class _SidebarBranding extends StatelessWidget {
  const _SidebarBranding();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: AppBrandLogo(size: 72)),
        const SizedBox(height: 10),
        const Text(
          'Resilient Build Pakistan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Government of Pakistan',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
        ),
        Text(
          'NDMA',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
        ),
      ],
    );
  }
}
