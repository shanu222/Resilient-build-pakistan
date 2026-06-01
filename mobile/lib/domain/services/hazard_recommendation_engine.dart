import '../../data/models/hazard_profile.dart';
import '../../data/models/house_model.dart';
import '../../features/models/domain/resilient_model.dart';
import '../../features/models/resilient_model_registry.dart';
import '../../data/repositories/json_asset_repository.dart';
import 'location_intelligence_engine.dart';
import 'model_recommendation_engine.dart';

/// Location hazard analysis + resilient model ranking (national deployment API).
class HazardRecommendationEngine {
  HazardRecommendationEngine({
    LocationIntelligenceEngine? locationEngine,
    ModelRecommendationEngine? modelEngine,
  })  : _location = locationEngine ?? LocationIntelligenceEngine(),
        _models = modelEngine ?? ModelRecommendationEngine();

  final LocationIntelligenceEngine _location;
  final ModelRecommendationEngine _models;

  HazardProfile analyzeLocation({
    required double latitude,
    required double longitude,
    String? placeName,
  }) {
    return _location.analyze(
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
    );
  }

  List<HouseModel> recommendHouses({
    required HazardProfile profile,
    required List<HouseModel> allModels,
    required Map<String, List<String>> regionRecommendations,
  }) {
    return _models.recommend(
      profile: profile,
      allModels: allModels,
      regionRecommendations: regionRecommendations,
    );
  }

  /// Full pipeline: hazards → scored resilient models.
  Future<List<ModelRecommendationResult>> recommendResilientModels({
    required double latitude,
    required double longitude,
    required JsonAssetRepository repository,
    String? placeName,
  }) async {
    final profile = analyzeLocation(
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
    );
    final houses = await repository.getHouses();
    final regionRecs = await repository.getRegionRecommendations();
    final ranked = recommendHouses(
      profile: profile,
      allModels: houses,
      regionRecommendations: regionRecs,
    );
    final notes = await repository.getEngineeringNotes();

    final results = <ModelRecommendationResult>[];
    for (var i = 0; i < ranked.length; i++) {
      final house = ranked[i];
      final resilient = ResilientModelRegistry.fromHouse(house, notes);
      final score = _scoreForRank(i, ranked.length, resilient);
      results.add(
        ModelRecommendationResult(model: resilient, score: score, rank: i + 1),
      );
    }
    return results;
  }

  double _scoreForRank(int index, int total, ResilientModel model) {
    if (total <= 1) return 100;
    final base = 100 - (index / (total - 1)) * 40;
    return (base + model.resilienceScore * 0.05).clamp(0, 100);
  }
}
