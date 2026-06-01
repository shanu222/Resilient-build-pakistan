import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/fly_ash_dimensions.dart';
import '../geometry/fly_ash_scene_builder.dart';

class FlyAshPackage extends BimScenePackage {
  @override
  String get modelId => 'fly_ash_masonry';

  @override
  String get displayName => 'Fly Ash Masonry Structure';

  @override
  String get definitionAssetPath => 'assets/data/bim_fly_ash.json';

  @override
  double get crossSectionCenterX => FlyAshDimensions.centerX;

  @override
  List<BimEntity> buildScene() => FlyAshSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        if (e.id == 'terrain') return 1;
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
        return e.id == 'pcc_layer' ? p : 1;
      case 4:
        if (e.id.startsWith('footing_rebar')) {
          return (p * 1.2 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id.startsWith('footing_concrete')) {
          return ((p - 0.3) * 1.6 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id.startsWith('found_brick')) {
          return (p * 1.1 - _idx(e.id) * 0.015).clamp(0, 1);
        }
        return 1;
      case 6:
        if (e.id == 'plinth_rebar') return (p * 1.4).clamp(0, 1);
        if (e.id == 'plinth_band') return ((p - 0.35) * 1.8).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('fa_brick')) {
          return (p * 1.08 - _idx(e.id) * 0.006).clamp(0, 1);
        }
        if (e.id.startsWith('mortar_joint') || e.id.startsWith('junction')) {
          return ((p - 0.2) * 1.3).clamp(0, 1);
        }
        if (e.id == 'clay_brick_ghost') return p < 0.6 ? 0.65 : 0.3;
        return 1;
      case 8:
        if (e.id.contains('frame') ||
            e.id == 'opening_reinf' ||
            e.id == 'stress_flow') {
          return p;
        }
        return 1;
      case 9:
        if (e.id == 'lintel_rebar') return (p * 1.5).clamp(0, 1);
        if (e.id == 'lintel_band') return ((p - 0.3) * 1.6).clamp(0, 1);
        return 1;
      case 10:
        if (e.id == 'roof_band_rebar') return (p * 1.4).clamp(0, 1);
        if (e.id == 'roof_band') return ((p - 0.35) * 1.7).clamp(0, 1);
        return 1;
      case 11:
        if (e.id == 'slab_formwork') return (p * 1.4).clamp(0, 1);
        if (e.id.startsWith('slab_rebar')) return ((p - 0.15) * 1.4).clamp(0, 1);
        if (e.id == 'roof_slab') return ((p - 0.45) * 2.1).clamp(0, 1);
        return 1;
      case 12:
        if (e.id == 'dpc_course' ||
            e.id == 'waterproof_membrane' ||
            e.id == 'capillary_block') {
          return p;
        }
        return 1;
      case 13:
        if (e.id.startsWith('plaster')) return p;
        return 1;
      case 14:
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
