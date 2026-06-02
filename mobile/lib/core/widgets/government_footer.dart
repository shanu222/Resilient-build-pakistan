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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 2,
              children: [
                const Text('Government of Pakistan'),
                Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                const Text('NDMA'),
                Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                const Text(
                  'Resilient Build Pakistan',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                Text('v$version'),
                Text('· © $year'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

