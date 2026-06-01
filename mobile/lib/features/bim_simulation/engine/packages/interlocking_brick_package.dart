import '../bim_entity.dart';
import '../bim_scene_package.dart';
import '../geometry/house_dimensions.dart';
import '../geometry/interlocking_brick_scene_builder.dart';

class InterlockingBrickPackage extends BimScenePackage {
  @override
  String get modelId => 'interlocking_brick_masonry';

  @override
  String get displayName => 'Interlocking Brick Masonry';

  @override
  String get definitionAssetPath => 'assets/data/bim_interlocking_brick.json';

  @override
  double get crossSectionCenterX => HouseDimensions.centerX;

  @override
  List<BimEntity> buildScene() => InterlockingBrickSceneBuilder().build();

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
        if (e.id.startsWith('trench') || e.id == 'excavator') return p;
        if (e.id == 'bearing_layer') return (p * 1.2).clamp(0, 1);
        return p > 0.3 ? 1 : 0;
      case 3:
        return e.id.startsWith('pcc') ? p : 1;
      case 4:
        if (e.id.contains('found') || e.id.contains('footing')) {
          return (p * 1.5 - (e.id.contains('course_1') ? 0.2 : 0)).clamp(0, 1);
        }
        return p;
      case 5:
        if (e.id == 'plinth_formwork') return (p * 3).clamp(0, 1);
        if (e.id.contains('plinth_rebar')) return ((p - 0.15) * 2).clamp(0, 1);
        if (e.id == 'plinth_concrete') return ((p - 0.5) * 2).clamp(0, 1);
        return p;
      case 6:
        if (e.category == BimEntityCategory.rebar && e.id.startsWith('vbar')) {
          return p;
        }
        return 1;
      case 7:
        if (e.id.startsWith('blk_')) {
          final idx = int.tryParse(e.id.split('_').last) ?? 0;
          return (p * 1.15 - idx / 600).clamp(0, 1);
        }
        return 1;
      case 8:
        return e.id == 'lintel_band' ? p : 1;
      case 9:
        return e.id == 'roof_band' ? p : 1;
      case 10:
        if (e.id == 'roof_shuttering') return (p * 2).clamp(0, 1);
        if (e.id.contains('slab_rebar')) return ((p - 0.2) * 1.5).clamp(0, 1);
        if (e.id == 'roof_concrete') return ((p - 0.55) * 2.2).clamp(0, 1);
        return p;
      case 11:
        return e.category == BimEntityCategory.finishing || e.id == 'landscape'
            ? p
            : 1;
      default:
        return p;
    }
  }
}
