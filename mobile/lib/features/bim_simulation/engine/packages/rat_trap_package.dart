import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/rat_trap_dimensions.dart';
import '../geometry/rat_trap_scene_builder.dart';

class RatTrapPackage extends BimScenePackage {
  @override
  String get modelId => 'rat_trap_bond_masonry';

  @override
  String get displayName => 'Rat Trap Bond Masonry Structure';

  @override
  String get definitionAssetPath => 'assets/data/bim_rat_trap_bond.json';

  @override
  double get crossSectionCenterX => RatTrapDimensions.centerX;

  @override
  List<BimEntity> buildScene() => RatTrapSceneBuilder().build();

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
        if (e.id.startsWith('setout') ||
            e.id.startsWith('corner') ||
            e.id == 'wall_centerline') {
          return p;
        }
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
        if (e.id.startsWith('found_brick')) {
          return (p * 1.08 - _idx(e.id) * 0.012).clamp(0, 1);
        }
        return 1;
      case 5:
        if (e.id == 'plinth_rebar') return (p * 1.35).clamp(0, 1);
        if (e.id == 'plinth_band') return ((p - 0.3) * 1.7).clamp(0, 1);
        return 1;
      case 6:
        if (e.id.contains('rtb_') && e.minStage == 6) {
          return (p * 1.1 - _rtbBay(e.id) * 0.04).clamp(0, 1);
        }
        return 1;
      case 7:
        if (e.id.contains('rtb_')) {
          return (p * 1.05 - _rtbBay(e.id) * 0.02).clamp(0, 1);
        }
        if (e.id == 'conventional_wall_ghost') {
          return p < 0.55 ? 0.5 : 0.28;
        }
        return 1;
      case 8:
        if (e.id.startsWith('seismic_bar')) {
          return (p * 1.1 - _idx(e.id) * 0.12).clamp(0, 1);
        }
        if (e.id.startsWith('grout_fill')) return ((p - 0.25) * 1.4).clamp(0, 1);
        return 1;
      case 9:
        if (e.id.contains('frame') ||
            e.id == 'opening_reinf' ||
            e.id == 'stress_flow') {
          return p;
        }
        return 1;
      case 10:
        if (e.id == 'lintel_rebar') return (p * 1.4).clamp(0, 1);
        if (e.id == 'lintel_band') return ((p - 0.3) * 1.65).clamp(0, 1);
        return 1;
      case 11:
        if (e.id == 'roof_band_rebar') return (p * 1.35).clamp(0, 1);
        if (e.id == 'roof_band' || e.id == 'box_action_note') {
          return ((p - 0.28) * 1.7).clamp(0, 1);
        }
        return 1;
      case 12:
        if (e.id == 'slab_formwork') return (p * 1.3).clamp(0, 1);
        if (e.id.startsWith('slab_rebar')) return ((p - 0.12) * 1.45).clamp(0, 1);
        if (e.id == 'roof_slab') return ((p - 0.4) * 2).clamp(0, 1);
        if (e.id == 'load_path_arrow') return ((p - 0.5) * 2).clamp(0, 1);
        return 1;
      case 13:
        if (e.id == 'dpc_course' ||
            e.id == 'waterproof_membrane' ||
            e.id == 'capillary_block') {
          return p;
        }
        return 1;
      case 14:
        if (e.id.startsWith('landscape') || e.id == 'material_savings_note') {
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

  int _rtbBay(String id) {
    final parts = id.split('_');
    if (parts.length < 4) return 0;
    return int.tryParse(parts[parts.length - 2]) ?? 0;
  }
}
