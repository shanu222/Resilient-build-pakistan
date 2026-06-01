import 'dart:convert';

import 'package:flutter/services.dart';

import 'domain/digital_twin_manifest.dart';

/// Loads generated GLB construction sequences + narration without per-model Dart code.
abstract final class DigitalTwinEngine {
  static const _manifestPrefix = 'assets/data/digital_twin/';

  static final Map<String, DigitalTwinManifest> _cache = {};

  /// True when pipeline deployed `assets/data/digital_twin/{modelId}.json`.
  static Future<bool> hasAssets(String modelId) async {
    try {
      await rootBundle.loadString('$_manifestPrefix$modelId.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<DigitalTwinManifest> loadManifest(String modelId) async {
    if (_cache.containsKey(modelId)) return _cache[modelId]!;
    final raw = await rootBundle.loadString('$_manifestPrefix$modelId.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final manifest = DigitalTwinManifest.fromJson(json);
    _cache[modelId] = manifest;
    return manifest;
  }

  static void clearCache() => _cache.clear();
}
