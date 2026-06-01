import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

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
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.layers_outlined), selectedIcon: Icon(Icons.layers), label: 'Models'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Academy'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
        indicatorColor: AppColors.orange.withValues(alpha: 0.15),
      ),
    );
  }

  static const _paths = ['/home', '/models', '/academy', '/projects', '/profile'];

  int _indexForPath(String path) {
    if (path.startsWith('/home') || path.startsWith('/location')) return 0;
    if (path.startsWith('/model') || path == '/models') return 1;
    if (path.startsWith('/academy')) return 2;
    if (path.startsWith('/projects') || path.startsWith('/report')) return 3;
    if (path.startsWith('/profile')) return 4;
    return 0;
  }
}
