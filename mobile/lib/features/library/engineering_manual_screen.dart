import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';

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
  late final Future<Uint8List> _bytes = _build();

  Future<Uint8List> _build() async {
    return EngineeringManualGenerator.generatePdf(
      title: 'Construction Guidelines & Engineering Manual',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering manual', style: TextStyle(fontSize: 16)),
      ),
      body: FutureBuilder<Uint8List>(
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

