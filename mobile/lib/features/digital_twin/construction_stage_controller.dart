import 'package:flutter/foundation.dart';

import 'domain/digital_twin_manifest.dart';

enum PlaybackDirection { forward, reverse }

enum PlaybackState { stopped, playing, paused }

/// Timeline playback for GLB construction stages (BIM 4D sequencing).
class ConstructionStageController extends ChangeNotifier {
  ConstructionStageController(this.manifest);

  final DigitalTwinManifest manifest;

  int stageIndex = 0;
  double stageProgress = 0;
  PlaybackState playbackState = PlaybackState.stopped;
  PlaybackDirection playbackDirection = PlaybackDirection.forward;
  double playbackSpeed = 1.0; // 0.25× .. 4×
  String hazardMode = 'none'; // none | earthquake | flood | wind | landslide

  // Playback/UI state that should be preserved across stage changes.
  // This is intentionally lightweight: viewer/camera state lives in the viewport (web component / BIM controller).
  String selectedViewMode = 'default';

  // Runtime stats (best-effort).
  double fpsEstimate = 0;
  double _fpsSmoothing = 0;

  DigitalTwinStage? get currentStage =>
      manifest.stages.isEmpty ? null : manifest.stages[stageIndex.clamp(0, manifest.stages.length - 1)];

  String get currentGlbPath =>
      currentStage?.glb ?? manifest.masterGlb;

  bool get isPlaying => playbackState == PlaybackState.playing;

  double get progressNormalized {
    final total = manifest.stages.length;
    if (total == 0) return 0;
    return ((stageIndex + stageProgress) / total).clamp(0, 1);
  }

  void setStage(int index) {
    stageIndex = index.clamp(0, manifest.stages.length - 1);
    stageProgress = 0;
    notifyListeners();
  }

  void setHazardMode(String mode) {
    hazardMode = mode;
    notifyListeners();
  }

  void play() {
    playbackState = PlaybackState.playing;
    notifyListeners();
  }

  void pause() {
    if (playbackState == PlaybackState.playing) {
      playbackState = PlaybackState.paused;
      notifyListeners();
    }
  }

  void stop() {
    playbackState = PlaybackState.stopped;
    stageProgress = 0;
    notifyListeners();
  }

  void restart() {
    stageIndex = 0;
    stageProgress = 0;
    playbackState = PlaybackState.stopped;
    notifyListeners();
  }

  void previousStage() {
    if (manifest.stages.isEmpty) return;
    stageIndex = (stageIndex - 1).clamp(0, manifest.stages.length - 1);
    stageProgress = 0;
    notifyListeners();
  }

  void nextStage() {
    if (manifest.stages.isEmpty) return;
    stageIndex = (stageIndex + 1).clamp(0, manifest.stages.length - 1);
    stageProgress = 0;
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed = speed.clamp(0.25, 4.0);
    notifyListeners();
  }

  void setPlaybackDirection(PlaybackDirection direction) {
    playbackDirection = direction;
    notifyListeners();
  }

  void setSelectedViewMode(String mode) {
    selectedViewMode = mode;
    notifyListeners();
  }

  void advance(double dtSeconds) {
    if (!isPlaying || manifest.stages.isEmpty) return;
    final stage = currentStage!;
    final durationSec = (stage.durationMs / 1000.0) / playbackSpeed;
    final delta = dtSeconds / durationSec;

    if (playbackDirection == PlaybackDirection.forward) {
      stageProgress += delta;
      if (stageProgress >= 1) {
        stageProgress = 0;
        if (stageIndex < manifest.stages.length - 1) {
          stageIndex++;
        } else {
          playbackState = PlaybackState.stopped;
          stageIndex = manifest.stages.length - 1;
          stageProgress = 1;
        }
      }
    } else {
      stageProgress -= delta;
      if (stageProgress <= 0) {
        stageProgress = 0;
        if (stageIndex > 0) {
          stageIndex--;
          stageProgress = 1;
        } else {
          playbackState = PlaybackState.stopped;
          stageIndex = 0;
          stageProgress = 0;
        }
      }
    }
    notifyListeners();
  }

  void reportFrameTime(double dtSeconds) {
    if (dtSeconds <= 0) return;
    final fps = 1.0 / dtSeconds;
    _fpsSmoothing = (_fpsSmoothing == 0) ? fps : (_fpsSmoothing * 0.90 + fps * 0.10);
    fpsEstimate = _fpsSmoothing.clamp(0, 240);
  }

  void scrub(double normalized) {
    final total = manifest.stages.length;
    final pos = normalized.clamp(0, 1) * total;
    stageIndex = pos.floor().clamp(0, total - 1);
    stageProgress = (pos - stageIndex).toDouble();
    notifyListeners();
  }
}
