import 'dart:convert';

import 'package:flutter/services.dart';

import '../bim_simulation/engine/bim_scene_registry.dart';
import 'domain/digital_twin_manifest.dart';

/// Loads GLB construction sequences + narration; synthesizes manifest from BIM JSON when needed.
abstract final class DigitalTwinEngine {
  static const _manifestPrefix = 'assets/data/digital_twin/';
  static const _bimPrefix = 'assets/data/bim_';

  static final Map<String, DigitalTwinManifest> _cache = {};

  /// True when a dedicated digital-twin manifest exists.
  static Future<bool> hasDedicatedManifest(String modelId) async {
    try {
      await rootBundle.loadString('$_manifestPrefix$modelId.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// True when twin can run — dedicated manifest OR procedural BIM definition.
  static Future<bool> hasAssets(String modelId) async {
    if (await hasDedicatedManifest(modelId)) return true;
    return BimSceneRegistry.hasBimSimulation(modelId);
  }

  static Future<DigitalTwinManifest> loadManifest(String modelId) async {
    if (_cache.containsKey(modelId)) return _cache[modelId]!;
    try {
      final raw = await rootBundle.loadString('$_manifestPrefix$modelId.json');
      final manifest = DigitalTwinManifest.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      _cache[modelId] = manifest;
      return manifest;
    } catch (_) {
      final manifest = await _synthesizeFromBim(modelId);
      _cache[modelId] = manifest;
      return manifest;
    }
  }

  static Future<DigitalTwinManifest> _synthesizeFromBim(String modelId) async {
    final pkg = BimSceneRegistry.packageFor(modelId);
    final raw = await rootBundle.loadString(pkg.definitionAssetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final stages = (json['stages'] as List).map((s) {
      final m = s as Map<String, dynamic>;
      return DigitalTwinStage(
        index: m['index'] as int,
        key: m['key'] as String,
        title: m['title'] as String,
        timelineLabel: m['timelineLabel'] as String,
        durationMs: m['durationMs'] as int,
        glb: 'assets/models/$modelId/completed_house.glb',
        narration: m['narration'] as String,
        explanation: m['explanation'] as String,
        engineeringPrinciple: m['explanation'] as String,
        constructionActivity: m['title'] as String,
        inspectionChecklist: 'Verify per engineering checklist.',
        commonMistakes: const ['Misaligned grid', 'Skipped inspection'],
        resilienceBenefits: const ['Structural continuity', 'Seismic resilience'],
        highlights: List<String>.from(m['highlights'] as List? ?? const []),
      );
    }).toList();

    final hazards = _defaultHazards(modelId);
    final components = Map<String, dynamic>.from(
      json['components'] as Map? ?? {},
    );

    return DigitalTwinManifest(
      modelId: modelId,
      displayName: pkg.displayName,
      masterGlb: 'assets/models/$modelId/completed_house.glb',
      stages: stages,
      hazardSimulations: hazards,
      components: components,
    );
  }

  static Map<String, dynamic> _defaultHazards(String modelId) {
    if (modelId.contains('interlocking')) {
      return {
        'earthquake': {
          'title': 'Earthquake',
          'explanation':
              'Vertical bars, grouted cores and RC bands activate box action under seismic loading.',
          'animationKey': 'earthquake',
        },
        'wind': {
          'title': 'Wind',
          'explanation':
              'Roof truss bracing and sheet fixings resist uplift and racking.',
          'animationKey': 'wind',
        },
        'flood': {
          'title': 'Moderate Flood',
          'explanation':
              'Raised plinth and DPC protect masonry from capillary moisture rise.',
          'animationKey': 'flood',
        },
      };
    }
    return {
      'earthquake': {
        'title': 'Earthquake',
        'explanation': 'Structural system activates ductile load paths.',
        'animationKey': 'earthquake',
      },
    };
  }

  static void clearCache() => _cache.clear();
}
