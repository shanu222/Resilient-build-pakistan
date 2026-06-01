import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/advanced_interlocking_dimensions.dart';
import '../geometry/advanced_interlocking_scene_builder.dart';

class AdvancedInterlockingPackage extends BimScenePackage {
  @override
  String get modelId => 'advanced_interlocking_brick_masonry';

  @override
  String get displayName => 'Advanced Interlocking Brick Masonry';

  @override
  String get definitionAssetPath =>
      'assets/data/bim_advanced_interlocking.json';

  @override
  double get crossSectionCenterX => AdvancedInterlockingDimensions.centerX;

  @override
  List<BimEntity> buildScene() => AdvancedInterlockingSceneBuilder().build();

  @override
  double entityProgress(BimEntity e, int si, double p) {
    if (e.minStage > si) return 0;
    if (e.minStage < si) return 1;
    return _progress(e, si, p);
  }

  double _progress(BimEntity e, int stage, double p) {
    switch (stage) {
      case 0:
        return p;
      case 1:
        if (e.id.startsWith('grid') || e.id.startsWith('stake')) return p;
        return 1;
      case 2:
        if (e.id.startsWith('trench') ||
            e.id == 'excavator' ||
            e.id == 'soil_profile') {
          return p;
        }
        if (e.id == 'bearing_layer') return (p * 1.2).clamp(0, 1);
        return p > 0.25 ? 1 : 0;
      case 3:
        return e.id.startsWith('pcc') ? p : 1;
      case 4:
        if (e.id.contains('footing') || e.id.startsWith('found_masonry')) {
          if (e.id == 'footing_rebar_cage') return (p * 2).clamp(0, 1);
          if (e.id == 'footing_concrete') return ((p - 0.35) * 1.8).clamp(0, 1);
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return ((p - 0.2) * 1.5 - idx * 0.12).clamp(0, 1);
        }
        return p;
      case 5:
        if (e.id == 'plinth_formwork') return (p * 2.5).clamp(0, 1);
        if (e.id == 'plinth_rebar') return ((p - 0.2) * 2).clamp(0, 1);
        if (e.id == 'plinth_concrete' || e.id == 'dpc_layer') {
          return ((p - 0.45) * 2).clamp(0, 1);
        }
        return p;
      case 6:
        if (e.id.startsWith('blk_')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 99;
          return idx < 20 ? (p * 1.2).clamp(0, 1) : 0;
        }
        return e.id == 'block_lock_demo' ? p : 1;
      case 7:
        if (e.id.startsWith('vbar')) return p;
        return 1;
      case 8:
        if (e.id.startsWith('blk_')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.1 - idx / 500).clamp(0, 1);
        }
        return 1;
      case 9:
        if (e.id.startsWith('grout')) return p;
        return 1;
      case 10:
        return e.id.contains('frame') ? p : 1;
      case 11:
        if (e.id == 'lintel_rebar') return (p * 2).clamp(0, 1);
        return e.id == 'lintel_band' ? ((p - 0.35) * 1.6).clamp(0, 1) : p;
      case 12:
        return e.id == 'roof_band' ? p : 1;
      case 13:
        if (e.id == 'roof_shuttering') return (p * 2).clamp(0, 1);
        if (e.id.startsWith('slab_rebar')) return ((p - 0.25) * 1.6).clamp(0, 1);
        if (e.id == 'roof_concrete') return ((p - 0.55) * 2.2).clamp(0, 1);
        return p;
      case 14:
        return e.id == 'waterproofing' ||
                e.id.contains('frame') ||
                e.category == BimEntityCategory.finishing
            ? p
            : 1;
      case 15:
        return e.id == 'landscape' ||
                e.id == 'conventional_masonry_ghost'
            ? p
            : 1;
      default:
        return p;
    }
  }
}
