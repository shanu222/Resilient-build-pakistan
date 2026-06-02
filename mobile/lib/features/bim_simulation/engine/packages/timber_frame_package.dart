import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/timber_frame_dimensions.dart';
import '../geometry/timber_frame_scene_builder.dart';

class TimberFramePackage extends BimScenePackage {
  @override
  String get modelId => 'timber_frame_lath_plaster';

  @override
  String get displayName => 'Timber Frame with Lath and Plaster';

  @override
  String get definitionAssetPath => 'assets/data/bim_timber_frame.json';

  @override
  double get crossSectionCenterX => TimberFrameDimensions.centerX;

  @override
  List<BimEntity> buildScene() => TimberFrameSceneBuilder().build();

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
        if (e.id.startsWith('survey') ||
            e.id.startsWith('col_marker') ||
            e.id == 'wall_centerline') {
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
        if (e.id.startsWith('stone_found')) {
          return ((p - 0.1) * 1.2 - _idx(e.id) * 0.015).clamp(0, 1);
        }
        if (e.id == 'plinth_beam') return ((p - 0.45) * 1.9).clamp(0, 1);
        return 1;
      case 4:
        if (e.id == 'raw_timber') return p < 0.5 ? 0.7 : 0.4;
        if (e.id == 'treated_timber' || e.id == 'termite_coating') return p;
        return 1;
      case 5:
        if (e.id.startsWith('timber_column')) {
          return (p * 1.1 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        return 1;
      case 6:
        if (e.id.startsWith('beam_')) return (p * 1.08 - _beamDelay(e.id)).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('brace')) return p;
        if (e.id == 'unbraced_frame_ghost') return p < 0.55 ? 0.45 : 0.25;
        return 1;
      case 8:
        if (e.id.startsWith('wall_stud') || e.id == 'wall_top_plate') {
          return (p * 1.05 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 9:
        if (e.id.startsWith('timber_lath')) {
          return (p * 1.06 - _idx(e.id) * 0.04).clamp(0, 1);
        }
        return 1;
      case 10:
        if (e.id.startsWith('wire_mesh')) {
          return (p * 1.1 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        return 1;
      case 11:
        if (e.id.startsWith('plaster')) return p;
        return 1;
      case 12:
        if (e.id.contains('truss') || e.id == 'ridge_beam') return p;
        if (e.id.startsWith('rafter') || e.id.startsWith('purlin')) {
          return ((p - 0.15) * 1.3 - _idx(e.id) * 0.06).clamp(0, 1);
        }
        if (e.id == 'heavy_masonry_roof_ghost') return p < 0.5 ? 0.35 : 0.2;
        return 1;
      case 13:
        if (e.id.startsWith('cgi_sheet')) {
          return ((p - 0.1) * 1.4 - _idx(e.id) * 0.1).clamp(0, 1);
        }
        if (e.id.startsWith('roof_fastener')) return ((p - 0.3) * 1.6).clamp(0, 1);
        return 1;
      case 14:
        if (e.id.contains('frame')) return p;
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

  double _beamDelay(String id) {
    if (id.contains('front')) return 0;
    if (id.contains('rear')) return 0.15;
    if (id.contains('left')) return 0.3;
    return 0.45;
  }
}
