import 'package:equatable/equatable.dart';

class HazardMetric extends Equatable {
  const HazardMetric({
    required this.type,
    required this.name,
    required this.level,
    required this.score,
    required this.colorHex,
  });

  final String type;
  final String name;
  final String level;
  final int score;
  final String colorHex;

  @override
  List<Object?> get props => [type, score];
}

class HazardProfile extends Equatable {
  const HazardProfile({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    required this.regionId,
    required this.regionName,
    required this.climate,
    required this.metrics,
    required this.suitabilityScore,
    required this.suitabilitySummary,
    required this.riverProximityKm,
    required this.riverProximityNote,
    required this.terrainSlopePercent,
    required this.historicalEvents,
  });

  final double latitude;
  final double longitude;
  final String displayName;
  final String regionId;
  final String regionName;
  final String climate;
  final List<HazardMetric> metrics;
  final int suitabilityScore;
  final String suitabilitySummary;
  final double? riverProximityKm;
  final String riverProximityNote;
  final double terrainSlopePercent;
  final List<String> historicalEvents;

  @override
  List<Object?> get props => [latitude, longitude, regionId];
}
