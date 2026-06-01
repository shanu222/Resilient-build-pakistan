import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/geogrid_dimensions.dart';
import '../geometry/geogrid_scene_builder.dart';

class GeogridPackage extends BimScenePackage {
  @override
  String get modelId => 'geogrid_reinforced_retaining_wall';

  @override
  String get displayName => 'Geogrid Reinforced Retaining Wall';

  @override
  String get definitionAssetPath => 'assets/data/bim_geogrid.json';

  @override
  double get crossSectionCenterX => GeogridDimensions.wallFaceX + 0.2;

  @override
  List<BimEntity> buildScene() => GeogridSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        if (e.id == 'mountain_slope') return 1;
        return p;
      case 1:
        if (e.id.startsWith('borehole') || e.id.startsWith('soil_layer')) {
          return (p * 1.2 - _idx(e.id) * 0.15).clamp(0, 1);
        }
        if (e.id == 'groundwater_table') return ((p - 0.4) * 1.8).clamp(0, 1);
        return p * 0.7;
      case 2:
        if (e.id == 'slope_cut' || e.id == 'foundation_trench') return p;
        if (e.id == 'bench_1') return ((p - 0.25) * 1.5).clamp(0, 1);
        return 1;
      case 3:
        if (e.id == 'leveling_pad') return (p * 1.4).clamp(0, 1);
        if (e.id == 'granular_foundation' || e.id == 'compaction_roller_0') {
          return ((p - 0.3) * 1.6).clamp(0, 1);
        }
        return 1;
      case 4:
        return e.id == 'facing_block_0' ? p : 1;
      case 5:
        if (e.id == 'geogrid_0' || e.id == 'grid_connection_0') return p;
        return 1;
      case 6:
        return e.id == 'backfill_0' ? p : 1;
      case 7:
        if (e.id.startsWith('compaction_roller')) return p;
        return 1;
      case 8:
        if (e.id.startsWith('facing_block') && e.id != 'facing_block_0') {
          return (p * 1.1 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        if (e.id.startsWith('geogrid') && e.id != 'geogrid_0') {
          return (p * 1.05 - _idx(e.id) * 0.08).clamp(0, 1);
        }
        if (e.id.startsWith('backfill') && e.id != 'backfill_0') {
          return (p * 1.08 - _idx(e.id) * 0.07).clamp(0, 1);
        }
        if (e.id == 'reinforced_zone_outline') return ((p - 0.5) * 2).clamp(0, 1);
        return 1;
      case 9:
        if (e.id == 'drainage_pipe' ||
            e.id == 'drainage_blanket' ||
            e.id == 'filter_layer') {
          return p;
        }
        return 1;
      case 10:
        if (e.id.startsWith('weep_hole')) {
          return (p * 1.2 - _idx(e.id) * 0.15).clamp(0, 1);
        }
        return 1;
      case 11:
        if (e.id == 'top_coping') return p;
        if (e.id.startsWith('facing_block')) return 1;
        return 1;
      case 12:
        if (e.id == 'surface_protection' || e.id.startsWith('vegetation')) {
          return p;
        }
        return 1;
      case 13:
        if (e.id == 'completed_road' || e.id.startsWith('landscape')) return p;
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
