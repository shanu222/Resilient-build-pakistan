import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/earthbag_dimensions.dart';
import '../geometry/earthbag_scene_builder.dart';

class EarthbagPackage extends BimScenePackage {
  @override
  String get modelId => 'earthbag_masonry';

  @override
  String get displayName => 'Earthbag Masonry Structure';

  @override
  String get definitionAssetPath => 'assets/data/bim_earthbag.json';

  @override
  double get crossSectionCenterX => EarthbagDimensions.centerX;

  @override
  List<BimEntity> buildScene() => EarthbagSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0: // Site analysis
        if (e.id == 'mountain_terrain') return 1;
        if (e.id == 'building_platform' || e.id == 'footprint') return p;
        if (e.id == 'slope_indicator') return (p - 0.4).clamp(0, 1);
        return p * 0.8;
      case 1: // Setting out
        if (e.id.startsWith('grid') || e.id.startsWith('stake')) return p;
        if (e.id.startsWith('opening_marker')) return ((p - 0.5) * 2).clamp(0, 1);
        return 1;
      case 2: // Excavation
        if (e.id == 'excavation_trench') return p;
        if (e.id == 'bearing_soil') return ((p - 0.3) * 1.5).clamp(0, 1);
        return p > 0.2 ? 1 : 0;
      case 3: // Rubble trench
        if (e.id.startsWith('rubble')) return (p * 1.3 - _idx(e.id) * 0.08).clamp(0, 1);
        if (e.id == 'gravel_base') return ((p - 0.35) * 1.8).clamp(0, 1);
        if (e.id == 'drainage_pipe') return ((p - 0.5) * 2).clamp(0, 1);
        return p;
      case 4: // First earthbag course
        if (e.id.startsWith('first_bag')) {
          return (p * 1.2 - _bagIdx(e.id) * 0.03).clamp(0, 1);
        }
        if (e.id == 'plinth_band') return ((p - 0.6) * 2.5).clamp(0, 1);
        return 1;
      case 5: // Barbed wire
        if (e.id.startsWith('barbed_wire_1')) return p;
        if (e.id.startsWith('first_bag')) return 1;
        return p > 0.5 ? 1 : 0;
      case 6: // Wall construction
        if (e.id.startsWith('wall_bag')) {
          return (p * 1.1 - _bagIdx(e.id) * 0.015).clamp(0, 1);
        }
        if (e.id.startsWith('barbed_wire')) {
          final c = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.15 - c * 0.08).clamp(0, 1);
        }
        if (e.id == 'buttress') return ((p - 0.4) * 1.8).clamp(0, 1);
        return 1;
      case 7: // Vertical reinforcement
        if (e.id.startsWith('vbar')) return p;
        return 1;
      case 8: // Door/window frames
        if (e.id.contains('frame')) return p;
        return 1;
      case 9: // Lintel band
        if (e.id == 'lintel_rebar') return (p * 2).clamp(0, 1);
        if (e.id == 'lintel_band') return ((p - 0.35) * 1.8).clamp(0, 1);
        return 1;
      case 10: // Roof anchorage
        if (e.id.startsWith('anchor')) return (p * 1.5 - _idx(e.id) * 0.1).clamp(0, 1);
        return 1;
      case 11: // Roof construction
        if (e.id.startsWith('truss')) return (p * 1.4 - _idx(e.id) * 0.2).clamp(0, 1);
        if (e.id == 'roof_sheeting') return ((p - 0.45) * 2).clamp(0, 1);
        return 1;
      case 12: // Plaster
        if (e.id == 'wire_mesh') return (p * 1.5).clamp(0, 1);
        if (e.id == 'exterior_plaster') return ((p - 0.25) * 1.5).clamp(0, 1);
        return 1;
      case 13: // Drainage apron
        return e.id == 'drainage_apron' ? p : 1;
      case 14: // Complete
        if (e.id.startsWith('tree')) return p;
        return 1;
      default:
        return p;
    }
  }

  int _idx(String id) {
    final parts = id.split('_');
    return int.tryParse(parts.last) ?? 0;
  }

  int _bagIdx(String id) {
    final parts = id.split('_');
    if (parts.length >= 4) return int.tryParse(parts[3]) ?? 0;
    return 0;
  }
}
