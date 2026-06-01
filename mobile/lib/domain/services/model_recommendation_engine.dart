import '../../data/models/hazard_profile.dart';
import '../../data/models/house_model.dart';

class ModelRecommendationEngine {
  List<HouseModel> recommend({
    required HazardProfile profile,
    required List<HouseModel> allModels,
    required Map<String, List<String>> regionRecommendations,
  }) {
    final regionIds = regionRecommendations[profile.regionId] ?? [];
    final scored = <HouseModel, double>{};

    for (final model in allModels) {
      var score = 0.0;
      if (regionIds.contains(model.id)) score += 50;
      if (model.suitableRegions.contains(profile.regionId)) score += 30;

      for (final metric in profile.metrics) {
        if (metric.type == 'flood' && metric.score >= 60) {
          if (model.hazardsCovered.any((h) => h.contains('flood'))) score += 15;
        }
        if (metric.type == 'earthquake' && metric.score >= 50) {
          if (model.hazardsCovered.any((h) => h.contains('earthquake'))) {
            score += 12;
          }
        }
        if (metric.type == 'landslide' && metric.score >= 50) {
          if (model.hazardsCovered.any((h) => h.contains('landslide'))) {
            score += 12;
          }
        }
        if (metric.type == 'glof' && metric.score >= 40) {
          if (model.hazardsCovered.any((h) => h.contains('glof'))) score += 10;
        }
      }

      score += model.resilienceScore * 0.1;
      scored[model] = score;
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommended = sorted.map((e) => e.key).toList();
    if (recommended.isEmpty) return allModels;
    return recommended;
  }
}
