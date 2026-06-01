import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Stage narration synchronized with BIM timeline (professional TTS).
class BimNarrationService {
  BimNarrationService() : _tts = kIsWeb ? null : FlutterTts();

  final FlutterTts? _tts;
  String? _lastSpoken;
  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb || _tts == null) {
      _ready = true;
      return;
    }
    await _tts!.setLanguage('en-GB');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _ready = true;
  }

  Future<void> speakStage(String narration) async {
    if (!_ready || narration == _lastSpoken || _tts == null) return;
    _lastSpoken = narration;
    await _tts!.stop();
    await _tts.speak(narration);
  }

  Future<void> stop() async {
    await _tts?.stop();
    _lastSpoken = null;
  }

  void dispose() {
    _tts?.stop();
  }
}
