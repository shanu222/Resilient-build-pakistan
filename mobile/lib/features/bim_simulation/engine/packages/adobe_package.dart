import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/adobe_dimensions.dart';
import '../geometry/adobe_scene_builder.dart';

class AdobePackage extends BimScenePackage {
  @override
  String get modelId => 'reinforced_adobe_brick_structure';

  @override
  String get displayName => 'Reinforced Adobe Brick Structure';

  @override
  String get definitionAssetPath => 'assets/data/bim_reinforced_adobe.json';

  @override
  double get crossSectionCenterX => AdobeDimensions.centerX;

  @override
  List<BimEntity> buildScene() => AdobeSceneBuilder().build();

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
        if (e.id.startsWith('soil')) return p;
        return 1;
      case 2:
        if (e.id.contains('adobe') ||
            e.id.contains('curing') ||
            e.id.contains('stabilizer') ||
            e.id.contains('mold') ||
            e.id == 'traditional_adobe_sample') {
          return (p * 1.05 - _idx(e.id) * 0.06).clamp(0, 1);
        }
        return 1;
      case 3:
        if (e.id.startsWith('setout') || e.id == 'wall_centerline') return p;
        return 1;
      case 4:
        if (e.id == 'excavation') return p;
        if (e.id == 'bearing_soil' || e.id == 'soil_profile') {
          return ((p - 0.2) * 1.4).clamp(0, 1);
        }
        return p > 0.1 ? 1 : 0;
      case 5:
        if (e.id == 'pcc_layer') return (p * 1.2).clamp(0, 1);
        if (e.id.startsWith('footing')) {
          return ((p - 0.15) * 1.3 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        if (e.id.startsWith('found_brick')) {
          return ((p - 0.35) * 1.5 - _idx(e.id) * 0.01).clamp(0, 1);
        }
        return 1;
      case 6:
        if (e.id == 'plinth_rebar') return (p * 1.35).clamp(0, 1);
        if (e.id == 'plinth_band') return ((p - 0.3) * 1.7).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('adobe_brick')) {
          return (p * 1.06 - _idx(e.id) * 0.008).clamp(0, 1);
        }
        if (e.id == 'traditional_adobe_ghost') return p < 0.5 ? 0.55 : 0.5;
        return 1;
      case 8:
        if (e.id.startsWith('vertical_bar')) {
          return (p * 1.1 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        return 1;
      case 9:
        if (e.id.contains('wire_mesh') || e.id.startsWith('mesh_corner')) {
          return (p * 1.08 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 10:
        if (e.id.contains('frame') ||
            e.id == 'opening_reinf' ||
            e.id == 'stress_flow') {
          return p;
        }
        return 1;
      case 11:
        if (e.id == 'lintel_rebar') return (p * 1.4).clamp(0, 1);
        if (e.id == 'lintel_band') return ((p - 0.3) * 1.65).clamp(0, 1);
        return 1;
      case 12:
        if (e.id == 'roof_band_rebar') return (p * 1.35).clamp(0, 1);
        if (e.id == 'roof_band' || e.id == 'box_action_note') {
          return ((p - 0.28) * 1.7).clamp(0, 1);
        }
        return 1;
      case 13:
        if (e.id.contains('truss') || e.id == 'ridge_beam') return p;
        if (e.id.startsWith('cgi_sheet')) {
          return ((p - 0.15) * 1.4 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id == 'heavy_roof_ghost') return p < 0.55 ? 0.5 : 0.28;
        return 1;
      case 14:
        if (e.id == 'protective_plaster' ||
            e.id == 'waterproof_coating' ||
            e.id == 'dpc_course') {
          return p;
        }
        return 1;
      case 15:
        if (e.id.startsWith('landscape') || e.id == 'reinforced_label') {
          return p;
        }
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
