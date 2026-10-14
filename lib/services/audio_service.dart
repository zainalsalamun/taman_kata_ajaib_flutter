import 'dart:math';
import 'tts/tts_platform.dart';
import 'tts/tts_platform_selector.dart';
import 'audio/asset_audio_player.dart';
import 'audio/asset_audio_player_selector.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final TtsPlatform _platform = createPlatformTts();
  final AssetAudioPlayer _assetPlayer = createAssetAudioPlayer();
  bool _isMuted = false;

  AudioService._internal() {
    _platform.init();
  }

  bool get isMuted => _isMuted;
  String get engineStatus => _platform.getEngineStatus();

  bool toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stop();
    }
    return _isMuted;
  }

  /// Speaks text instantly using the local speech synthesis engine with natural human intonation.
  Future<void> speak(String text) async {
    if (_isMuted) return;
    try {
      await _platform.speak(text);
    } catch (_) {}
  }

  /// Play sound effects (e.g., 'pop', 'ding', 'star', 'tuut', 'whoosh')
  void playSfx(String sfxType) {
    if (_isMuted) return;
    _assetPlayer.playProceduralSfx(sfxType);
  }

  Future<void> stop() async {
    try {
      _assetPlayer.stop();
      await _platform.stop();
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

  Future<void> speakCelebration() async {
    final celebrations = [
      "Horeee! Luar biasa! Tiga bintang berkilau untukmu!",
      "Yeeay! Pintar sekali! Kamu berhasil menyelesaikan tantangan!",
      "Wah, hebat banget! Tiga bintang emas untuk anak pintar!",
      "Keren sekali! Hore, kamu menang!",
      "Luar biasa! Kamu semakin pintar membaca!",
    ];
    final chosen = celebrations[Random().nextInt(celebrations.length)];
    await speak(chosen);
  }
}
