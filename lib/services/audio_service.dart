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
  bool _isBgmMuted = false;

  AudioService._internal() {
    _platform.init();
  }

  bool get isMuted => _isMuted;
  bool get isBgmMuted => _isBgmMuted;
  bool get isBgmPlaying => _assetPlayer.isBgmPlaying;
  String get engineStatus => _platform.getEngineStatus();

  /// Toggles master mute (mutes TTS speech, SFX, and BGM)
  bool toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stop();
      _assetPlayer.stopBgm();
    } else if (!_isBgmMuted) {
      _assetPlayer.startBgm();
    }
    return _isMuted;
  }

  /// Toggles background music independently
  bool toggleBgm() {
    _isBgmMuted = !_isBgmMuted;
    if (_isBgmMuted || _isMuted) {
      _assetPlayer.stopBgm();
    } else {
      _assetPlayer.startBgm();
    }
    return _isBgmMuted;
  }

  /// Starts background music if not muted
  void startBgm() {
    if (_isMuted || _isBgmMuted) return;
    _assetPlayer.startBgm();
  }

  /// Stops background music
  void stopBgm() {
    _assetPlayer.stopBgm();
  }

  /// Speaks text instantly using the local speech synthesis engine with natural human intonation.
  Future<void> speak(String text) async {
    if (_isMuted) return;
    try {
      await _platform.speak(text);
    } catch (_) {}
  }

  /// Play sound effects (e.g., 'pop', 'ding', 'star', 'tuut', 'whoosh', 'twinkle', 'boing', 'fanfare')
  void playSfx(String sfxType) {
    if (_isMuted) return;
    _assetPlayer.playProceduralSfx(sfxType);
  }

  /// Stops current speech and temporary SFX
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

  Future<void> speakIslandMastery(String islandTitle) async {
    final masteryQuotes = [
      "LUAR BIASA! Selamat, kamu telah menuntaskan seluruh kata di $islandTitle! Kamu adalah Juara Sejati!",
      "Horeee! Pesta kembang api untukmu! Seluruh tantangan di $islandTitle berhasil kamu taklukkan!",
      "Wah mengagumkan! Mahkota emas untuk sang master di $islandTitle! Kamu hebat sekali!",
    ];
    final chosen = masteryQuotes[Random().nextInt(masteryQuotes.length)];
    await speak(chosen);
  }
}
