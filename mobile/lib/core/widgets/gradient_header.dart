import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 120,
    this.child,
  });

  final String title;
  final String? subtitle;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyLight],
        ),
      ),
      child: child ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
    );
  }
}
