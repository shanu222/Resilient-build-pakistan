import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/loh_kaat_dimensions.dart';
import '../geometry/loh_kaat_scene_builder.dart';

class LohKaatPackage extends BimScenePackage {
  @override
  String get modelId => 'loh_kaat_timber_house';

  @override
  String get displayName => 'Loh-Kaat Timber House';

  @override
  String get definitionAssetPath => 'assets/data/bim_loh_kaat.json';

  @override
  double get crossSectionCenterX => LohKaatDimensions.centerX;

  @override
  List<BimEntity> buildScene() => LohKaatSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        if (e.id == 'mountain_terrain') return 1;
        return p;
      case 1:
        if (e.id.startsWith('grid') ||
            e.id.startsWith('corner') ||
            e.id == 'wall_centerline') {
          return p;
        }
        return 1;
      case 2:
        if (e.id == 'excavation') return p;
        if (e.id == 'bearing_soil') return ((p - 0.25) * 1.5).clamp(0, 1);
        return p > 0.15 ? 1 : 0;
      case 3:
        if (e.id == 'pcc_layer') return ((p - 0.1) * 1.5).clamp(0, 1);
        if (e.id.startsWith('stone_found')) {
          return (p * 1.1 - _idx(e.id) * 0.02).clamp(0, 1);
        }
        return 1;
      case 4:
        if (e.id == 'raw_timber') return (p * 1.5).clamp(0, 1);
        if (e.id == 'treated_timber' || e.id == 'moisture_coating') {
          return ((p - 0.35) * 1.6).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id.contains('plinth_band')) return p;
        return 1;
      case 6:
        if (e.id.startsWith('masonry') || e.id.startsWith('mud_mortar')) {
          return (p * 1.06 - _idx(e.id) * 0.005).clamp(0, 1);
        }
        return 1;
      case 7:
        if (e.id.contains('mid_band')) return p;
        return 1;
      case 8:
        if (e.id.contains('frame') ||
            e.id == 'opening_reinf' ||
            e.id == 'stress_marker') {
          return p;
        }
        return 1;
      case 9:
        if (e.id.contains('lintel_band')) return p;
        return 1;
      case 10:
        if (e.id.startsWith('timber_column') || e.id == 'timber_beam_tie') {
          return p;
        }
        return 1;
      case 11:
        if (e.id.startsWith('rafter') || e.id.startsWith('purlin')) return p;
        if (e.id == 'heavy_roof_ghost') return p < 0.6 ? 0.55 : 0.3;
        return 1;
      case 12:
        if (e.id.startsWith('roof_sheet')) {
          return (p * 1.15 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        return 1;
      case 13:
        if (e.id == 'wall_plaster' || e.id == 'floor_finish') return p;
        return 1;
      case 14:
        if (e.id.startsWith('mountain_tree')) return p;
        return 1;
      default:
        return p;
    }
  }

  int _idx(String id) {
    final parts = id.split('_');
    return int.tryParse(parts.last) ?? 0;
  }
}
