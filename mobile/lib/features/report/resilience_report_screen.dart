import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';

class ResilienceReportScreen extends ConsumerWidget {
  const ResilienceReportScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final profile = location.profile;
    final modelsAsync = ref.watch(recommendedModelsProvider);

    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Resilience Report',
            subtitle: 'Site assessment summary',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (profile != null) ...[
                  Card(
                    child: ListTile(
                      title: Text(profile.displayName),
                      subtitle: Text('${profile.regionName} • ${profile.climate}'),
                      trailing: Text(
                        '${profile.suitabilityScore}%',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...profile.metrics.map(
                    (m) => ListTile(
                      title: Text(m.name),
                      trailing: Text('${m.score}% (${m.level})'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text('Top Recommended Models',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                modelsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('$e'),
                  data: (models) => Column(
                    children: models.take(3).map((m) {
                      return FutureBuilder(
                        future: ref.read(jsonRepoProvider).getResilienceScores(m.id),
                        builder: (context, snap) {
                          final scores = snap.data;
                          return Card(
                            margin: const EdgeInsets.only(top: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('Overall: ${scores?.overall ?? m.resilienceScore}%'),
                                      ],
                                    ),
                                  ),
                                  if (scores != null)
                                    SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: SfRadialGauge(
                                        axes: [
                                          RadialAxis(
                                            maximum: 100,
                                            showLabels: false,
                                            showTicks: false,
                                            pointers: [
                                              RangePointer(
                                                value: scores.overall.toDouble(),
                                                color: AppColors.success,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
