import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../data/models/house_model.dart';
import '../../providers/app_providers.dart';

class RecommendedModelsScreen extends ConsumerWidget {
  const RecommendedModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(recommendedModelsProvider);

    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Recommended Models',
            subtitle: 'Based on your location hazard profile',
          ),
          Expanded(
            child: modelsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (models) => ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: models.length,
                itemBuilder: (_, i) => _ModelCard(model: models[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.model});

  final HouseModel model;

  @override
  Widget build(BuildContext context) {
    final c1 = Color(int.parse(model.thumbnailGradient[0].replaceFirst('#', '0xFF')));
    final c2 = Color(int.parse(model.thumbnailGradient[1].replaceFirst('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/model/${model.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c1, c2]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.home, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(model.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: model.hazardsCovered.take(2).map((h) {
                        return Chip(
                          label: Text(h, style: const TextStyle(fontSize: 10)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 14, color: AppColors.mutedForeground),
                        Text(model.costCategory,
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        const SizedBox(width: 12),
                        const Icon(Icons.shield, size: 14, color: AppColors.success),
                        Text('${model.resilienceScore}%',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success)),
                        const SizedBox(width: 12),
                        const Icon(Icons.build, size: 14, color: AppColors.mutedForeground),
                        Text(model.complexity,
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/model/${model.id}'),
                            child: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/construction/${model.id}');
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Select'),
                                Icon(Icons.chevron_right, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
