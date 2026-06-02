import 'bim_scene_package.dart';
import 'packages/cement_bamboo_package.dart';
import 'packages/confined_block_package.dart';
import 'packages/earthbag_package.dart';
import 'packages/amphibious_package.dart';
import 'packages/fly_ash_package.dart';
import 'packages/geogrid_package.dart';
import 'packages/light_gauge_package.dart';
import 'packages/loh_kaat_package.dart';
import 'packages/prefab_package.dart';
import 'packages/raised_plinth_package.dart';
import 'packages/rat_trap_package.dart';
import 'packages/adobe_package.dart';
import 'packages/timber_frame_package.dart';
import 'packages/elevated_flood_package.dart';
import 'packages/interlocking_brick_package.dart';
import 'packages/advanced_interlocking_package.dart';

abstract final class BimSceneRegistry {
  static const bimModelIds = {
    'interlocking_brick_masonry',
    'earthbag_masonry',
    'cement_bamboo_frame',
    'confined_concrete_block_masonry',
    'elevated_flood_resilient_house',
    'floating_amphibious_structure',
    'fly_ash_masonry',
    'geogrid_reinforced_retaining_wall',
    'light_gauge_steel_house',
    'loh_kaat_timber_house',
    'pre_fabricated_house',
    'raised_plinth_flood_resilient_house',
    'rat_trap_bond_masonry',
    'reinforced_adobe_brick_structure',
    'timber_frame_lath_plaster',
    'advanced_interlocking_brick_masonry',
  };

  static bool hasBimSimulation(String modelId) => bimModelIds.contains(modelId);

  /// BIM stage JSON path for dynamic engine loading.
  static String? definitionAssetFor(String modelId) {
    if (!hasBimSimulation(modelId)) return null;
    return packageFor(modelId).definitionAssetPath;
  }

  static BimScenePackage packageFor(String modelId) {
    switch (modelId) {
      case 'earthbag_masonry':
        return EarthbagPackage();
      case 'cement_bamboo_frame':
        return CementBambooPackage();
      case 'confined_concrete_block_masonry':
        return ConfinedBlockPackage();
      case 'elevated_flood_resilient_house':
        return ElevatedFloodPackage();
      case 'floating_amphibious_structure':
        return AmphibiousPackage();
      case 'fly_ash_masonry':
        return FlyAshPackage();
      case 'geogrid_reinforced_retaining_wall':
        return GeogridPackage();
      case 'light_gauge_steel_house':
        return LightGaugePackage();
      case 'loh_kaat_timber_house':
        return LohKaatPackage();
      case 'pre_fabricated_house':
        return PrefabPackage();
      case 'raised_plinth_flood_resilient_house':
        return RaisedPlinthPackage();
      case 'rat_trap_bond_masonry':
        return RatTrapPackage();
      case 'reinforced_adobe_brick_structure':
        return AdobePackage();
      case 'timber_frame_lath_plaster':
        return TimberFramePackage();
      case 'advanced_interlocking_brick_masonry':
        return AdvancedInterlockingPackage();
      case 'interlocking_brick_masonry':
      default:
        return InterlockingBrickPackage();
    }
  }
}
