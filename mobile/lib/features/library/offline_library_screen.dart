import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';
import '../downloads/download_center_screen.dart';
import '../pdf/pdf_viewer_screen.dart';

/// Bundled PDFs, engineering notes, and saved offline content — no account required.
class OfflineLibraryScreen extends ConsumerWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housesAsync = ref.watch(housesProvider);

    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Guidance Library',
            subtitle: 'PDFs and engineering references — works fully offline',
          ),
          Expanded(
            child: housesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (houses) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: AppColors.navy,
                    child: ListTile(
                      leading: const Icon(Icons.cloud_off, color: Colors.white),
                      title: const Text(
                        'Offline-first',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'All models, animations, and guidance are bundled. No login or internet required.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: const Text('Downloaded content'),
                    subtitle: const Text('Saved PDFs and notes on this device'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DownloadCenterScreen()),
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Model guidance (PDF)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  ...houses.where((h) => h.pdfAsset.isNotEmpty).map((h) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(h.name),
                        subtitle: Text(h.category),
                        trailing: const Icon(Icons.picture_as_pdf),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                assetPath: h.pdfAsset,
                                title: h.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/materials'),
                    icon: const Icon(Icons.construction),
                    label: const Text('Materials engineering reference'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
