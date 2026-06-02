import 'dart:math' as math;

import '../../data/models/hazard_profile.dart';

/// Analyzes coordinates and produces a hazard profile for Pakistan.
class LocationIntelligenceEngine {
  HazardProfile analyze({
    required double latitude,
    required double longitude,
    String? placeName,
    String? regionId,
    String? regionName,
    String? climate,
  }) {
    final resolved = regionId ?? _detectRegionId(latitude, longitude);
    final region = _regionProfiles[resolved] ?? _regionProfiles['punjab_plains']!;

    final flood = _floodScore(latitude, longitude, resolved);
    final earthquake = _earthquakeScore(latitude, longitude);
    final landslide = _landslideScore(latitude, longitude, resolved);
    final glof = _glofScore(latitude, longitude, resolved);
    final wind = _windScore(latitude, longitude, resolved);
    final riverKm = _riverProximityKm(latitude, longitude);
    final slope = _terrainSlopePercent(latitude, longitude, resolved);

    final metrics = [
      HazardMetric(
        type: 'flood',
        name: 'Flood Risk',
        level: _level(flood),
        score: flood,
        colorHex: '#2563EB',
      ),
      HazardMetric(
        type: 'earthquake',
        name: 'Earthquake Risk',
        level: _level(earthquake),
        score: earthquake,
        colorHex: '#F97316',
      ),
      HazardMetric(
        type: 'landslide',
        name: 'Landslide Risk',
        level: _level(landslide),
        score: landslide,
        colorHex: '#16A34A',
      ),
      HazardMetric(
        type: 'glof',
        name: 'GLOF Risk',
        level: _level(glof),
        score: glof,
        colorHex: '#0891B2',
      ),
      HazardMetric(
        type: 'wind',
        name: 'Wind Risk',
        level: _level(wind),
        score: wind,
        colorHex: '#9333EA',
      ),
    ];

    final suitability = (100 -
            (flood * 0.25 +
                earthquake * 0.2 +
                landslide * 0.2 +
                glof * 0.1 +
                wind * 0.15 +
                (riverKm < 3 ? 20 : 0)))
        .clamp(0, 100)
        .round();

    return HazardProfile(
      latitude: latitude,
      longitude: longitude,
      displayName: placeName ?? region['defaultCity'] as String,
      regionId: resolved,
      regionName: regionName ?? region['name'] as String,
      climate: climate ?? region['climate'] as String,
      metrics: metrics,
      suitabilityScore: suitability,
      suitabilitySummary: _suitabilitySummary(suitability, flood, resolved),
      riverProximityKm: riverKm,
      riverProximityNote: _riverNote(riverKm, resolved),
      terrainSlopePercent: slope,
      historicalEvents: List<String>.from(
        region['historicalEvents'] as List? ?? [],
      ),
    );
  }

  static String _detectRegionId(double lat, double lng) {
    for (final entry in _regionBounds.entries) {
      final b = entry.value;
      if (lat >= b['minLat']! &&
          lat <= b['maxLat']! &&
          lng >= b['minLng']! &&
          lng <= b['maxLng']!) {
        return entry.key;
      }
    }
    return 'punjab_plains';
  }

  static int _floodScore(double lat, double lng, String region) {
    const base = {
      'sindh_riverine': 85,
      'coastal_sindh': 70,
      'punjab_plains': 55,
      'gb_hilly': 25,
      'kpk_mountain': 45,
      'balochistan_arid': 30,
      'azad_kashmir': 50,
      'islamabad_foot_hills': 48,
    };
    var score = base[region] ?? 50;
    if (_riverProximityKm(lat, lng) < 2) score += 15;
    return score.clamp(0, 100);
  }

  static int _earthquakeScore(double lat, double lng) {
    // Higher in north (Himalayan belt)
    final northFactor = ((lat - 24) / 12 * 40).clamp(0, 40);
    final faultProximity = math.sin(lng * 0.1) * 10 + 35;
    return (northFactor + faultProximity).round().clamp(15, 95);
  }

  static int _landslideScore(double lat, double lng, String region) {
    const base = {
      'gb_hilly': 75,
      'kpk_mountain': 65,
      'azad_kashmir': 70,
      'islamabad_foot_hills': 45,
      'punjab_plains': 15,
      'sindh_riverine': 10,
    };
    return (base[region] ?? 30) + (_terrainSlopePercent(lat, lng, region) / 2).round();
  }

  static int _glofScore(double lat, double lng, String region) {
    if (region == 'gb_hilly' && lat > 35.5) return 45;
    if (region == 'azad_kashmir' && lat > 34) return 35;
    return region == 'gb_hilly' ? 25 : 10;
  }

  static int _windScore(double lat, double lng, String region) {
    if (region == 'coastal_sindh') return 75;
    if (region == 'balochistan_arid') return 55;
    return 40;
  }

  static double _riverProximityKm(double lat, double lng) {
    // Approximate distance to major rivers (Ravi, Indus, Swat)
    final rivers = [
      (31.52, 74.36), // Ravi near Lahore
      (25.4, 68.4), // Indus near Hyderabad
      (34.8, 72.4), // Swat
    ];
    var minKm = 999.0;
    for (final r in rivers) {
      final d = _haversineKm(lat, lng, r.$1, r.$2);
      if (d < minKm) minKm = d;
    }
    return minKm;
  }

