import 'package:flutter_test/flutter_test.dart';
import 'package:resilientbuild_pakistan/data/models/hazard_profile.dart';
import 'package:resilientbuild_pakistan/data/models/house_model.dart';
import 'package:resilientbuild_pakistan/domain/services/model_recommendation_engine.dart';

void main() {
  final engine = ModelRecommendationEngine();

  final houses = [
    const HouseModel(
      id: 'elevated_flood_resilient_house',
      name: 'Elevated Flood',
      category: 'Flood',
      suitableRegions: ['sindh_riverine'],
      hazardsCovered: ['flood', 'earthquake'],
      resilienceScore: 90,
      costCategory: 'high',
      complexity: 'high',
      constructionDurationDays: 120,
      estimatedMaterialCostPkr: 3000000,
      estimatedLabourCostPkr: 900000,
      thumbnailGradient: ['#000', '#111'],
      model3dPath: 'assets/models/x/base.glb',
      pdfAsset: 'assets/pdfs/x.pdf',
      advantages: [],
      limitations: [],
      resilienceFeatures: [],
      engineeringSummary: '',
      materialIds: [],
    ),
    const HouseModel(
      id: 'earthbag_masonry',
      name: 'Earthbag',
      category: 'Masonry',
      suitableRegions: ['punjab_plains'],
      hazardsCovered: ['earthquake'],
      resilienceScore: 80,
      costCategory: 'low',
      complexity: 'moderate',
      constructionDurationDays: 60,
      estimatedMaterialCostPkr: 1000000,
      estimatedLabourCostPkr: 400000,
      thumbnailGradient: ['#000', '#111'],
      model3dPath: 'assets/models/x/base.glb',
      pdfAsset: 'assets/pdfs/x.pdf',
      advantages: [],
      limitations: [],
      resilienceFeatures: [],
      engineeringSummary: '',
      materialIds: [],
    ),
  ];

  test('prioritizes region-recommended flood model', () {
    final profile = HazardProfile(
      latitude: 24.8,
      longitude: 67.0,
      displayName: 'Test',
      regionId: 'sindh_riverine',
      regionName: 'Sindh Riverine',
      climate: 'Arid',
      metrics: const [
        HazardMetric(
          type: 'flood',
          name: 'Flood',
          level: 'High',
          score: 85,
          colorHex: '#EF4444',
        ),
      ],
      suitabilityScore: 70,
      suitabilitySummary: 'Test',
      riverProximityKm: 2,
      riverProximityNote: 'Near river',
      terrainSlopePercent: 1,
      historicalEvents: const [],
    );
    final result = engine.recommend(
      profile: profile,
      allModels: houses,
      regionRecommendations: {
        'sindh_riverine': ['elevated_flood_resilient_house'],
      },
    );
    expect(result.first.id, 'elevated_flood_resilient_house');
  });
}
