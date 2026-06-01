import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/prefab_dimensions.dart';
import '../geometry/prefab_scene_builder.dart';

class PrefabPackage extends BimScenePackage {
  @override
  String get modelId => 'pre_fabricated_house';

  @override
  String get displayName => 'Pre-Fabricated House Structure';

  @override
  String get definitionAssetPath => 'assets/data/bim_prefabricated.json';

  @override
  double get crossSectionCenterX => PrefabDimensions.centerX;

  @override
  List<BimEntity> buildScene() => PrefabSceneBuilder().build();

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
        if (e.id.startsWith('setout') || e.id.startsWith('panel_layout')) {
          return p;
        }
        return 1;
      case 2:
        if (e.id == 'excavation') return p;
        if (e.id == 'bearing_soil' || e.id == 'soil_profile') {
          return ((p - 0.2) * 1.4).clamp(0, 1);
        }
        return p > 0.1 ? 1 : 0;
      case 3:
        if (e.id == 'pcc_layer') return (p * 1.2).clamp(0, 1);
        if (e.id.startsWith('footing')) return ((p - 0.15) * 1.4).clamp(0, 1);
        if (e.id.startsWith('foundation_beam')) return ((p - 0.45) * 1.8).clamp(0, 1);
        return 1;
      case 4:
        if (e.id.startsWith('anchor_bolt')) {
          return (p * 1.1 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id == 'mobile_crane' || e.id == 'crane_boom') return p > 0.05 ? 1 : 0;
        if (e.id.startsWith('floor_panel')) {
          return (p * 1.05 - _idx(e.id) * 0.15).clamp(0, 1);
        }
        return 1;
      case 6:
        if (e.id == 'mobile_crane' || e.id == 'crane_boom') return 1;
        if (e.id.startsWith('wall_')) return (p * 1.08 - _wallIdx(e.id) * 0.12).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('steel_connector')) return p;
        return 1;
      case 8:
        if (e.id.contains('door') || e.id.contains('window')) return p;
        return 1;
      case 9:
        if (e.id.startsWith('roof_panel')) {
          return (p * 1.1 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        if (e.id == 'heavy_roof_ghost') return p < 0.65 ? 0.55 : 0.3;
        return 1;
      case 10:
        if (e.id.contains('insulation') || e.id == 'thermal_barrier') return p;
        return 1;
      case 11:
        if (e.id.startsWith('panel_lock')) return (p * 1.2 - _idx(e.id) * 0.1).clamp(0, 1);
        return 1;
      case 12:
        if (e.id == 'electrical_conduit' || e.id == 'water_line') return p;
        return 1;
      case 13:
        if (e.id.contains('finish')) return p;
        return 1;
      case 14:
        if (e.id.startsWith('landscape') || e.id == 'factory_module_note') {
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

  int _wallIdx(String id) {
    if (id.contains('front')) return 0;
    if (id.contains('rear')) return 1;
    if (id.contains('left')) return 2;
    if (id.contains('right')) return 3;
    return 0;
  }
}
