import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../providers/app_providers.dart';

class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(localStorageProvider);
    final bookmarked = storage.isPdfBookmarked(assetPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () async {
              await storage.togglePdfBookmark(assetPath);
              if (context.mounted) {
                (context as Element).markNeedsBuild();
              }
            },
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        assetPath,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'PDF not found in assets. Add file to assets/pdfs/ for offline viewing.',
              ),
            ),
          );
        },
      ),
    );
  }
}
