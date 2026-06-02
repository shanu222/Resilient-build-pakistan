import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/advanced_interlocking_dimensions.dart';
import '../geometry/advanced_interlocking_scene_builder.dart';

class AdvancedInterlockingPackage extends BimScenePackage {
  @override
  String get modelId => 'advanced_interlocking_brick_masonry';

  @override
  String get displayName => 'Advanced Interlocking Brick Masonry';

  @override
  String get definitionAssetPath =>
      'assets/data/bim_advanced_interlocking.json';

  @override
  double get crossSectionCenterX => AdvancedInterlockingDimensions.centerX;

  @override
  List<BimEntity> buildScene() => AdvancedInterlockingSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        if (e.id.startsWith('grid') || e.id.startsWith('footprint')) return p;
        return 1;
      case 1:
        if (e.id.startsWith('trench') || e.id == 'pcc_strip' || e.id == 'bearing_layer') return p;
        return 1;
      case 2:
        return e.id.startsWith('found_rebar') || e.id.startsWith('cover_block') ? p : 1;
      case 3:
        return e.id.startsWith('footing_') ? p : 1;
      case 4:
        return e.id.startsWith('found_wall') ? p : 1;
      case 5:
        if (e.id == 'plinth_formwork') return (p * 2.2).clamp(0, 1);
        if (e.id.startsWith('plinth_rebar')) return ((p - 0.15) * 1.8).clamp(0, 1);
        if (e.id == 'plinth_concrete') return ((p - 0.45) * 2).clamp(0, 1);
        return p;
      case 6:
        return e.id == 'dpc_layer' ? p : 1;
      case 7:
        if (e.id.startsWith('blk_')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.08 - idx / 900).clamp(0, 1);
        }
        return 1;
      case 8:
        if (e.id.startsWith('vbar') || e.id.startsWith('core_void') || e.id.startsWith('grout')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.2 - idx * 0.1).clamp(0, 1);
        }
        return 1;
      case 9:
        if (e.id == 'lintel_formwork') return (p * 2).clamp(0, 1);
        if (e.id.startsWith('lintel_rebar')) return ((p - 0.2) * 1.6).clamp(0, 1);
        return e.id == 'lintel_band' ? ((p - 0.5) * 2).clamp(0, 1) : p;
      case 10:
        if (e.id.startsWith('roof_band_rebar')) return (p * 1.5).clamp(0, 1);
        return e.id == 'roof_band' ? ((p - 0.35) * 1.6).clamp(0, 1) : p;
      case 11:
        if (e.id.contains('truss') || e.id.contains('purlin') || e.id.contains('ridge') || e.id == 'wall_plate' || e.id == 'roof_bracing') {
          final idx = int.tryParse(e.id.split('_').last.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return (p * 1.25 - idx * 0.08).clamp(0, 1);
        }
        return p;
      case 12:
        if (e.id.startsWith('roof_sheet')) {
          final parts = e.id.split('_');
          final row = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;
          final col = int.tryParse(parts.length > 3 ? parts[3] : '0') ?? 0;
          return (p * 1.15 - (row * 4 + col) * 0.035).clamp(0, 1);
        }
        if (e.id.contains('frame')) return p;
        return 1;
      case 13:
        return e.id == 'load_path_marker' ? p : 1;
      case 14:
        return e.id == 'landscape' || e.id == 'conventional_masonry_ghost' ? p : 1;
      default:
        return p;
    }
  }
}
