import 'package:flutter_tts/flutter_tts.dart';
import 'tts_platform.dart';

class TtsPlatformIo implements TtsPlatform {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  Future<void> init() async {
    try {
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.42); // Clear tempo for children
      await _flutterTts.setPitch(1.25);      // Cheerful tone
      await _flutterTts.setVolume(1.0);
    } catch (_) {}
  }

  @override
  Future<void> speak(String text) async {
    try {
      final cleaned = _sanitizeText(text);
      if (cleaned.isEmpty) return;
      await _flutterTts.stop();
      await _flutterTts.speak(cleaned);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _flutterTts.stop();
  }

  @override
  String getEngineStatus() => 'Sistem Native (Android/iOS)';

  String _sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[^\w\s.,!?-]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

TtsPlatform createTtsPlatform() => TtsPlatformIo();
