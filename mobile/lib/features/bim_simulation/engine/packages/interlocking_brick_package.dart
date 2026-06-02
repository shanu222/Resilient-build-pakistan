import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/house_dimensions.dart';
import '../geometry/interlocking_brick_scene_builder.dart';

class InterlockingBrickPackage extends BimScenePackage {
  @override
  String get modelId => 'interlocking_brick_masonry';

  @override
  String get displayName => 'Interlocking Brick Masonry';

  @override
  String get definitionAssetPath => 'assets/data/bim_interlocking_brick.json';

  @override
  double get crossSectionCenterX => HouseDimensions.centerX;

  @override
  List<BimEntity> buildScene() => InterlockingBrickSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        // Stage 1 (0): Site layout
        if (e.id.startsWith('grid') || e.id.startsWith('stake') || e.id.startsWith('footprint')) {
          return p;
        }
        return 1;
      case 1:
        // Stage 2 (1): Excavation
        if (e.id.startsWith('trench') || e.id == 'excavator') return p;
        if (e.id == 'bearing_layer') return (p * 1.2).clamp(0, 1);
        return p > 0.25 ? 1 : 0;
      case 2:
        // Stage 3 (2): Foundation (PCC + footings + foundation wall)
        if (e.id.startsWith('pcc')) return p;
        if (e.id.startsWith('footing')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.4 - idx * 0.12).clamp(0, 1);
        }
        if (e.id.startsWith('found_wall')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.3 - idx * 0.25).clamp(0, 1);
        }
        return p;
      case 3:
        // Stage 4 (3): Structural reinforcement (starter/vertical bars)
        if (e.category == BimEntityCategory.rebar && e.id.startsWith('vbar')) {
          final idx = int.tryParse(
                e.id.split('_').last.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          return (p * 1.2 - idx * 0.08).clamp(0, 1);
        }
        return 1;
      case 4:
        // Stage 5 (4): Columns / primary structure (not applicable → hold steady)
        return 1;
      case 5:
        // Stage 6 (5): Plinth beam / DPC
        if (e.id == 'plinth_formwork') return (p * 2.5).clamp(0, 1);
        if (e.id.contains('plinth_rebar')) return ((p - 0.12) * 1.8).clamp(0, 1);
        if (e.id == 'plinth_concrete') return ((p - 0.45) * 1.8).clamp(0, 1);
        if (e.id == 'dpc_layer') return ((p - 0.7) * 3.3).clamp(0, 1);
        return p;
      case 6:
        // Stage 7 (6): Walls
        if (e.id.startsWith('blk_')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.1 - idx / 800).clamp(0, 1);
        }
        return 1;
      case 7:
        // Stage 8 (7): Openings
        if (e.id.contains('door') || e.id.contains('window') || e.id.contains('frame')) return p;
        return 1;
      case 8:
        // Stage 9 (8): Lintel / ring beams (includes roof band for masonry)
        if (e.id == 'lintel_formwork') return (p * 2.2).clamp(0, 1);
        if (e.id.startsWith('lintel_rebar')) return ((p - 0.15) * 1.6).clamp(0, 1);
        if (e.id == 'lintel_concrete_pour') return ((p - 0.4) * 2).clamp(0, 1);
        if (e.id == 'lintel_band') return ((p - 0.65) * 2.8).clamp(0, 1);
        if (e.id.startsWith('roof_band_rebar')) return (p * 1.5).clamp(0, 1);
        if (e.id == 'roof_band_formwork') return ((p - 0.2) * 2).clamp(0, 1);
        if (e.id == 'roof_band_concrete') return ((p - 0.5) * 2).clamp(0, 1);
        return p;
      case 9:
        // Stage 10 (9): Roof structure
        if (e.id == 'wall_plate') return (p * 2).clamp(0, 1);
        if (e.id.contains('truss') || e.id == 'ridge_beam') {
          final idx = int.tryParse(e.id.split('_').last.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return (p * 1.3 - idx * 0.1).clamp(0, 1);
        }
        if (e.id.startsWith('purlin') || e.id == 'roof_bracing') {
          return ((p - 0.25) * 1.5).clamp(0, 1);
        }
        if (e.id.startsWith('truss_connector')) return ((p - 0.5) * 2).clamp(0, 1);
        return p;
      case 10:
        // Stage 11 (10): Roof cover
        if (e.id.startsWith('roof_sheet')) {
          final parts = e.id.split('_');
          final row = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;
          final col = int.tryParse(parts.length > 3 ? parts[3] : '0') ?? 0;
          return (p * 1.2 - (row * 3 + col) * 0.04).clamp(0, 1);
        }
        return 1;
      case 11:
        // Stage 12 (11): Finishes
        if (e.category == BimEntityCategory.finishing || e.id == 'landscape') return p;
        return 1;
      case 12:
        // Stage 13 (12): Completed
        return 1;
      default:
        return p;
    }
  }
}
