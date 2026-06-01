import '../bim_simulation/services/bim_narration_service.dart';
import 'domain/digital_twin_manifest.dart';

/// Synchronized engineering narration for digital twin stages.
class NarrationController {
  NarrationController() : _tts = BimNarrationService();

  final BimNarrationService _tts;
  int _lastStage = -1;

  Future<void> init() => _tts.init();

  void onStageEnter(DigitalTwinStage stage, double progress) {
    if (progress > 0.12) return;
    if (stage.index == _lastStage) return;
    _lastStage = stage.index;
    _tts.speakStage(stage.narration);
  }

  void dispose() => _tts.dispose();
}
