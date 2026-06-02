import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/bim_simulation/ui/bim_simulation_screen.dart';
import '../../features/construction/construction_guide_screen.dart';
import '../../features/engineering/engineering_detail_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/library/offline_library_screen.dart';
import '../../features/location/location_analysis_screen.dart';
import '../../features/materials/materials_library_screen.dart';
import '../../features/models/guidelines_route_screen.dart';
import '../../features/models/model_details_screen.dart';
import '../../features/models/recommended_models_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/report/resilience_report_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../theme/app_page_transitions.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(
        path: '/model/:id/guidelines',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
          key: s.pageKey,
          child: GuidelinesRouteScreen(modelId: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/bim/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
          key: s.pageKey,
          child: BimSimulationScreen(modelId: s.pathParameters['id']!),
        ),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: const HomeDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/location/:id',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: LocationAnalysisScreen(
                locationId: s.pathParameters['id'] ?? 'current',
              ),
            ),
          ),
          GoRoute(
            path: '/models',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: const RecommendedModelsScreen(),
            ),
          ),
          GoRoute(
            path: '/model/:id',
            pageBuilder: (c, s) => AppPageTransitions.scaleFade(
              key: s.pageKey,
              child: ModelDetailsScreen(modelId: s.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/construction/:id',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: ConstructionGuideScreen(modelId: s.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/engineering/:component',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: EngineeringDetailScreen(
                componentId: s.pathParameters['component'] ?? 'foundation',
              ),
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: const OfflineLibraryScreen(),
            ),
          ),
          GoRoute(
            path: '/materials',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: const MaterialsLibraryScreen(),
            ),
          ),
          GoRoute(
            path: '/report/:id',
            pageBuilder: (c, s) => AppPageTransitions.fadeSlide(
              key: s.pageKey,
              child: ResilienceReportScreen(reportId: s.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
});
