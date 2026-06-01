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
  final _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      (Icons.navigation, 'Explore My Location', Colors.blue, _useMyLocation),
      (Icons.warning_amber, 'Hazard Assessment', AppColors.orange, _useMyLocation),
      (Icons.apartment, 'House Models', AppColors.navy, () => context.push('/models')),
      (Icons.school, 'Construction Academy', Colors.green, () => context.push('/academy')),
      (Icons.calculate, 'Resilience Calculator', Colors.purple, _useMyLocation),
    ];

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
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
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Where do you want to build?',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.location_on, color: AppColors.orange),
                          onPressed: () async {
                            await ref.read(locationProvider.notifier).analyzeAt(
                                  31.5204,
                                  74.3587,
                                  placeName: _searchController.text.isEmpty
                                      ? 'Lahore, Punjab'
                                      : _searchController.text,
                                );
                            if (context.mounted) {
                              context.push('/location/current');
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 64, color: AppColors.orange),
                      const SizedBox(height: 12),
                      Text(
                        'Tap the map or search to select location',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _useMyLocation,
                        icon: const Icon(Icons.navigation, color: Colors.white),
                        label: const Text('Use My Location', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
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
                      'Quick Actions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
