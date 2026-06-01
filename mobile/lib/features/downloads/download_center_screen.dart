import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';
import '../pdf/pdf_viewer_screen.dart';

class DownloadCenterScreen extends ConsumerWidget {
  const DownloadCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(jsonRepoProvider).getHouses(),
      builder: (context, snap) {
        final houses = snap.data ?? [];
        final bookmarks = ref.watch(localStorageProvider).bookmarkedPdfs;

        return Scaffold(
          body: Column(
            children: [
              const GradientHeader(
                title: 'Download Center',
                subtitle: 'PDFs and offline content',
              ),
              if (bookmarks.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Bookmarks',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                ...bookmarks.map(
                  (path) => ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(path.split('/').last),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => PdfViewerScreen(
                          assetPath: path,
                          title: path.split('/').last,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: houses.length,
                  itemBuilder: (_, i) {
                    final h = houses[i];
                    return ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text(h.name),
                      subtitle: Text(h.pdfAsset),
                      trailing: const Icon(Icons.download),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => PdfViewerScreen(
                            assetPath: h.pdfAsset,
                            title: h.name,
                          ),
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
}
