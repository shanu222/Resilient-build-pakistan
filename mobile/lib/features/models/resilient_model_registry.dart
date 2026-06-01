import '../../data/models/house_model.dart';
import '../../data/repositories/json_asset_repository.dart';
import '../bim_simulation/engine/bim_scene_registry.dart';
import 'domain/resilient_model.dart';

/// Central registry for all resilient housing models (catalog + BIM linkage).
abstract final class ResilientModelRegistry {
  static const coreModelIds = [
    'interlocking_brick_masonry',
    'bamboo_frame_wattle_daub',
    'cement_bamboo_frame',
    'confined_concrete_block_masonry',
    'earthbag_masonry',
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
  ];

  /// All 16 curriculum models plus extended catalog entries (e.g. advanced interlocking).
  static Future<List<ResilientModel>> loadAll(JsonAssetRepository repo) async {
    final houses = await repo.getHouses();
    final notes = await repo.getEngineeringNotes();
    return houses.map((h) => fromHouse(h, notes)).toList();
  }

  static ResilientModel fromHouse(
    HouseModel house,
    Map<String, dynamic> engineeringNotes,
  ) {
    final hasBim = BimSceneRegistry.hasBimSimulation(house.id);
    return ResilientModel(
      house: house,
      hasBimSimulation: hasBim,
      bimDefinitionAsset: BimSceneRegistry.definitionAssetFor(house.id),
      engineeringNotes: engineeringNotes[house.id] as Map<String, dynamic>?,
      constructionStageCount:
          hasBim ? null : null, // Loaded at runtime from bim JSON when needed
    );
  }

  static Future<ResilientModel?> byId(
    JsonAssetRepository repo,
    String id,
  ) async {
    final house = await repo.getHouseById(id);
    if (house == null) return null;
    final notes = await repo.getEngineeringNotes();
    return fromHouse(house, notes);
  }

  static bool isCoreModel(String id) => coreModelIds.contains(id);
}
