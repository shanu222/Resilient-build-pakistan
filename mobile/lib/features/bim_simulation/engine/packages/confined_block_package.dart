import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/confined_block_dimensions.dart';
import '../geometry/confined_block_scene_builder.dart';

class ConfinedBlockPackage extends BimScenePackage {
  @override
  String get modelId => 'confined_concrete_block_masonry';

  @override
  String get displayName => 'Confined Concrete Block Masonry';

  @override
  String get definitionAssetPath => 'assets/data/bim_confined_block.json';

  @override
  double get crossSectionCenterX => ConfinedBlockDimensions.centerX;

  @override
  List<BimEntity> buildScene() => ConfinedBlockSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        return e.id == 'terrain' ? 1 : p;
      case 1:
        if (e.id.startsWith('grid') || e.id.startsWith('tie_col_marker')) {
          return p;
        }
        return 1;
      case 2:
        if (e.id == 'excavation') return p;
        if (e.id == 'bearing_soil') return ((p - 0.3) * 1.5).clamp(0, 1);
        return p > 0.2 ? 1 : 0;
      case 3:
        return e.id == 'pcc_layer' ? p : 1;
      case 4:
        if (e.id.startsWith('footing_rebar')) return (p * 1.3 - _idx(e.id) * 0.08).clamp(0, 1);
        if (e.id.startsWith('footing_concrete')) {
          return ((p - 0.35) * 1.6 - _idx(e.id) * 0.06).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id == 'plinth_formwork') return (p * 2).clamp(0, 1);
        if (e.id == 'plinth_rebar') return ((p - 0.2) * 1.5).clamp(0, 1);
        if (e.id == 'plinth_beam') return ((p - 0.45) * 2).clamp(0, 1);
        return 1;
      case 6:
        if (e.id.startsWith('tie_cage')) return (p * 1.1 - _idx(e.id) * 0.1).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('block_')) {
          return (p * 1.12 - _idx(e.id) * 0.008).clamp(0, 1);
        }
        return 1;
      case 8:
        if (e.id.startsWith('tie_concrete')) return ((p - 0.15) * 1.3).clamp(0, 1);
        if (e.id.startsWith('tie_formwork')) return (p * 1.5).clamp(0, 1);
        if (e.id == 'unconfined_ghost') return p < 0.5 ? 0.8 : 0.25;
        return 1;
      case 9:
        if (e.id.contains('frame') || e.id == 'opening_reinf') return p;
        return 1;
      case 10:
        if (e.id == 'lintel_rebar') return (p * 1.5).clamp(0, 1);
        if (e.id == 'lintel_band') return ((p - 0.3) * 1.6).clamp(0, 1);
        return 1;
      case 11:
        return e.id == 'tie_beam_ring' ? p : 1;
      case 12:
        return e.id == 'roof_band' ? p : 1;
      case 13:
        if (e.id == 'slab_formwork') return (p * 1.4).clamp(0, 1);
        if (e.id.startsWith('slab_rebar')) return ((p - 0.15) * 1.4).clamp(0, 1);
        if (e.id == 'roof_slab') return ((p - 0.5) * 2.2).clamp(0, 1);
        return 1;
      case 14:
        if (e.id == 'plaster' || e.id == 'floor_finish') return p;
        return 1;
      case 15:
        if (e.id.startsWith('landscape')) return p;
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
