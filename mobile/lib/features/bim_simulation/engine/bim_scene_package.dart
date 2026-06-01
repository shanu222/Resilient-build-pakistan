import 'bim_entity.dart';
import 'math/bim_vec3.dart';

/// Model-specific BIM scene + stage animation rules (procedural or GLB-backed).
abstract class BimScenePackage {
  String get modelId;
  String get displayName;
  String get definitionAssetPath;
  double get crossSectionCenterX;

  List<BimEntity> buildScene();

  /// Progress 0–1 for entity during [stageIndex] animation.
  double entityProgress(BimEntity entity, int stageIndex, double stageProgress);
}
