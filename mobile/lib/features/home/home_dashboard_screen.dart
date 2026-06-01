import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  Map<String, dynamic>? _selectedDistrict;

  Future<void> _useMyLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission required')),
        );
      }
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    await ref.read(locationProvider.notifier).analyzeAt(
          pos.latitude,
          pos.longitude,
          placeName: 'Current Location',
        );
    if (mounted) context.push('/location/current');
  }

  Future<void> _analyzeDistrict() async {
    final d = _selectedDistrict;
    if (d == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a district first')),
      );
      return;
    }
    await ref.read(locationProvider.notifier).analyzeDistrict(d);
    if (mounted) context.push('/location/current');
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsProvider);
    final location = ref.watch(locationProvider);

    final quickActions = [
      (Icons.map, 'Select district & assess hazards', AppColors.orange, _analyzeDistrict),
      (Icons.navigation, 'Use GPS location', Colors.blue, _useMyLocation),
      (Icons.home_work, 'Resilient model library', AppColors.navy, () => context.push('/models')),
      (Icons.view_in_ar, 'Construction academy', Colors.green, () => context.push('/academy')),
    ];

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.navy, AppColors.navyMid],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Where will you build?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a district — we evaluate flood, earthquake, landslide, GLOF, and wind risk offline.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        districtsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('$e', style: const TextStyle(color: Colors.white)),
                          data: (districts) {
                            return DropdownButtonFormField<Map<String, dynamic>>(
                              value: _selectedDistrict,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'District',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: districts
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        '${d['name']} (${d['provinceName']})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedDistrict = v),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _analyzeDistrict,
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text('Evaluate hazards & recommend models'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _useMyLocation,
                          icon: const Icon(Icons.my_location, color: Colors.white70),
                          label: const Text(
                            'Or use GPS',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        if (location.profile != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Last: ${location.placeName}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  children: [
                    const Text(
                      'Learning journey',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Location → Hazards → Recommended models → Digital Twin → Hazard simulation',
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ...quickActions.map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => a.$4(),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: a.$3,
                                    child: Icon(a.$1, color: Colors.white),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      a.$2,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
