import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/house_model.dart';
import '../models/resilience_dimensions.dart';

class JsonAssetRepository {
  List<HouseModel>? _houses;
  Map<String, List<String>>? _regionRecommendations;
  Map<String, ResilienceDimensions>? _resilienceScores;
  Map<String, dynamic>? _constructionSteps;
  Map<String, dynamic>? _engineeringNotes;
  Map<String, dynamic>? _materials;
  Map<String, dynamic>? _academy;

  Future<List<HouseModel>> getHouses() async {
    if (_houses != null) return _houses!;
    final raw = await rootBundle.loadString('assets/data/houses.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _houses = (json['models'] as List)
        .map((e) => HouseModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _houses!;
  }

  Future<HouseModel?> getHouseById(String id) async {
    final houses = await getHouses();
    try {
      return houses.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, List<String>>> getRegionRecommendations() async {
    if (_regionRecommendations != null) return _regionRecommendations!;
    final raw = await rootBundle.loadString('assets/data/regions.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _regionRecommendations = {};
    for (final r in json['regions'] as List) {
      final map = r as Map<String, dynamic>;
      _regionRecommendations![map['id'] as String] =
          List<String>.from(map['recommendedModelIds'] as List);
    }
    return _regionRecommendations!;
  }

  Future<ResilienceDimensions> getResilienceScores(String modelId) async {
    if (_resilienceScores == null) {
      final raw =
          await rootBundle.loadString('assets/data/resilience_scores.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final defaults = json['defaultScores'] as Map<String, dynamic>;
      _resilienceScores = {};
      final modelScores = json['modelScores'] as Map<String, dynamic>? ?? {};
      for (final entry in modelScores.entries) {
        _resilienceScores![entry.key] = ResilienceDimensions.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
      _resilienceScores!['__default__'] =
          ResilienceDimensions.fromJson(defaults);
    }
    return _resilienceScores![modelId] ?? _resilienceScores!['__default__']!;
  }

  Future<Map<String, dynamic>> getConstructionSteps() async {
    _constructionSteps ??= jsonDecode(
      await rootBundle.loadString('assets/data/construction_steps.json'),
    ) as Map<String, dynamic>;
    return _constructionSteps!;
  }

  Future<Map<String, dynamic>> getEngineeringNotes() async {
    _engineeringNotes ??= jsonDecode(
      await rootBundle.loadString('assets/data/engineering_notes.json'),
    ) as Map<String, dynamic>;
    return _engineeringNotes!;
  }

  Future<Map<String, dynamic>> getMaterials() async {
    _materials ??= jsonDecode(
      await rootBundle.loadString('assets/data/materials.json'),
    ) as Map<String, dynamic>;
    return _materials!;
  }

  Future<Map<String, dynamic>> getAcademy() async {
    _academy ??= jsonDecode(
      await rootBundle.loadString('assets/data/academy.json'),
    ) as Map<String, dynamic>;
    return _academy!;
  }

  Future<List<Map<String, dynamic>>> getDistricts() async {
    final raw = await rootBundle.loadString('assets/data/districts.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = <Map<String, dynamic>>[];
    for (final province in json['provinces'] as List) {
      final p = province as Map<String, dynamic>;
      for (final d in p['districts'] as List) {
        final district = Map<String, dynamic>.from(d as Map<String, dynamic>);
        district['provinceName'] = p['name'];
        list.add(district);
      }
    }
    return list;
  }

  String getStageModelPath(String modelId, String stageKey) {
    final steps = _constructionSteps;
    if (steps == null) return 'assets/models/generic/stage_01_site.glb';
    final modelStages = steps['modelStages'] as Map<String, dynamic>;
    final config = modelStages[modelId] ?? modelStages['default'];
    final stageModels = config['stageModels'] as Map<String, dynamic>;
    return stageModels[stageKey] as String? ??
        'assets/models/generic/stage_01_site.glb';
  }
}
