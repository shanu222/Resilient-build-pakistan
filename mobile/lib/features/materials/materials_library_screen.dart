import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_extensions.dart';
import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';

class MaterialsLibraryScreen extends ConsumerWidget {
  const MaterialsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(jsonRepoProvider).getMaterials(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final materials = snap.data!['materials'] as List;

        return Scaffold(
          body: Column(
            children: [
              const GradientHeader(
                title: 'Materials Library',
                subtitle: 'Specifications and engineering purpose',
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: materials.length,
                  itemBuilder: (_, i) {
                    final m = materials[i] as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.inventory_2),
                        ),
                        title: Text(m['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(m['specification'] as String,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _row(context, 'Purpose', m['engineeringPurpose'] as String),
                                _row(context, 'Advantages', (m['advantages'] as List).join(', ')),
                                _row(context, 'Disadvantages', (m['disadvantages'] as List).join(', ')),
                                _row(context, 'Expected Life', '${m['expectedLifeYears']} years'),
                                _row(context, 'Maintenance', m['maintenance'] as String),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: tokens.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: tokens.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
