import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academy/construction_academy_screen.dart';
import '../../features/construction/construction_guide_screen.dart';
import '../../features/engineering/engineering_detail_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/library/offline_library_screen.dart';
import '../../features/location/location_analysis_screen.dart';
import '../../features/materials/materials_library_screen.dart';
import '../../features/models/model_details_screen.dart';
import '../../features/models/recommended_models_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/report/resilience_report_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeDashboardScreen()),
          GoRoute(
            path: '/location/:id',
            builder: (_, state) => LocationAnalysisScreen(
              locationId: state.pathParameters['id'] ?? 'current',
            ),
          ),
          GoRoute(path: '/models', builder: (_, __) => const RecommendedModelsScreen()),
          GoRoute(
            path: '/model/:id',
            builder: (_, state) => ModelDetailsScreen(
              modelId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/construction/:id',
            builder: (_, state) => ConstructionGuideScreen(
              modelId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/bim/:id',
            builder: (_, state) => ConstructionGuideScreen(
              modelId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/engineering/:component',
            builder: (_, state) => EngineeringDetailScreen(
              componentId: state.pathParameters['component'] ?? 'foundation',
            ),
          ),
          GoRoute(path: '/library', builder: (_, __) => const OfflineLibraryScreen()),
          GoRoute(path: '/materials', builder: (_, __) => const MaterialsLibraryScreen()),
          GoRoute(path: '/academy', builder: (_, __) => const ConstructionAcademyScreen()),
          GoRoute(
            path: '/report/:id',
            builder: (_, state) => ResilienceReportScreen(
              reportId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});
