import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme_extensions.dart';

class GovernmentFooter extends StatelessWidget {
  const GovernmentFooter({
    super.key,
    required this.version,
  });

  final String version;

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final tokens = context.appTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.headerBackground,
        border: Border(top: BorderSide(color: tokens.border.withValues(alpha: 0.35))),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: tokens.textOnPrimary.withValues(alpha: 0.82),
              height: 1.25,
              fontSize: 10,
            ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 2,
          children: [
            const Text('Government of Pakistan', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('·', style: TextStyle(color: tokens.textOnPrimary.withValues(alpha: 0.5))),
            const Text('NDMA'),
            Text('·', style: TextStyle(color: tokens.textOnPrimary.withValues(alpha: 0.5))),
            Text('v$version'),
            Text('·', style: TextStyle(color: tokens.textOnPrimary.withValues(alpha: 0.5))),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: tokens.textOnPrimary.withValues(alpha: 0.9),
              ),
              child: const Text('Documentation'),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: tokens.textOnPrimary.withValues(alpha: 0.9),
              ),
              child: const Text('Support'),
            ),
            Text('· © $year', style: TextStyle(color: tokens.textOnPrimary.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

