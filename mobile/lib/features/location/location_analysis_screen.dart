import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_providers.dart';

class LocationAnalysisScreen extends ConsumerStatefulWidget {
  const LocationAnalysisScreen({super.key, required this.locationId});

  final String locationId;

  @override
  ConsumerState<LocationAnalysisScreen> createState() =>
      _LocationAnalysisScreenState();
}

class _LocationAnalysisScreenState
    extends ConsumerState<LocationAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = ref.read(locationProvider);
      if (loc.profile == null) {
        await ref.read(locationProvider.notifier).analyzeCurrent();
      }
    });
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'High':
        return AppColors.hazard;
      case 'Medium':
        return AppColors.orange;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locationProvider);
    final profile = loc.profile;

    if (loc.isLoading || profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.navyMid],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: AppColors.orange, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${profile.latitude.toStringAsFixed(4)}° N, ${profile.longitude.toStringAsFixed(4)}° E',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: AppColors.navyLight,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Overall Site Suitability',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${profile.suitabilityScore}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: profile.suitabilityScore / 100,
                                minHeight: 10,
                                backgroundColor: Colors.white24,
                                color: AppColors.orange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.suitabilitySummary,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hazard Assessment',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...profile.metrics.map((m) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(
                                  int.parse(m.colorHex.replaceFirst('#', '0xFF')),
                                ).withValues(alpha: 0.15),
                                child: Icon(
                                  _iconFor(m.type),
                                  color: Color(
                                    int.parse(m.colorHex.replaceFirst('#', '0xFF')),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(m.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                          m.level,
                                          style: TextStyle(
                                            color: _levelColor(m.level),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: m.score / 100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Card(
                      color: AppColors.orange.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('River Proximity',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              profile.riverProximityNote,
                              style: const TextStyle(
                                  color: AppColors.mutedForeground, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Historical Events',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...profile.historicalEvents.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(e,
                                    style: const TextStyle(
                                        color: AppColors.mutedForeground,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'View Recommended House Models',
                      icon: Icons.chevron_right,
                      onPressed: () => context.push('/models'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'flood':
        return Icons.waves;
      case 'earthquake':
        return Icons.sensors;
      case 'landslide':
        return Icons.terrain;
      case 'glof':
        return Icons.water_drop;
      case 'wind':
        return Icons.air;
      default:
        return Icons.warning;
    }
  }
}
