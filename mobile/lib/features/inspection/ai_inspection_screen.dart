import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';
import 'ai_inspection_service.dart';

class AiInspectionScreen extends ConsumerStatefulWidget {
  const AiInspectionScreen({super.key});

  @override
  ConsumerState<AiInspectionScreen> createState() => _AiInspectionScreenState();
}

class _AiInspectionScreenState extends ConsumerState<AiInspectionScreen> {
  AiInspectionResult? _result;
  bool _loading = false;
  String? _imagePath;

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _loading = true;
      _imagePath = file.path;
    });
    final result = await ref.read(aiInspectionProvider).analyzeConstructionPhoto(
          imagePath: file.path,
          options: const AiInspectionOptions(),
        );
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'AI Site Inspection',
            subtitle: 'Upload construction photos for analysis',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (_result == null && !_loading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.camera_alt, size: 64, color: AppColors.steel),
                          const SizedBox(height: 16),
                          const Text('Upload Construction Photo',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text(
                            'Take a photo of rebar, columns, beams, or structural elements',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _pick(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Take Photo'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pick(ImageSource.gallery),
                                  icon: const Icon(Icons.upload),
                                  label: const Text('Upload'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (_result != null) ...[
                  if (_imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_imagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text('Model: ${_result!.modelVersion}',
                      style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ..._result!.findings.map(_findingCard),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _findingCard(InspectionFinding f) {
    final (color, bg, icon) = switch (f.status) {
      InspectionStatus.pass => (AppColors.success, Colors.green.shade50, Icons.check_circle),
      InspectionStatus.warning => (AppColors.orange, Colors.orange.shade50, Icons.warning),
      InspectionStatus.critical => (AppColors.hazard, Colors.red.shade50, Icons.cancel),
      _ => (AppColors.steel, AppColors.muted, Icons.hourglass_empty),
    };
    return Card(
      color: bg,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(f.item, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(f.details),
        trailing: Text('${(f.confidence * 100).round()}%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
