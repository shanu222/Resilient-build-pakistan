import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'engineering_manual_generator.dart';

class EngineeringManualScreen extends StatefulWidget {
  const EngineeringManualScreen({
    super.key,
    this.initialSearch,
  });

  final String? initialSearch;

  @override
  State<EngineeringManualScreen> createState() => _EngineeringManualScreenState();
}

class _EngineeringManualScreenState extends State<EngineeringManualScreen> {
  final PdfViewerController _controller = PdfViewerController();
  late final Future<List<int>> _bytes = _build();

  Future<List<int>> _build() async {
    final data = await EngineeringManualGenerator.generatePdf(
      title: 'Construction Guidelines & Engineering Manual',
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering manual', style: TextStyle(fontSize: 16)),
      ),
      body: FutureBuilder<List<int>>(
        future: _bytes,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bytes = snap.data!;
          return SfPdfViewer.memory(
            bytes,
            controller: _controller,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            enableTextSelection: true,
            onDocumentLoaded: (_) {
              final q = widget.initialSearch;
              if (q == null || q.trim().isEmpty) return;
              _controller.searchText(q);
            },
          );
        },
      ),
    );
  }
}

