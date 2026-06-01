import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/amphibious_dimensions.dart';
import '../geometry/amphibious_scene_builder.dart';

class AmphibiousPackage extends BimScenePackage {
  @override
  String get modelId => 'floating_amphibious_structure';

  @override
  String get displayName => 'Floating Amphibious Structure';

  @override
  String get definitionAssetPath => 'assets/data/bim_amphibious.json';

  @override
  double get crossSectionCenterX => AmphibiousDimensions.centerX;

  @override
  List<BimEntity> buildScene() => AmphibiousSceneBuilder().build();

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
            e.id == 'flood_zone' ||
            e.id == 'high_flood_mark' ||
            e.id == 'anchorage_zone') {
          return p;
        }
        if (e.id == 'flood_water') return ((p - 0.45) * 2).clamp(0, 1);
        return p * 0.5;
      case 1:
        if (e.id.startsWith('grid') ||
            e.id.startsWith('pad_marker') ||
            e.id.startsWith('guide_marker') ||
            e.id == 'platform_boundary') {
          return p;
        }
        return 1;
      case 2:
        if (e.id.startsWith('pad_excavation')) return p;
        if (e.id.startsWith('pad_rebar')) {
          return (p * 1.2 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id.startsWith('foundation_pad')) {
          return ((p - 0.35) * 1.6 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 3:
        if (e.id.startsWith('guide_post')) {
          return (p * 1.15 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        return 1;
      case 4:
        if (e.id == 'platform_frame') return (p * 1.3).clamp(0, 1);
        if (e.id == 'floating_deck') return ((p - 0.35) * 1.7).clamp(0, 1);
        if (e.id == 'pontoon_alt') return p < 0.7 ? 0.5 : 0.35;
        return 1;
      case 5:
        if (e.id.startsWith('buoy_drum')) {
          return (p * 1.1 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id.startsWith('drum_strap')) return ((p - 0.3) * 1.5).clamp(0, 1);
        return 1;
      case 6:
        if (e.id.startsWith('frame_col') || e.id.startsWith('bamboo')) {
          return (p * 1.1 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id == 'steel_brace') return ((p - 0.4) * 1.8).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('deck_panel')) {
          return (p * 1.15 - _idx(e.id) * 0.15).clamp(0, 1);
        }
        if (e.id == 'moisture_floor') return ((p - 0.4) * 1.7).clamp(0, 1);
        return 1;
      case 8:
        if (e.id.startsWith('wall_panel')) {
          return (p * 1.08 - _idx(e.id) * 0.03).clamp(0, 1);
        }
        if (e.id == 'heavy_wall_ghost') return p < 0.55 ? 0.75 : 0.3;
        return 1;
      case 9:
        if (e.id.contains('frame')) return p;
        return 1;
      case 10:
        if (e.id.startsWith('roof_truss')) return p;
        return 1;
      case 11:
        if (e.id.startsWith('cgi')) return (p * 1.15 - _idx(e.id) * 0.12).clamp(0, 1);
        return 1;
      case 12:
        if (e.id.startsWith('flex_')) return (p * 1.2 - _idx(e.id) * 0.15).clamp(0, 1);
        return 1;
      case 13:
        if (e.id.startsWith('guide_collar')) return p;
        if (e.id == 'movement_range') return ((p - 0.3) * 1.5).clamp(0, 1);
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
