import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/light_gauge_dimensions.dart';
import '../geometry/light_gauge_scene_builder.dart';

class LightGaugePackage extends BimScenePackage {
  @override
  String get modelId => 'light_gauge_steel_house';

  @override
  String get displayName => 'Light Gauge Steel House';

  @override
  String get definitionAssetPath => 'assets/data/bim_light_gauge_steel.json';

  @override
  double get crossSectionCenterX => LightGaugeDimensions.centerX;

  @override
  List<BimEntity> buildScene() => LightGaugeSceneBuilder().build();

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
        if (e.id.startsWith('setout')) return p;
        return 1;
      case 2:
        if (e.id == 'excavation') return p;
        if (e.id == 'bearing_soil') return ((p - 0.25) * 1.5).clamp(0, 1);
        return p > 0.15 ? 1 : 0;
      case 3:
        if (e.id == 'pcc_layer') return (p * 1.3).clamp(0, 1);
        if (e.id.startsWith('footing')) return ((p - 0.2) * 1.5).clamp(0, 1);
        return 1;
      case 4:
        if (e.id.startsWith('anchor_bolt')) {
          return (p * 1.15 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id.startsWith('base_track') || e.id == 'galvanization_note') {
          return p;
        }
        return 1;
      case 6:
        if (e.id.startsWith('stud') || e.id.startsWith('steel_column')) {
          return (p * 1.08 - _idx(e.id) * 0.04).clamp(0, 1);
        }
        if (e.id == 'top_track') return ((p - 0.4) * 1.8).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('beam') || e.id.startsWith('screw') || e.id.startsWith('gusset')) {
          return p;
        }
        return 1;
      case 8:
        if (e.id.startsWith('brace')) return p;
        if (e.id == 'unbraced_ghost') return p < 0.55 ? 0.75 : 0.3;
        return 1;
      case 9:
        if (e.id.startsWith('truss')) return p;
        return 1;
      case 10:
        if (e.id.startsWith('purlin') || e.id.startsWith('roof_sheet')) {
          return (p * 1.1 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id == 'heavy_roof_ghost') return p < 0.6 ? 0.6 : 0.35;
        return 1;
      case 11:
        if (e.id.startsWith('ext_sheath')) return (p * 1.15 - _idx(e.id) * 0.2).clamp(0, 1);
        return 1;
      case 12:
        return e.id == 'insulation_fill' ? p : 1;
      case 13:
        if (e.id.startsWith('int_sheath') ||
            e.id.contains('door') ||
            e.id.contains('window') ||
            e.id == 'moisture_barrier') {
          return p;
        }
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
