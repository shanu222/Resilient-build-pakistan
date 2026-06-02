import 'dart:io';

import '../lib/features/pdf/model_manual_generator.dart';

Future<void> main(List<String> args) async {
  // Run from mobile/ directory.
  final repoRoot = Directory.current.path;

  final models = [
    'interlocking_brick_masonry',
    'advanced_interlocking_brick_masonry',
    'bamboo_frame_wattle_daub',
    'cement_bamboo_frame',
    'confined_concrete_block_masonry',
    'earthbag_masonry',
    'elevated_flood_resilient_house',
    'floating_amphibious_structure',
    'fly_ash_masonry',
    'geogrid_reinforced_retaining_wall',
    'light_gauge_steel_house',
    'loh_kaat_timber_house',
    'pre_fabricated_house',
    'raised_plinth_flood_resilient_house',
    'rat_trap_bond_masonry',
    'reinforced_adobe_brick_structure',
    'timber_frame_lath_plaster',
  ];

  final govtLogo = await File('$repoRoot/assets/images/branding/govt_pakistan.png').readAsBytes();
  final ndmaLogo = await File('$repoRoot/assets/images/branding/ndma.png').readAsBytes();

  final outDir = Directory('$repoRoot/${ModelManualGenerator.manualDir}');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  var generated = 0;
  var failed = 0;
  for (final id in models) {
    final outPath = '$repoRoot/${ModelManualGenerator.manualAssetPathFor(id)}';
    final file = File(outPath);
    if (file.existsSync() && file.lengthSync() > 50 * 1024) {
      stdout.writeln('skip: $outPath (already exists)');
      continue;
    }
    stdout.writeln('gen:  $outPath');
    try {
      final input = await ModelManualGenerator.loadInputFromAssets(
        repoRoot: repoRoot,
        modelId: id,
      );
      final pdf = await ModelManualGenerator.generateModelManualPdf(
        input: input,
        govtLogoPng: govtLogo,
        ndmaLogoPng: ndmaLogo,
      );
      await file.writeAsBytes(pdf);
      generated++;
    } catch (e, st) {
      failed++;
      stderr.writeln('ERROR: failed generating "$id": $e');
      stderr.writeln(st);
      // Keep going to generate as many manuals as possible; fail at end so CI catches it.
    }
  }

  stdout.writeln('Done. Generated $generated manuals. Failed $failed.');
  if (failed > 0) {
    exitCode = 2;
  }
}

