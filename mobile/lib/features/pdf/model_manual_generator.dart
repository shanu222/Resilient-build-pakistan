import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ModelManualInput {
  const ModelManualInput({
    required this.modelId,
    required this.modelName,
    required this.category,
    required this.hazardsCovered,
    required this.engineeringSummary,
    required this.advantages,
    required this.limitations,
    required this.resilienceFeatures,
    required this.materials,
    required this.stageDocs,
  });

  final String modelId;
  final String modelName;
  final String category;
  final List<String> hazardsCovered;
  final String engineeringSummary;
  final List<String> advantages;
  final List<String> limitations;
  final List<String> resilienceFeatures;
  final List<MaterialSpec> materials;
  final List<StageDoc> stageDocs; // 13 items
}

class MaterialSpec {
  const MaterialSpec({
    required this.id,
    required this.name,
    required this.specification,
    required this.engineeringPurpose,
    required this.qualityPoints,
  });

  final String id;
  final String name;
  final String specification;
  final String engineeringPurpose;
  final List<String> qualityPoints;
}

class StageDoc {
  const StageDoc({
    required this.index,
    required this.title,
    required this.purpose,
    required this.procedure,
    required this.materials,
    required this.inspectionChecklist,
    required this.commonMistakes,
    required this.qualityChecks,
    required this.safety,
  });

  final int index; // 0..12
  final String title;
  final String purpose;
  final List<String> procedure;
  final List<String> materials;
  final List<String> inspectionChecklist;
  final List<String> commonMistakes;
  final List<String> qualityChecks;
  final List<String> safety;
}

abstract final class ModelManualGenerator {
  static const manualDir = 'assets/pdfs';

  static String manualAssetPathFor(String modelId) =>
      'assets/pdfs/${modelId}_manual.pdf';

  /// Normalize arbitrary stage sources to the canonical 13-stage engineering schema.
  /// This must match the Digital Twin’s canonical stage list.
  static List<StageDoc> normalizeStages({
    required String modelId,
    required List<Map<String, dynamic>> stages,
  }) {
    // Canonical 13 titles as per requirement (index → title).
    const canonical = [
      'Site Layout',
      'Excavation',
      'Foundation',
      'Columns',
      'Plinth Beam',
      'Floor System',
      'Walls',
      'Openings',
      'Lintel Band',
      'Roof Structure',
      'Roof Cover',
      'Services',
      'Final Inspection',
    ];

    // Convert source stages to 13 docs by mapping/merging nearest stages.
    final normalized = <StageDoc>[];
    for (var i = 0; i < canonical.length; i++) {
      final title = canonical[i];
      final s = _bestStageFor(title: title, stages: stages) ?? (stages.isNotEmpty ? stages.first : const {});
      final narration = (s['narration'] as String?) ?? '';
      final explanation = (s['explanation'] as String?) ?? narration;
      normalized.add(
        StageDoc(
          index: i,
          title: title,
          purpose: explanation.isEmpty ? 'Engineering purpose for $title.' : explanation,
          materials: _materialsForStage(title),
          procedure: _procedureForStage(title, modelId),
          inspectionChecklist: _inspectionForStage(title),
          commonMistakes: _commonMistakesForStage(title),
          qualityChecks: _qualityChecksForStage(title),
          safety: _safetyForStage(title),
        ),
      );
    }
    return normalized;
  }

