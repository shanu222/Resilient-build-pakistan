import '../../../data/models/house_model.dart';
import '../../../data/models/resilience_dimensions.dart';

/// Unified resilient housing model — metadata + BIM + content paths.
class ResilientModel {
  const ResilientModel({
    required this.house,
    required this.hasBimSimulation,
    this.bimDefinitionAsset,
    this.engineeringNotes,
    this.constructionStageCount,
  });

  final HouseModel house;
  final bool hasBimSimulation;
  final String? bimDefinitionAsset;
  final Map<String, dynamic>? engineeringNotes;
  final int? constructionStageCount;

  String get id => house.id;
  String get name => house.name;
  int get resilienceScore => house.resilienceScore;

  bool get hasPdf => house.pdfAsset.isNotEmpty;
  bool get hasGlb => house.model3dPath.isNotEmpty;
}

/// Scored recommendation for location-based model selection.
class ModelRecommendationResult {
  const ModelRecommendationResult({
    required this.model,
    required this.score,
    required this.rank,
  });

  final ResilientModel model;
  final double score;
  final int rank;
}
