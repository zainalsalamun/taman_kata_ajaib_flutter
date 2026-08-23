import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isMuted = false;

  AudioService._internal() {
    _initTts();
  }

  bool get isMuted => _isMuted;

  void _initTts() async {
    try {
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.42); // Slower for clear child pronunciation
      await _flutterTts.setPitch(1.25);      // Cheerful friendly tone
      await _flutterTts.setVolume(1.0);
    } catch (_) {}
  }

  bool toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _flutterTts.stop();
    }
    return _isMuted;
  }

  Future<void> speak(String text) async {
    if (_isMuted) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> speakPraise() async {
    final praises = [
      "Wah, hebat sekali!",
      "Pintar!",
      "Luar biasa!",
      "Bagus sekali!",
      "Hore, kamu berhasil!",
      "Keren banget!"
    ];
    final chosen = praises[Random().nextInt(praises.length)];
    await speak(chosen);
  }
}
