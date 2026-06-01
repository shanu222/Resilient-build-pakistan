import 'package:flutter_test/flutter_test.dart';
import 'package:resilientbuild_pakistan/domain/services/hazard_recommendation_engine.dart';
import 'package:resilientbuild_pakistan/domain/services/location_intelligence_engine.dart';

void main() {
  test('analyzeLocation returns profile with region', () {
    final engine = HazardRecommendationEngine();
    final profile = engine.analyzeLocation(
      latitude: 31.52,
      longitude: 74.35,
      placeName: 'Lahore',
    );
    expect(profile.displayName, isNotEmpty);
    expect(profile.metrics, isNotEmpty);
  });

  test('location engine classifies punjab coordinates', () {
    final loc = LocationIntelligenceEngine();
    final profile = loc.analyze(latitude: 31.0, longitude: 72.5);
    expect(profile.regionId, isNotEmpty);
  });
}
