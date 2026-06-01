import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/raised_plinth_dimensions.dart';
import '../geometry/raised_plinth_scene_builder.dart';

class RaisedPlinthPackage extends BimScenePackage {
  @override
  String get modelId => 'raised_plinth_flood_resilient_house';

  @override
  String get displayName => 'Raised Plinth Flood Resilient House';

  @override
  String get definitionAssetPath => 'assets/data/bim_raised_plinth.json';

  @override
  double get crossSectionCenterX => RaisedPlinthDimensions.centerX + 0.4;

  @override
  List<BimEntity> buildScene() => RaisedPlinthSceneBuilder().build();

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
        if (e.id == 'flood_water') return ((p - 0.45) * 1.8).clamp(0, 1);
        if (e.id == 'high_flood_mark' ||
            e.id == 'safe_level_mark' ||
            e.id == 'flood_zone_marker' ||
            e.id == 'footprint') {
          return p;
        }
        return p * 0.5;
      case 1:
        if (e.id.startsWith('grid') || e.id == 'plinth_boundary') return p;
        return 1;
      case 2:
        if (e.id == 'excavation') return p;
        if (e.id == 'bearing_soil' || e.id == 'soil_profile') {
          return ((p - 0.2) * 1.4).clamp(0, 1);
        }
        return p > 0.12 ? 1 : 0;
      case 3:
        if (e.id == 'pcc_layer') return (p * 1.2).clamp(0, 1);
        if (e.id.startsWith('footing_rebar')) {
          return (p * 1.15 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        if (e.id.startsWith('footing_concrete')) {
          return ((p - 0.25) * 1.5 - _idx(e.id) * 0.06).clamp(0, 1);
        }
        return 1;
      case 4:
        if (e.id.startsWith('found_wall')) {
          return (p * 1.1 - _courseIdx(e.id) * 0.15).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id.startsWith('earth_fill')) {
          return (p * 1.05 - _idx(e.id) * 0.18).clamp(0, 1);
        }
        if (e.id == 'compaction_roller') return ((p - 0.15) * 1.2).clamp(0, 1);
        return 1;
      case 6:
        if (e.id.startsWith('retaining_edge')) {
          return (p * 1.1 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        return 1;
      case 7:
        if (e.id.contains('plinth_beam_rebar')) return ((p - 0.05) * 1.3).clamp(0, 1);
        if (e.id == 'plinth_beam_formwork') return (p * 1.25).clamp(0, 1);
        if (e.id.startsWith('plinth_beam')) {
          return ((p - 0.35) * 1.7).clamp(0, 1);
        }
        return 1;
      case 8:
        if (e.id == 'dpc_layer' || e.id == 'waterproof_membrane') return p;
        return 1;
      case 9:
        if (e.id.startsWith('wall_')) {
          return (p * 1.08 - _courseIdx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 10:
        if (e.id.contains('door') || e.id.contains('window')) return p;
        return 1;
      case 11:
        if (e.id.contains('truss') || e.id == 'ridge_beam') return p;
        if (e.id.startsWith('cgi_sheet')) {
          return ((p - 0.2) * 1.4 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        return 1;
      case 12:
        if (e.id.contains('drain') || e.id == 'runoff_arrow_note') return p;
        return 1;
      case 13:
        if (e.id == 'ext_waterproofing' || e.id == 'plinth_toe_coating') {
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

  int _courseIdx(String id) {
    final parts = id.split('_');
    return int.tryParse(parts.last) ?? 0;
  }
}
