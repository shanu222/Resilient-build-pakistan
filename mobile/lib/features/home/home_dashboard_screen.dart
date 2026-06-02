import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/widgets/responsive_page.dart';
import '../../core/widgets/section_header.dart';
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
    final theme = Theme.of(context);
    final isWide = AppBreakpoints.isDesktop(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroSection(
            districtsAsync: districtsAsync,
            selectedDistrict: _selectedDistrict,
            onDistrictChanged: (v) => setState(() => _selectedDistrict = v),
            onAnalyze: _analyzeDistrict,
            onGps: _useMyLocation,
            lastPlace: location.profile != null ? location.placeName : null,
            isWide: isWide,
          )),
          SliverToBoxAdapter(
            child: ResponsivePage(
              scrollable: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'Resilient construction journey',
                    subtitle:
                        'Assess hazards at your site, explore engineered models, and learn through the Digital Twin.',
                  ),
                  const SizedBox(height: 20),
                  _ActionGrid(isWide: isWide, onNavigate: (path) => context.push(path)),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.offline_bolt, color: AppColors.success),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Offline-first platform', style: theme.textTheme.titleSmall),
                                const SizedBox(height: 4),
                                Text(
                                  'Hazard data, BIM sequences, and NDMA-aligned guidance work without internet.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.districtsAsync,
    required this.selectedDistrict,
    required this.onDistrictChanged,
    required this.onAnalyze,
    required this.onGps,
    this.lastPlace,
    required this.isWide,
  });

  final AsyncValue<List<Map<String, dynamic>>> districtsAsync;
  final Map<String, dynamic>? selectedDistrict;
  final ValueChanged<Map<String, dynamic>?> onDistrictChanged;
  final VoidCallback onAnalyze;
  final VoidCallback onGps;
  final String? lastPlace;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = isWide ? 320.0 : 380.0;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.heroGradient,
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: 40,
            child: Icon(
              Icons.map_outlined,
              size: isWide ? 200 : 140,
              color: context.appTokens.textOnHero.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 20,
                vertical: 24,
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _heroCopy(context, theme.textTheme)),
                        const SizedBox(width: 32),
                        Expanded(child: _heroForm(context, districtsAsync)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _heroCopy(context, theme.textTheme),
                        const SizedBox(height: 20),
                        _heroForm(context, districtsAsync),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCopy(BuildContext context, TextTheme theme) {
    final hero = context.appTokens.textOnHero;
    final heroMuted = context.appTokens.textOnHeroMuted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
          ),
          child: const Text(
            'National Resilience Platform',
            style: TextStyle(color: AppColors.orangeLight, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Build safer across Pakistan',
          style: theme.headlineMedium?.copyWith(color: hero),
        ),
        const SizedBox(height: 8),
        Text(
          'District hazard intelligence, engineered housing models, and step-by-step Digital Twin construction — aligned with disaster-resilient practice.',
          style: theme.bodyMedium?.copyWith(color: heroMuted),
        ),
        if (lastPlace != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.history, size: 14, color: heroMuted),
              const SizedBox(width: 6),
              Text(
                'Last site: $lastPlace',
                style: TextStyle(color: heroMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _heroForm(BuildContext context, AsyncValue<List<Map<String, dynamic>>> districtsAsync) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select location', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            districtsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (districts) => DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedDistrict,
                decoration: const InputDecoration(labelText: 'District'),
                items: districts
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          '${d['name']} · ${d['provinceName']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onDistrictChanged,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Evaluate hazards & recommend models'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onGps,
              icon: const Icon(Icons.my_location),
              label: const Text('Use GPS location'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.isWide, required this.onNavigate});

  final bool isWide;
  final void Function(String path) onNavigate;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(Icons.map_outlined, 'Site assessment', 'View hazard profile', AppColors.orange, '/location/current'),
      _Action(Icons.home_work_outlined, 'Explore models', 'Resilient housing catalog', AppColors.navy, '/models'),
      _Action(Icons.menu_book_outlined, 'Engineering library', 'Guidelines, standards, and checklists', AppColors.steel, '/library'),
    ];

    if (isWide) {
      return Row(
        children: actions
            .map((a) => Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ActionCard(action: a, onTap: () => onNavigate(a.path)),
                )))
            .toList(),
      );
    }

    return Column(
      children: actions
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActionCard(action: a, onTap: () => onNavigate(a.path)),
              ))
          .toList(),
    );
  }
}

class _Action {
  const _Action(this.icon, this.title, this.subtitle, this.color, this.path);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String path;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.onTap});

  final _Action action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, style: Theme.of(context).textTheme.titleSmall),
                    Text(action.subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
