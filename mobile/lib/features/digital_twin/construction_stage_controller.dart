import 'package:flutter/foundation.dart';

import 'domain/digital_twin_manifest.dart';

/// Timeline playback for GLB construction stages (BIM 4D sequencing).
class ConstructionStageController extends ChangeNotifier {
  ConstructionStageController(this.manifest);

  final DigitalTwinManifest manifest;

  int stageIndex = 0;
  double stageProgress = 0;
  bool isPlaying = false;
  double playbackSpeed = 1.0;
  String hazardMode = 'none'; // none | earthquake | flood | wind | landslide

  DigitalTwinStage? get currentStage =>
      manifest.stages.isEmpty ? null : manifest.stages[stageIndex.clamp(0, manifest.stages.length - 1)];

  String get currentGlbPath =>
      currentStage?.glb ?? manifest.masterGlb;

  void setStage(int index) {
    stageIndex = index.clamp(0, manifest.stages.length - 1);
    stageProgress = 0;
    notifyListeners();
  }

  void setHazardMode(String mode) {
    hazardMode = mode;
    notifyListeners();
  }

  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed = speed.clamp(0.5, 2.0);
    notifyListeners();
  }

  void advance(double dtSeconds) {
    if (!isPlaying || manifest.stages.isEmpty) return;
    final stage = currentStage!;
    final durationSec = stage.durationMs / 1000.0 / playbackSpeed;
    stageProgress += dtSeconds / durationSec;
    if (stageProgress >= 1) {
      stageProgress = 0;
      if (stageIndex < manifest.stages.length - 1) {
        stageIndex++;
      } else {
        isPlaying = false;
        stageIndex = manifest.stages.length - 1;
        stageProgress = 1;
      }
    }
    notifyListeners();
  }

  void scrub(double normalized) {
    final total = manifest.stages.length;
    final pos = normalized.clamp(0, 1) * total;
    stageIndex = pos.floor().clamp(0, total - 1);
    stageProgress = pos - stageIndex;
    notifyListeners();
  }
}
