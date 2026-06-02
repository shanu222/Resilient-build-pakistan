import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/house_model.dart';
import 'model_manual_generator.dart';

class ModelManualScreen extends StatefulWidget {
  const ModelManualScreen({
    super.key,
    required this.house,
  });

  final HouseModel house;

  @override
  State<ModelManualScreen> createState() => _ModelManualScreenState();
}

class _ModelManualScreenState extends State<ModelManualScreen> {
  final PdfViewerController _controller = PdfViewerController();
  late final Future<Uint8List> _bytes = _loadOrGenerate();

  Future<Uint8List> _loadOrGenerate() async {
    final asset = ModelManualGenerator.manualAssetPathFor(widget.house.id);
    try {
      final data = await rootBundle.load(asset);
      return data.buffer.asUint8List();
    } catch (_) {
      // Fallback: generate at runtime so the manual is never blank/missing in dev.
      final govt = (await rootBundle.load('assets/images/branding/govt_pakistan.png')).buffer.asUint8List();
      final ndma = (await rootBundle.load('assets/images/branding/ndma.png')).buffer.asUint8List();
      final input = await _loadInputFromBundle(modelId: widget.house.id);
      return ModelManualGenerator.generateModelManualPdf(
        input: input,
        govtLogoPng: govt,
        ndmaLogoPng: ndma,
      );
    }
  }

  Future<ModelManualInput> _loadInputFromBundle({required String modelId}) async {
    final housesRaw = await rootBundle.loadString('assets/data/houses.json');
    final houses = jsonDecode(housesRaw) as Map<String, dynamic>;
    final models = (houses['models'] as List).cast<Map<String, dynamic>>();
    final house = models.firstWhere((m) => m['id'] == modelId);

    final materialsRaw = await rootBundle.loadString('assets/data/materials.json');
    final materialsJson = jsonDecode(materialsRaw) as Map<String, dynamic>;
    final materialsList =
        (materialsJson['materials'] as List).cast<Map<String, dynamic>>();
    final materialsById = {
      for (final m in materialsList) (m['id'] as String): m,
    };

    final materialIds = (house['materialIds'] as List).cast<String>();
    final materials = materialIds.map((id) {
      final m = materialsById[id]!;
      return MaterialSpec(
        id: id,
        name: m['name'] as String,
        specification: m['specification'] as String,
        engineeringPurpose: m['engineeringPurpose'] as String,
        qualityPoints: const [
          'Verify specification compliance (site test + supplier certificate).',
          'Reject damaged/contaminated material; store dry and protected.',
          'Record batch/lot for traceability.',
        ],
      );
    }).toList();

    final stages = await _loadStagesBundle(modelId);
    final stageDocs = _normalizeStagesForManual(modelId: modelId, stages: stages);

    return ModelManualInput(
      modelId: modelId,
      modelName: house['name'] as String,
      category: house['category'] as String,
      hazardsCovered: (house['hazardsCovered'] as List).cast<String>(),
      engineeringSummary: house['engineeringSummary'] as String,
      advantages: (house['advantages'] as List).cast<String>(),
      limitations: (house['limitations'] as List).cast<String>(),
      resilienceFeatures: (house['resilienceFeatures'] as List).cast<String>(),
      materials: materials,
      stageDocs: stageDocs,
    );
  }

  Future<List<Map<String, dynamic>>> _loadStagesBundle(String modelId) async {
    // Match the same BIM-preferred mapping as build-time tool.
    final bim = <String, String>{
      'interlocking_brick_masonry': 'assets/data/bim_interlocking_brick.json',
      'advanced_interlocking_brick_masonry': 'assets/data/bim_advanced_interlocking.json',
      'reinforced_adobe_brick_structure': 'assets/data/bim_reinforced_adobe.json',
      'raised_plinth_flood_resilient_house': 'assets/data/bim_raised_plinth.json',
      'cement_bamboo_frame': 'assets/data/bim_cement_bamboo.json',
      'light_gauge_steel_house': 'assets/data/bim_light_gauge_steel.json',
      'elevated_flood_resilient_house': 'assets/data/bim_elevated_flood.json',
      'floating_amphibious_structure': 'assets/data/bim_amphibious.json',
      'rat_trap_bond_masonry': 'assets/data/bim_rat_trap_bond.json',
      'geogrid_reinforced_retaining_wall': 'assets/data/bim_geogrid.json',
      'timber_frame_lath_plaster': 'assets/data/bim_timber_frame.json',
      'pre_fabricated_house': 'assets/data/bim_prefabricated.json',
      'confined_concrete_block_masonry': 'assets/data/bim_confined_block.json',
      'loh_kaat_timber_house': 'assets/data/bim_loh_kaat.json',
      'fly_ash_masonry': 'assets/data/bim_fly_ash.json',
      'earthbag_masonry': 'assets/data/bim_earthbag.json',
    };
    final path = bim[modelId] ?? 'assets/data/digital_twin/$modelId.json';
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['stages'] as List).cast<Map<String, dynamic>>();
  }

  List<StageDoc> _normalizeStagesForManual({
    required String modelId,
    required List<Map<String, dynamic>> stages,
  }) {
    return ModelManualGenerator.normalizeStages(modelId: modelId, stages: stages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.house.name, style: const TextStyle(fontSize: 16)),
      ),
      body: FutureBuilder<Uint8List>(
        future: _bytes,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData) {
            return const Center(
              child: Text('Manual could not be generated.'),
            );
          }
          return Container(
            color: AppColors.background,
            child: SfPdfViewer.memory(
              snap.data!,
              controller: _controller,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableTextSelection: true,
            ),
          );
        },
      ),
    );
  }
}

