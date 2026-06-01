import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';

class MarketPricesScreen extends ConsumerWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(locale: 'en_PK', symbol: 'PKR ', decimalDigits: 0);

    return FutureBuilder(
      future: ref.read(jsonRepoProvider).getHouses(),
      builder: (context, snap) {
        final houses = snap.data ?? [];
        return Scaffold(
          body: Column(
            children: [
              const GradientHeader(
                title: 'Cost Estimates',
                subtitle: 'Material, labour, and duration by model',
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: houses.length,
                  itemBuilder: (_, i) {
                    final h = houses[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.name,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Materials: ${formatter.format(h.estimatedMaterialCostPkr)}'),
                            Text('Labour: ${formatter.format(h.estimatedLabourCostPkr)}'),
                            Text(
                              'Total: ${formatter.format(h.totalEstimatedCostPkr)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(h.costCategory.toUpperCase()),
                                  backgroundColor: _costColor(h.costCategory),
                                ),
                                const SizedBox(width: 8),
                                Text('${h.constructionDurationDays} days'),
                              ],
                            ),
                          ],
                        ),
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

  Color _costColor(String cat) {
    switch (cat) {
      case 'low':
        return Colors.green.shade100;
      case 'premium':
        return Colors.purple.shade100;
      case 'high':
        return Colors.orange.shade100;
      default:
        return AppColors.muted;
    }
  }
}
