import 'package:equatable/equatable.dart';

class HouseModel extends Equatable {
  const HouseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.suitableRegions,
    required this.hazardsCovered,
    required this.resilienceScore,
    required this.costCategory,
    required this.complexity,
    required this.constructionDurationDays,
    required this.estimatedMaterialCostPkr,
    required this.estimatedLabourCostPkr,
    required this.thumbnailGradient,
    required this.model3dPath,
    required this.pdfAsset,
    required this.advantages,
    required this.limitations,
    required this.resilienceFeatures,
    required this.engineeringSummary,
    required this.materialIds,
  });

  factory HouseModel.fromJson(Map<String, dynamic> json) {
    return HouseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      suitableRegions: List<String>.from(json['suitableRegions'] as List),
      hazardsCovered: List<String>.from(json['hazardsCovered'] as List),
      resilienceScore: json['resilienceScore'] as int,
      costCategory: json['costCategory'] as String,
      complexity: json['complexity'] as String,
      constructionDurationDays: json['constructionDurationDays'] as int,
      estimatedMaterialCostPkr: json['estimatedMaterialCostPkr'] as int,
      estimatedLabourCostPkr: json['estimatedLabourCostPkr'] as int,
      thumbnailGradient: List<String>.from(json['thumbnailGradient'] as List),
      model3dPath: json['model3dPath'] as String,
      pdfAsset: json['pdfAsset'] as String,
      advantages: List<String>.from(json['advantages'] as List),
      limitations: List<String>.from(json['limitations'] as List),
      resilienceFeatures: List<String>.from(json['resilienceFeatures'] as List),
      engineeringSummary: json['engineeringSummary'] as String,
      materialIds: List<String>.from(json['materialIds'] as List),
    );
  }

  final String id;
  final String name;
  final String category;
  final List<String> suitableRegions;
  final List<String> hazardsCovered;
  final int resilienceScore;
  final String costCategory;
  final String complexity;
  final int constructionDurationDays;
  final int estimatedMaterialCostPkr;
  final int estimatedLabourCostPkr;
  final List<String> thumbnailGradient;
  final String model3dPath;
  final String pdfAsset;
  final List<String> advantages;
  final List<String> limitations;
  final List<String> resilienceFeatures;
  final String engineeringSummary;
  final List<String> materialIds;

  int get totalEstimatedCostPkr =>
      estimatedMaterialCostPkr + estimatedLabourCostPkr;

  @override
  List<Object?> get props => [id];
}
