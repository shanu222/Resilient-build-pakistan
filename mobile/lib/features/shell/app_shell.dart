import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Public education navigation — no profile or admin.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexForPath(path),
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Location',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work),
            label: 'Models',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_in_ar_outlined),
            selectedIcon: Icon(Icons.view_in_ar),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Library',
          ),
        ],
        indicatorColor: AppColors.orange.withValues(alpha: 0.15),
      ),
    );
  }

  static const _paths = ['/home', '/models', '/academy', '/library'];

  int _indexForPath(String path) {
    if (path.startsWith('/home') || path.startsWith('/location')) return 0;
    if (path.startsWith('/model') || path == '/models') return 1;
    if (path.startsWith('/academy') ||
        path.startsWith('/construction') ||
        path.startsWith('/bim')) {
      return 2;
    }
    if (path.startsWith('/library') ||
        path.startsWith('/materials') ||
        path.startsWith('/downloads')) {
      return 3;
    }
    return 0;
  }
}