  static Future<ModelManualInput> loadInputFromAssets({
    required String repoRoot, // .../mobile
    required String modelId,
  }) async {
    final houses = jsonDecode(
      await File('$repoRoot/assets/data/houses.json').readAsString(),
    ) as Map<String, dynamic>;
    final models = (houses['models'] as List).cast<Map<String, dynamic>>();
    final house = models.firstWhere((m) => m['id'] == modelId);

    final materialsJson = jsonDecode(
      await File('$repoRoot/assets/data/materials.json').readAsString(),
    ) as Map<String, dynamic>;
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
        qualityPoints: [
          'Verify specification compliance (site test + supplier certificate).',
          'Reject damaged/contaminated material; store dry and protected.',
          'Record batch/lot for traceability.',
        ],
      );
    }).toList();

    final stageDocs = await _loadAndNormalizeStages(repoRoot: repoRoot, modelId: modelId);

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

  static Future<List<StageDoc>> _loadAndNormalizeStages({
    required String repoRoot,
    required String modelId,
  }) async {
    // Prefer BIM stage definitions when present, otherwise fallback to digital_twin manifest stages.
    final bimFileCandidates = <String>[
      // Known names are not 1:1; map modelId → bim file where needed.
      if (modelId == 'interlocking_brick_masonry') 'bim_interlocking_brick.json',
      if (modelId == 'advanced_interlocking_brick_masonry') 'bim_advanced_interlocking.json',
      if (modelId == 'reinforced_adobe_brick_structure') 'bim_reinforced_adobe.json',
      if (modelId == 'raised_plinth_flood_resilient_house') 'bim_raised_plinth.json',
      if (modelId == 'cement_bamboo_frame') 'bim_cement_bamboo.json',
      if (modelId == 'light_gauge_steel_house') 'bim_light_gauge_steel.json',
      if (modelId == 'elevated_flood_resilient_house') 'bim_elevated_flood.json',
      if (modelId == 'floating_amphibious_structure') 'bim_amphibious.json',
      if (modelId == 'rat_trap_bond_masonry') 'bim_rat_trap_bond.json',
      if (modelId == 'geogrid_reinforced_retaining_wall') 'bim_geogrid.json',
      if (modelId == 'timber_frame_lath_plaster') 'bim_timber_frame.json',
      if (modelId == 'pre_fabricated_house') 'bim_prefabricated.json',
      if (modelId == 'confined_concrete_block_masonry') 'bim_confined_block.json',
      if (modelId == 'loh_kaat_timber_house') 'bim_loh_kaat.json',
      if (modelId == 'fly_ash_masonry') 'bim_fly_ash.json',
      if (modelId == 'earthbag_masonry') 'bim_earthbag.json',
    ];

    Map<String, dynamic> srcJson;
    if (bimFileCandidates.isNotEmpty) {
      final p = '$repoRoot/assets/data/${bimFileCandidates.first}';
      srcJson = jsonDecode(await File(p).readAsString()) as Map<String, dynamic>;
    } else {
      final p = '$repoRoot/assets/data/digital_twin/$modelId.json';
      srcJson = jsonDecode(await File(p).readAsString()) as Map<String, dynamic>;
    }

    final stages = (srcJson['stages'] as List).cast<Map<String, dynamic>>();
    return normalizeStages(modelId: modelId, stages: stages);
  }

  static Map<String, dynamic>? _bestStageFor({
    required String title,
    required List<Map<String, dynamic>> stages,
  }) {
    final t = title.toLowerCase();
    Map<String, dynamic>? best;
    var bestScore = -1;
    for (final s in stages) {
      final key = (s['key'] as String? ?? '').toLowerCase();
      final st = (s['title'] as String? ?? '').toLowerCase();
      final text = '$key $st';
      var score = 0;
      if (text.contains('site')) score += t.contains('site') ? 3 : 0;
      if (text.contains('excav')) score += t.contains('excav') ? 3 : 0;
      if (text.contains('found') || text.contains('foot')) score += t.contains('found') ? 3 : 0;
      if (text.contains('column')) score += t.contains('column') ? 3 : 0;
      if (text.contains('plinth')) score += t.contains('plinth') ? 3 : 0;
      if (text.contains('floor')) score += t.contains('floor') ? 3 : 0;
      if (text.contains('wall')) score += t.contains('walls') ? 3 : 0;
      if (text.contains('opening') || text.contains('window') || text.contains('door')) {
        score += t.contains('open') ? 3 : 0;
      }
      if (text.contains('lintel') || text.contains('band') || text.contains('ring')) {
        score += t.contains('lintel') ? 3 : 0;
      }
      if (text.contains('roof')) score += t.contains('roof') ? 2 : 0;
      if (text.contains('service')) score += t.contains('services') ? 3 : 0;
      if (text.contains('inspect')) score += t.contains('inspection') ? 3 : 0;
      if (score > bestScore) {
        bestScore = score;
        best = s;
      }
    }
    return best;
  }

  static List<String> _materialsForStage(String title) => switch (title) {
        'Site Layout' => ['Survey pegs, chalk line, measuring tape, benchmarks'],
        'Excavation' => ['Excavation tools/equipment, spoil management materials'],
        'Foundation' => ['PCC, reinforcement, concrete, formwork as required'],
        'Columns' => ['Bars, ties/stirrups, formwork, concrete/structural members'],
        'Plinth Beam' => ['Rebar cage, formwork, concrete, DPC membrane'],
        'Floor System' => ['Slab mesh, joists/panels, anchors (system-specific)'],
        'Walls' => ['Wall units, mortar/grout, ties, reinforcement'],
        'Openings' => ['Frames, lintels, fasteners, seals'],
        'Lintel Band' => ['Band reinforcement, formwork, concrete'],
        'Roof Structure' => ['Trusses/rafters, purlins, bracing, connectors'],
        'Roof Cover' => ['Sheets/tiles, fasteners, flashing, ridge components'],
        'Services' => ['Conduits, plumbing, sleeves, penetrations sealing'],
        'Final Inspection' => ['Checklists, measuring tools, photographs, records'],
        _ => const [],
      };

  static List<String> _procedureForStage(String title, String modelId) {
    // Keep practical and aligned to the app’s 13-stage sequencing.
    switch (title) {
      case 'Site Layout':
        return const [
          'Establish a benchmark and verify plot boundaries.',
          'Mark grid lines and footprint centerlines with diagonals for squareness.',
          'Confirm drainage direction and finished floor level reference.',
        ];
      case 'Excavation':
        return const [
          'Excavate to the specified depth and competent bearing stratum.',
          'Keep trench sides stable; remove loose soil and standing water.',
          'Maintain line and level; do not over-excavate—rectify with lean concrete if needed.',
        ];
      case 'Foundation':
        return const [
          'Place PCC blinding to provide a clean, level base.',
          'Install reinforcement with correct cover and laps; use chairs/cover blocks.',
          'Pour concrete continuously where specified; vibrate and cure properly.',
        ];
      case 'Columns':
        return const [
          'Fix starter bars/dowels and verify verticality and spacing.',
          'Install ties/stirrups at specified spacing; secure cage against displacement.',
          'Erect formwork (if RC) or assemble primary posts/members (if bamboo/timber/steel).',
        ];
      case 'Plinth Beam':
        return const [
          'Install plinth reinforcement cage and verify continuity through corners.',
          'Cast plinth beam and integrate vertical bars; ensure correct cover.',
          'Install DPC/moisture barrier above plinth with continuous laps.',
        ];
      case 'Floor System':
        return const [
          'Install floor framing/panels/slab reinforcement as per system.',
          'Provide anchorage to plinth/columns; verify bearing and level.',
          'Seal service penetrations and confirm stiffness/diaphragm continuity.',
        ];
      case 'Walls':
        return [
          'Construct walls in lifts with continuous alignment checks (plumb and level).',
          if (modelId.contains('interlocking')) 'Maintain interlock engagement; align vertical cores for bars/grout.',
          if (modelId.contains('earthbag')) 'Compact each course; place barbed wire continuously between layers.',
          'Integrate ties/mesh/reinforcement where specified to prevent separation.',
        ];
      case 'Openings':
        return const [
          'Set door/window frames plumb, level, and anchored to the wall/frame.',
          'Maintain clearances and verify lintel seat/bearing locations.',
          'Protect openings from distortion during curing and loading.',
        ];
      case 'Lintel Band':
        return const [
          'Fix band reinforcement with proper laps and corner continuity.',
          'Install formwork; pour and cure RC band/ring beam continuously.',
          'Ensure connection to vertical reinforcement for seismic continuity.',
        ];
      case 'Roof Structure':
        return const [
          'Assemble trusses/rafters/purlins with bracing and correct connector detailing.',
          'Anchor roof structure to bands/wall plates; provide uplift tie-down path.',
          'Verify geometry, bracing lines, and load path continuity.',
        ];
      case 'Roof Cover':
        return const [
          'Fix roof covering with correct fastener spacing and edge distances.',
          'Provide ridge/valley flashing; ensure overlaps follow wind-driven rain direction.',
          'Seal penetrations; verify no loose sheets or missing screws.',
        ];
      case 'Services':
        return const [
          'Route electrical/plumbing services through sleeves; avoid cutting structural members.',
          'Seal all penetrations to control moisture ingress.',
          'Test systems before finishes and handover.',
        ];
      case 'Final Inspection':
        return const [
          'Verify structural continuity: roof-to-wall/frame-to-foundation load path.',
          'Complete checklists, record measurements, and photograph critical details.',
          'Confirm hazard-specific features are complete (bands, bracing, drainage).',
        ];
      default:
        return const [];
    }
  }

  static List<String> _inspectionForStage(String title) => switch (title) {
        'Site Layout' => [
            'Grid squareness verified by diagonals',
            'Footprint centered and setbacks verified',
            'Benchmark and levels recorded',
          ],
        'Excavation' => [
            'Depth and width match drawings',
            'Bearing soil confirmed; no loose/organic fill',
            'Trench base level and dry; no standing water',
          ],
        'Foundation' => [
            'PCC thickness and level verified',
            'Rebar size/spacing/laps/cover verified',
            'Concrete vibration and curing plan confirmed',
          ],
        'Columns' => [
            'Starter bars verticality and anchorage checked',
            'Stirrups/ties spacing checked',
            'Member alignment on grid verified',
          ],
        'Plinth Beam' => [
            'Continuity through corners verified',
            'DPC installed continuous with laps',
            'Plinth top level and true',
          ],
        'Floor System' => [
            'Bearing and level verified',
            'Anchorage to supports verified',
            'Service penetrations sealed',
          ],
        'Walls' => [
            'Plumbness and level checked per lift',
            'Reinforcement/mesh continuity verified',
            'Openings dimensions maintained',
          ],
        'Openings' => [
            'Frames plumb and anchored',
            'Lintel bearing length verified',
            'No distortion before curing',
          ],
        'Lintel Band' => [
            'Corner continuity and laps verified',
            'Concrete cover and curing verified',
            'Connection to vertical bars confirmed',
          ],
        'Roof Structure' => [
            'Bracing installed as per layout',
            'Tie-down/anchors complete',
            'No member damage/splitting/warping',
          ],
        'Roof Cover' => [
            'Fastener spacing and washers verified',
            'Overlaps and flashing correct',
            'Penetrations sealed',
          ],
        'Services' => [
            'No structural members cut without approval',
            'Electrical/plumbing tested',
            'Moisture sealing complete',
          ],
        'Final Inspection' => [
            'All hazard features present',
            'QC records complete',
            'Final safety and occupancy checks signed',
          ],
        _ => const [],
      };

  static List<String> _commonMistakesForStage(String title) => switch (title) {
        'Excavation' => ['Over-excavation without rectification', 'Spoil piled at trench edge'],
        'Foundation' => ['Steel placed directly on soil', 'Insufficient cover blocks'],
        'Walls' => ['Cumulative out-of-plumb', 'Missing ties/mesh at corners and openings'],
        'Roof Cover' => ['Missing screws at edges', 'Incorrect overlap direction'],
        _ => ['Skipped inspection checks', 'No record of measurements'],
      };

  static List<String> _qualityChecksForStage(String title) => switch (title) {
        'Foundation' => ['Concrete batch and curing logged', 'Rebar checklist signed'],
        'Walls' => ['Daily plumb/level log', 'Material batch/strength verified'],
        'Roof Structure' => ['Connection count verified', 'Bracing pattern verified'],
        _ => ['Checklist completed and filed'],
      };

  static List<String> _safetyForStage(String title) => switch (title) {
        'Excavation' => ['Shoring/benching where needed', 'Safe access and edge protection'],
        'Roof Structure' => ['Fall protection', 'Stable scaffolds and lifting plan'],
        _ => ['PPE used', 'Housekeeping maintained'],
      };

  static Future<Uint8List> generateModelManualPdf({
    required ModelManualInput input,
    required Uint8List govtLogoPng,
    required Uint8List ndmaLogoPng,
  }) async {
    final doc = pw.Document(
      title: '${input.modelName} — Engineering Manual',
      author: 'Government of Pakistan / NDMA',
      creator: 'Resilient Build Pakistan',
      subject: 'Engineering guidelines and construction sequencing',
    );

    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      italic: pw.Font.helveticaOblique(),
      boldItalic: pw.Font.helveticaBoldOblique(),
    );

    final govtImg = pw.MemoryImage(govtLogoPng);
    final ndmaImg = pw.MemoryImage(ndmaLogoPng);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 36),
        header: (ctx) => _pdfHeader(
          govtImg: govtImg,
          ndmaImg: ndmaImg,
          title: 'Resilient Build Pakistan',
          subtitle: '${input.modelName} · Engineering Guidelines Manual',
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Government of Pakistan · NDMA',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Text(
              'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (ctx) {
          final w = <pw.Widget>[];

          // Cover block
          w.add(
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 6, bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    input.modelName,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Category: ${input.category}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Intended hazards: ${input.hazardsCovered.join(', ')}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                  ),
                ],
              ),
            ),
          );

          // TOC (clickable anchors)
          const toc = [
            ('overview', '1. Overview'),
            ('principles', '2. Engineering Principles'),
            ('materials', '3. Materials'),
            ('sequence', '4. Construction Sequence (13 stages)'),
            ('details', '5. Structural Details'),
            ('hazards', '6. Hazard Performance'),
            ('inspection', '7. Inspection Checklist'),
            ('failures', '8. Common Failures'),
            ('maintenance', '9. Maintenance'),
            ('bimref', '10. BIM Construction Reference'),
          ];
          w.add(_tocBlock(toc));

          // Section 1
          w.add(pw.Anchor(
            name: 'overview',
            child: _sectionTitle('1. Overview'),
          ));
          w.add(_para(input.engineeringSummary));
          w.add(_subTitle('Resilience strategy'));
          w.add(_bullets(input.resilienceFeatures));
          w.add(_subTitle('Advantages'));
          w.add(_bullets(input.advantages));
          w.add(_subTitle('Limitations'));
          w.add(_bullets(input.limitations));

          // Section 2
          w.add(pw.Anchor(name: 'principles', child: _sectionTitle('2. Engineering Principles')));
          w.add(_para('Load transfer and hazard performance are explained using standard structural engineering terminology. '
              'The design philosophy for this model emphasizes continuity, ductility, and moisture control.'));
          w.add(_subTitle('Gravity loads'));
          w.add(_para('Gravity loads are transferred from roof system → walls/frame → bands/beams → foundation → soil. '
              'Ensure bearing and continuity at each interface to avoid differential settlement and cracking.'));
          w.add(_subTitle('Lateral loads (earthquake/wind)'));
          w.add(_para('Lateral resistance depends on the system type: bands/ring beams and confinement for masonry; bracing and ductile joints for bamboo/timber; sheathing diaphragms and bracing for light gauge steel; buoyancy guidance for amphibious systems.'));
          w.add(_subTitle('Moisture and durability'));
          w.add(_para('Moisture control is achieved with plinth height, DPC/capillary breaks, drainage, protected finishes, and sealed penetrations.'));

          // Section 3
          w.add(pw.Anchor(name: 'materials', child: _sectionTitle('3. Materials')));
          for (final m in input.materials) {
            w.add(_materialCard(m));
          }

          // Section 4
          w.add(pw.Anchor(name: 'sequence', child: _sectionTitle('4. Construction Sequence (13 stages)')));
          for (final s in input.stageDocs) {
            w.add(_stageBlock(s));
          }

          // Section 5
          w.add(pw.Anchor(name: 'details', child: _sectionTitle('5. Structural Details')));
          w.add(_para('Structural detailing governs performance. Confirm foundation type, wall/frame system, roof system, and connection/anchorage detailing match the Digital Twin sequence.'));
          w.add(_subTitle('Connections and anchorage'));
          w.add(_para('Connections must complete the load path and be inspectable. Typical issues include missing anchors, insufficient development length, splitting at bamboo/timber joints, and incomplete grouting in reinforced masonry.'));
          w.add(_subTitle('Bracing and bands'));
          w.add(_para('Bands/ring beams (masonry) and bracing (frames) provide lateral stability. Ensure continuity through corners and correct fastening patterns.'));

          // Section 6
          w.add(pw.Anchor(name: 'hazards', child: _sectionTitle('6. Hazard Performance')));
          w.add(_bullets([
            'Earthquake: ductility and continuity via bands, confinement, bracing and anchored reinforcement.',
            'Flood: elevation, raised plinth, drainage, and moisture barriers; avoid undermining and scour.',
            'Wind: roof tie-down and bracing prevent uplift and racking.',
            'Landslide (if applicable): slope drainage and retaining mechanics; avoid water pressure build-up.',
            'Thermal/moisture: insulation/cavity strategies and protected finishes.',
          ]));

          // Section 7
          w.add(pw.Anchor(name: 'inspection', child: _sectionTitle('7. Inspection Checklist')));
          w.add(_para('Use this checklist during construction and before occupancy. Record measurements, photos, and nonconformities.'));
          for (final s in input.stageDocs) {
            w.add(_subTitle('Stage ${s.index + 1}: ${s.title}'));
            w.add(_bullets(s.inspectionChecklist));
          }

          // Section 8
          w.add(pw.Anchor(name: 'failures', child: _sectionTitle('8. Common Failures')));
          w.add(_bullets([
            'Poor compaction and weak bearing soil causing settlement and cracking.',
            'Weak mortar/grout or missing curing leading to reduced strength.',
            'Missing reinforcement/bands/bracing causing brittle failure under lateral loads.',
            'Improper anchorage/tie-down causing roof uplift or wall separation.',
            'Poor drainage and missing DPC causing moisture ingress and durability loss.',
          ]));

          // Section 9
          w.add(pw.Anchor(name: 'maintenance', child: _sectionTitle('9. Maintenance')));
          w.add(_bullets([
            'Annual inspection: roof fasteners, moisture ingress points, cracks, settlement signs.',
            'After hazard events: check connections, bracing, bands, and foundation distress.',
            'Repair promptly: seal leaks, repoint, replace corroded fasteners, re-treat bamboo/timber.',
          ]));

          // Section 10
          w.add(pw.Anchor(name: 'bimref', child: _sectionTitle('10. BIM Construction Reference')));
          w.add(_para('This reference is derived from the same stage definitions used by the Digital Twin. '
              'Use the app’s Structural/Exploded/Section/Load Path/Connection views to validate field execution.'));
          w.add(_schematicViews(input.modelId));

          return w;
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _pdfHeader({
    required pw.ImageProvider govtImg,
    required pw.ImageProvider ndmaImg,
    required String title,
    required String subtitle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 28,
            height: 28,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Image(govtImg, fit: pw.BoxFit.contain),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            width: 28,
            height: 28,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Image(ndmaImg, fit: pw.BoxFit.contain),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tocBlock(List<(String, String)> entries) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Table of contents', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        ...entries.map(
          (e) => pw.UrlLink(
            destination: '#${e.$1}',
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(e.$2, style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue700)),
            ),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _sectionTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10, bottom: 6),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _subTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _para(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10, height: 1.35)),
      );

  static pw.Widget _bullets(List<String> items) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items
            .map((t) => pw.Bullet(text: t, style: const pw.TextStyle(fontSize: 10, height: 1.3)))
            .toList(),
      );

  static pw.Widget _materialCard(MaterialSpec m) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(m.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Text('Specification: ${m.specification}', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Purpose: ${m.engineeringPurpose}', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 6),
          pw.Text('Quality requirements', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ...m.qualityPoints.map((q) => pw.Bullet(text: q, style: const pw.TextStyle(fontSize: 9))).toList(),
        ],
      ),
    );
  }

  static pw.Widget _stageBlock(StageDoc s) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Stage ${s.index + 1} — ${s.title}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Purpose', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.Text(s.purpose, style: const pw.TextStyle(fontSize: 9, height: 1.3)),
          pw.SizedBox(height: 6),
          pw.Text('Materials', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ...s.materials.map((m) => pw.Bullet(text: m, style: const pw.TextStyle(fontSize: 9))).toList(),
          pw.SizedBox(height: 6),
          pw.Text('Procedure', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ...s.procedure.map((p) => pw.Bullet(text: p, style: const pw.TextStyle(fontSize: 9))).toList(),
          pw.SizedBox(height: 6),
          pw.Text('Inspection checklist', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ...s.inspectionChecklist.map((c) => pw.Bullet(text: c, style: const pw.TextStyle(fontSize: 9))).toList(),
          pw.SizedBox(height: 6),
          pw.Text('Common mistakes', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ...s.commonMistakes.map((c) => pw.Bullet(text: c, style: const pw.TextStyle(fontSize: 9))).toList(),
          pw.SizedBox(height: 6),
          pw.Text('Quality control checks', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ...s.qualityChecks.map((c) => pw.Bullet(text: c, style: const pw.TextStyle(fontSize: 9))).toList(),
          pw.SizedBox(height: 6),
          pw.Text('Safety requirements', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ...s.safety.map((c) => pw.Bullet(text: c, style: const pw.TextStyle(fontSize: 9))).toList(),
        ],
      ),
    );
  }

  static pw.Widget _schematicViews(String modelId) {
    // Engineering schematic (not placeholder): deterministic stack based on the same tier logic
    // used by exploded view. This provides a printable “reference diagram” consistent with the twin.
    pw.Widget stack(String title) {
      pw.Widget layer(PdfColor color, String label, double h) => pw.Container(
            height: h,
            width: double.infinity,
            color: color,
            alignment: pw.Alignment.center,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
          );

      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 6, bottom: 10),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            layer(PdfColors.blueGrey800, 'Roof cover (Tier 4 / +2.0m)', 18),
            pw.SizedBox(height: 4),
            layer(PdfColors.blueGrey700, 'Roof structure (Tier 3 / +1.5m)', 18),
            pw.SizedBox(height: 4),
            layer(PdfColors.brown700, 'Walls + openings + bands (Tier 2 / +1.0m)', 26),
            pw.SizedBox(height: 4),
            layer(PdfColors.grey700, 'Plinth / base structure (Tier 1 / +0.5m)', 18),
            pw.SizedBox(height: 4),
            layer(PdfColors.grey800, 'Foundation (Tier 0 / fixed)', 18),
            pw.SizedBox(height: 6),
            pw.Text(
              'Model: $modelId — schematic derived from exploded tier rules used in the Digital Twin.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        stack('Exploded view reference (vertical tiers)'),
        stack('Structural view reference (load-resisting system)'),
        stack('Completed structure reference (assembled)'),
      ],
    );
  }
}

