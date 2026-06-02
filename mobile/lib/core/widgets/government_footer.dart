import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GovernmentFooter extends StatelessWidget {
  const GovernmentFooter({
    super.key,
    required this.version,
  });

  final String version;

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.35,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Government of Pakistan'),
            const Text('National Disaster Management Authority (NDMA)'),
            const SizedBox(height: 6),
            const Text(
              'Resilient Build Pakistan Platform',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Version $version · © $year'),
          ],
        ),
      ),
    );
  }
}

