import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/academy/construction_academy_screen.dart';
import '../../features/bim_simulation/ui/bim_simulation_screen.dart';
import '../../features/construction/construction_guide_screen.dart';
import '../../features/downloads/download_center_screen.dart';
import '../../features/engineering/engineering_detail_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/inspection/ai_inspection_screen.dart';
import '../../features/location/location_analysis_screen.dart';
import '../../features/materials/materials_library_screen.dart';
import '../../features/models/model_details_screen.dart';
import '../../features/models/recommended_models_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/prices/market_prices_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/projects/project_tracker_screen.dart';
import '../../features/report/resilience_report_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
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
          GoRoute(
            path: '/models',
            builder: (_, __) => const RecommendedModelsScreen(),
          ),
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
            builder: (_, state) => BimSimulationScreen(
              modelId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/engineering/:component',
            builder: (_, state) => EngineeringDetailScreen(
              componentId: state.pathParameters['component'] ?? 'column',
            ),
          ),
          GoRoute(
            path: '/materials',
            builder: (_, __) => const MaterialsLibraryScreen(),
          ),
          GoRoute(
            path: '/prices',
            builder: (_, __) => const MarketPricesScreen(),
          ),
          GoRoute(
            path: '/downloads',
            builder: (_, __) => const DownloadCenterScreen(),
          ),
          GoRoute(
            path: '/academy',
            builder: (_, __) => const ConstructionAcademyScreen(),
          ),
          GoRoute(
            path: '/inspection',
            builder: (_, __) => const AiInspectionScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (_, __) => const ProjectTrackerScreen(),
          ),
          GoRoute(
            path: '/report/:id',
            builder: (_, state) => ResilienceReportScreen(
              reportId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
        ],
      ),
    ],
  );
});
