import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/cement_bamboo_dimensions.dart';
import '../geometry/cement_bamboo_scene_builder.dart';

class CementBambooPackage extends BimScenePackage {
  @override
  String get modelId => 'cement_bamboo_frame';

  @override
  String get displayName => 'Cement Bamboo Frame Structure';

  @override
  String get definitionAssetPath => 'assets/data/bim_cement_bamboo.json';

  @override
  double get crossSectionCenterX => CementBambooDimensions.centerX;

  @override
  List<BimEntity> buildScene() => CementBambooSceneBuilder().build();

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
        if (e.id.startsWith('grid') || e.id.startsWith('col_marker')) return p;
        return 1;
      case 2:
        if (e.id == 'excavation_trench') return p;
        if (e.id == 'bearing_soil') return ((p - 0.35) * 1.6).clamp(0, 1);
        return p > 0.2 ? 1 : 0;
      case 3:
        if (e.id == 'pcc_layer') return (p * 1.2).clamp(0, 1);
        if (e.id == 'strip_footing') return ((p - 0.25) * 1.5).clamp(0, 1);
        if (e.id == 'foundation_beam') return ((p - 0.5) * 2).clamp(0, 1);
        return 1;
      case 4:
        if (e.id == 'treatment_tank') return (p * 1.5).clamp(0, 1);
        if (e.id.startsWith('bamboo_raw')) {
          return p < 0.6 ? p * 1.2 : (1 - p) * 0.5;
        }
        return 1;
      case 5:
        if (e.id.startsWith('column_')) {
          return (p * 1.1 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        if (e.id.startsWith('col_base')) return p;
        return 1;
      case 6:
        if (e.id.startsWith('beam_')) return ((p - _idx(e.id) * 0.1) * 1.3).clamp(0, 1);
        return 1;
      case 7:
        if (e.id.startsWith('brace')) return p;
        if (e.id == 'frame_no_brace_ghost') return p < 0.5 ? 1 : 0.3;
        return 1;
      case 8:
        if (e.id.startsWith('wall_nog')) return (p * 1.2 - _idx(e.id) * 0.1).clamp(0, 1);
        return 1;
      case 9:
        return e.id == 'wire_mesh_walls' ? p : 1;
      case 10:
        return e.id == 'cement_plaster' ? p : 1;
      case 11:
        if (e.id.startsWith('truss') || e.id.startsWith('purlin')) {
          return (p * 1.15 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        return 1;
      case 12:
        if (e.id == 'cgi_roof') return p;
        if (e.id == 'heavy_roof_ghost') return ((p - 0.4) * 2).clamp(0, 1);
        return 1;
      case 13:
        if (e.id.startsWith('roof_anchor') || e.id == 'tie_down_strap') return p;
        return 1;
      case 14:
        if (['door', 'window', 'floor_finish'].contains(e.id)) return p;
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
