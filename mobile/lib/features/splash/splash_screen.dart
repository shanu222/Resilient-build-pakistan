import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/widgets/app_brand_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.navyLight, AppColors.navyMid],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppBrandLogo(size: 120)
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOut),
                const SizedBox(height: 32),
                const Text(
                  'ResilientBuild Pakistan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  '"Choose Location. Build Safe."',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 24),
                const Text(
                  'Build Smarter.\nBuild Safer.\nBuild for Pakistan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 48),
                PrimaryButton(
                  label: 'Get Started',
                  onPressed: () => context.go('/onboarding'),
                ).animate().fadeIn(delay: 900.ms),
                const Spacer(),
                Text(
                  'Public engineering education · Offline-first',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ).animate().fadeIn(delay: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
