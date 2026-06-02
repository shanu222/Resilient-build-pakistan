import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../providers/app_providers.dart';

class EngineeringDetailScreen extends ConsumerWidget {
  const EngineeringDetailScreen({super.key, required this.componentId});

  final String componentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(jsonRepoProvider).getEngineeringNotes(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final components = snap.data!['components'] as List;
        final comp = components.cast<Map<String, dynamic>>().firstWhere(
              (c) => c['id'] == componentId,
              orElse: () => components.first as Map<String, dynamic>,
            );

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${comp['name']} Engineering'),
                  Text(
                    'Structural Component Detail',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appTokens.textOnPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Card(
                    color: const Color(0xFFE2E8F0),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF52525B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.appTokens.textOnPrimary.withValues(alpha: 0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 8),
                            Divider(color: AppColors.orange, thickness: 3),
                            Spacer(),
                            Divider(color: AppColors.orange, thickness: 3),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Purpose'),
                    Tab(text: 'Forces'),
                    Tab(text: 'Mistakes'),
                    Tab(text: 'Checklist'),
                  ],
                ),
                SizedBox(
                  height: 360,
                  child: TabBarView(
                    children: [
                      _card(context, 'Engineering Purpose', comp['purpose'] as String, [
                        comp['function'] as String,
                      ]),
                      _card(context, 'Load Transfer & Forces', comp['engineeringPrinciple'] as String, []),
                      _card(context, 'Common Mistakes', 'Failure Modes', [
                        ...(comp['failureModes'] as List).cast<String>(),
                      ]),
                      _checklist(comp),
                    ],
                  ),
                ),
                Card(
                  color: context.appTokens.success.withValues(alpha: 0.12),
                  child: ListTile(
                    leading: Icon(Icons.eco, color: context.appTokens.success),
                    title: Text(
                      'Resilience Benefit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.appTokens.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      comp['resilienceBenefit'] as String,
                      style: TextStyle(color: context.appTokens.textSecondary),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.tips_and_updates, color: context.appTokens.warning),
                    title: Text(
                      'Construction Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.appTokens.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      comp['constructionTips'] as String,
                      style: TextStyle(color: context.appTokens.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, String title, String body, List<String> bullets) {
    final tokens = context.appTokens;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(color: tokens.textSecondary),
            ),
            ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('• $b'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _checklist(Map<String, dynamic> comp) {
    final items = (comp['inspectionChecklist'] as List).cast<String>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inspection Checklist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...items.map(
              (i) => CheckboxListTile(
                value: false,
                onChanged: (_) {},
                title: Text(i, style: const TextStyle(fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
