import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';
import 'construction_guidelines_screen.dart';

/// GoRouter entry for `/model/:id/guidelines` (browser / system back).
class GuidelinesRouteScreen extends ConsumerWidget {
  const GuidelinesRouteScreen({super.key, required this.modelId});

  final String modelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseAsync = ref.watch(houseByIdProvider(modelId));
    return houseAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/models'),
                child: const Text('Back to models'),
              ),
            ],
          ),
        ),
      ),
      data: (house) {
        if (house == null) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => context.go('/models'),
                child: const Text('Model not found'),
              ),
            ),
          );
        }
        return ConstructionGuidelinesScreen(house: house);
      },
    );
  }
}