  static double _terrainSlopePercent(double lat, double lng, String region) {
    const slopes = {
      'gb_hilly': 28.0,
      'kpk_mountain': 22.0,
      'azad_kashmir': 25.0,
      'punjab_plains': 2.0,
      'sindh_riverine': 1.0,
    };
    return slopes[region] ?? 5.0;
  }

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;

  static String _level(int score) {
    if (score >= 66) return 'High';
    if (score >= 36) return 'Medium';
    return 'Low';
  }

  static String _suitabilitySummary(int score, int flood, String region) {
    if (score >= 75) return 'Good suitability for resilient construction';
    if (flood >= 66) {
      return 'Moderate suitability with flood mitigation required';
    }
    if (region == 'gb_hilly') {
      return 'Mountain site — prioritize landslide and seismic detailing';
    }
    return 'Moderate suitability — follow regional model recommendations';
  }

  static String _riverNote(double km, String region) {
    if (km < 3) {
      return 'Located ${km.toStringAsFixed(1)} km from nearest major river. Monsoon flooding possible.';
    }
    return 'River systems ${km.toStringAsFixed(1)} km away. Local drainage still important.';
  }

  static const _regionBounds = {
    'gb_hilly': {'minLat': 34.5, 'maxLat': 37.5, 'minLng': 72.0, 'maxLng': 77.0},
    'sindh_riverine': {'minLat': 23.5, 'maxLat': 28.5, 'minLng': 66.5, 'maxLng': 71.0},
    'punjab_plains': {'minLat': 28.5, 'maxLat': 33.0, 'minLng': 70.0, 'maxLng': 75.5},
    'kpk_mountain': {'minLat': 33.0, 'maxLat': 36.5, 'minLng': 70.5, 'maxLng': 74.5},
    'balochistan_arid': {'minLat': 24.5, 'maxLat': 32.0, 'minLng': 60.5, 'maxLng': 70.5},
    'coastal_sindh': {'minLat': 23.0, 'maxLat': 26.0, 'minLng': 62.0, 'maxLng': 68.5},
    'azad_kashmir': {'minLat': 33.0, 'maxLat': 35.5, 'minLng': 73.0, 'maxLng': 75.5},
    'islamabad_foot_hills': {'minLat': 33.0, 'maxLat': 34.2, 'minLng': 72.5, 'maxLng': 73.8},
  };

  static const _regionProfiles = {
    'punjab_plains': {
      'name': 'Punjab Plains',
      'climate': 'Semi-Arid Continental',
      'defaultCity': 'Lahore, Punjab',
      'historicalEvents': [
        '• 2010: Major flood event (water level 5.2m)',
        '• 2014: Moderate flooding during monsoon',
        '• 2022: Urban flash floods',
      ],
    },
    'sindh_riverine': {
      'name': 'Sindh Riverine',
      'climate': 'Arid / Subtropical',
      'defaultCity': 'Hyderabad, Sindh',
      'historicalEvents': [
        '• 2010: Indus super flood — widespread inundation',
        '• 2011: Secondary flooding',
        '• 2022: Record monsoon rainfall',
      ],
    },
    'gb_hilly': {
      'name': 'Gilgit-Baltistan Hilly',
      'climate': 'Alpine / Cold Semi-Arid',
      'defaultCity': 'Gilgit, GB',
      'historicalEvents': [
        '• 2010: Attabad landslide / GLOF',
        '• 2019: Avalanche events in high valleys',
      ],
    },
    'kpk_mountain': {
      'name': 'KPK Mountain & Valley',
      'climate': 'Humid Subtropical / Alpine',
      'defaultCity': 'Peshawar, KPK',
      'historicalEvents': [
        '• 2005: Kashmir earthquake impacts',
        '• 2010: Flash floods in Swat',
      ],
    },
    'balochistan_arid': {
      'name': 'Balochistan Arid',
      'climate': 'Arid / Desert',
      'defaultCity': 'Quetta, Balochistan',
      'historicalEvents': ['• 1935: Quetta earthquake', '• 2022: Drought conditions'],
    },
    'coastal_sindh': {
      'name': 'Coastal Sindh',
      'climate': 'Coastal Arid',
      'defaultCity': 'Karachi Coast',
      'historicalEvents': ['• 1999: Cyclone impacts', '• 2021: Urban flooding'],
    },
    'azad_kashmir': {
      'name': 'Azad Jammu & Kashmir',
      'climate': 'Humid Subtropical / Alpine',
      'defaultCity': 'Muzaffarabad, AJK',
      'historicalEvents': ['• 2005: 7.6 magnitude earthquake'],
    },
    'islamabad_foot_hills': {
      'name': 'Islamabad & Potohar',
      'climate': 'Humid Subtropical',
      'defaultCity': 'Islamabad, ICT',
      'historicalEvents': ['• 2005: Earthquake damage in Margalla foothills'],
    },
  };
}
