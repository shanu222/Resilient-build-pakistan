import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/elevated_flood_dimensions.dart';
import '../geometry/elevated_flood_scene_builder.dart';

class ElevatedFloodPackage extends BimScenePackage {
  @override
  String get modelId => 'elevated_flood_resilient_house';

  @override
  String get displayName => 'Elevated Flood Resilient House';

  @override
  String get definitionAssetPath => 'assets/data/bim_elevated_flood.json';

  @override
  double get crossSectionCenterX =>
      ElevatedFloodDimensions.centerX + 1.2;

  @override
  List<BimEntity> buildScene() => ElevatedFloodSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        if (e.id == 'floodplain' || e.id == 'river_channel') return 1;
        if (e.id == 'footprint' ||
            e.id == 'flood_zone_marker' ||
            e.id == 'high_flood_mark' ||
            e.id == 'safe_level_mark') {
          return p;
        }
        if (e.id == 'flood_water') return ((p - 0.5) * 2).clamp(0, 1);
        return p * 0.6;
      case 1:
        if (e.id.startsWith('grid') ||
            e.id.startsWith('col_marker') ||
            e.id == 'platform_boundary') {
          return p;
        }
        return 1;
      case 2:
        if (e.id == 'excavation') return p;
        if (e.id == 'bearing_soil') return ((p - 0.25) * 1.5).clamp(0, 1);
        if (e.id == 'scour_zone') return ((p - 0.4) * 2).clamp(0, 1);
        return p > 0.15 ? 1 : 0;
      case 3:
        if (e.id.startsWith('footing_rebar')) {
          return (p * 1.2 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id.startsWith('footing_concrete') || e.id.startsWith('pedestal')) {
          return ((p - 0.3) * 1.5 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 4:
        if (e.id.startsWith('riprap')) {
          return (p * 1.15 - _idx(e.id) * 0.06).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id.startsWith('col_cage')) {
          return (p * 1.1 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        if (e.id.startsWith('col_formwork')) return (p * 1.3).clamp(0, 1);
        if (e.id.startsWith('col_concrete')) {
          return ((p - 0.35) * 1.6 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        return 1;
      case 6:
        if (e.id.startsWith('beam_rebar')) return ((p - 0.1) * 1.4).clamp(0, 1);
        if (e.id.startsWith('platform_beam')) return ((p - 0.4) * 1.8).clamp(0, 1);
        return 1;
      case 7:
        if (e.id == 'slab_formwork') return (p * 1.4).clamp(0, 1);
        if (e.id == 'slab_rebar_bottom') return ((p - 0.2) * 1.5).clamp(0, 1);
        if (e.id == 'elevated_slab') return ((p - 0.45) * 2).clamp(0, 1);
        if (e.id == 'flood_level_ref') return ((p - 0.5) * 2).clamp(0, 1);
        return 1;
      case 8:
        if (e.id.startsWith('wall_panel')) {
          return (p * 1.1 - _idx(e.id) * 0.04).clamp(0, 1);
        }
        if (e.id == 'heavy_wall_ghost') return p < 0.6 ? 0.7 : 0.3;
        return 1;
      case 9:
        if (e.id.contains('frame') || e.id == 'flood_elev_ref') return p;
        return 1;
      case 10:
        if (e.id.startsWith('truss') || e.id == 'ridge_beam') return p;
        return 1;
      case 11:
        if (e.id.startsWith('cgi_sheet')) {
          return (p * 1.2 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        if (e.id.startsWith('roof_fastener')) return ((p - 0.4) * 1.8).clamp(0, 1);
        return 1;
      case 12:
        if (e.id.startsWith('stair')) return (p * 1.1 - _idx(e.id) * 0.06).clamp(0, 1);
        return 1;
      case 13:
        if (e.id == 'moisture_barrier' || e.id == 'protective_coating') return p;
        return 1;
      case 14:
        if (e.id.startsWith('surface_drain') || e.id == 'drain_channel') {
          return p;
        }
        if (e.id == 'floor_finish' || e.id == 'exterior_paint') {
          return ((p - 0.3) * 1.5).clamp(0, 1);
        }
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
