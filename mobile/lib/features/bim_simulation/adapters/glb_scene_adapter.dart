import '../engine/bim_entity.dart';

/// Future adapter: load GLB/GLTF from assets or Firebase Storage and map to [BimEntity] list.
/// Keeps procedural engine as fallback when GLB is unavailable.
abstract class GlbSceneAdapter {
  Future<List<BimEntity>> loadStageModel({
    required String modelId,
    required String stageKey,
    String? assetPath,
    String? remoteUrl,
  });

  bool get isAvailable;
}

class StubGlbSceneAdapter implements GlbSceneAdapter {
  @override
  bool get isAvailable => false;

  @override
  Future<List<BimEntity>> loadStageModel({
    required String modelId,
    required String stageKey,
    String? assetPath,
    String? remoteUrl,
  }) async {
    throw UnimplementedError('GLB adapter not configured — using procedural BIM scene');
  }
}
