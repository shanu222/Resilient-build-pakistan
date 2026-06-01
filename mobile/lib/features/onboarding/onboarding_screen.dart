import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slides = [
    (
      title: 'Location-Based Construction Intelligence',
      body: 'Map of Pakistan with hazard overlays for your build site.',
      icon: Icons.map,
      colors: [AppColors.navy, AppColors.navyMid],
    ),
    (
      title: 'Engineering Animations',
      body: '3D house assembling from excavation to completion.',
      icon: Icons.view_in_ar,
      colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    ),
    (
      title: 'Resilience Scoring',
      body: 'Flood, earthquake, and landslide shields for every model.',
      icon: Icons.shield,
      colors: [AppColors.success, Color(0xFF059669)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: s.colors),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(s.icon, size: 80, color: Colors.white),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? AppColors.orange : AppColors.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                label: _page == _slides.length - 1 ? 'Start Exploring' : 'Next',
                onPressed: () async {
                  if (_page < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    await ref.read(localStorageProvider).setOnboardingComplete();
                    if (context.mounted) context.go('/home');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
