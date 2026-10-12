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

  static const Map<String, String> _voiceKeyMap = {
    // Praises
    "Wah, hebat sekali!": "assets/audio/praises/hebat.wav",
    "Pintar!": "assets/audio/praises/pintar.wav",
    "Luar biasa!": "assets/audio/praises/luarbiasa.wav",
    "Bagus sekali!": "assets/audio/praises/bagus.wav",
    "Hore, kamu berhasil!": "assets/audio/praises/berhasil.wav",
    "Keren banget!": "assets/audio/praises/keren.wav",

    // Celebrations
    "Horeee! Luar biasa! Tiga bintang berkilau untukmu!": "assets/audio/praises/celeb_bintang.wav",
    "Yeeay! Pintar sekali! Kamu berhasil menyelesaikan tantangan!": "assets/audio/praises/celeb_tantangan.wav",
    "Wah, hebat banget! Tiga bintang emas untuk anak pintar!": "assets/audio/praises/celeb_emas.wav",
    "Keren sekali! Hore, kamu menang!": "assets/audio/praises/celeb_menang.wav",
    "Luar biasa! Kamu semakin pintar membaca!": "assets/audio/praises/celeb_membaca.wav",

    // Train words & actions
    "Tuut tuut! Kereta meluncur!": "assets/audio/words/train_meluncur.wav",
    "APEL": "assets/audio/words/apel.wav",
    "BOLA": "assets/audio/words/bola.wav",
    "BUKU": "assets/audio/words/buku.wav",
    "CERI": "assets/audio/words/ceri.wav",
    "DUKU": "assets/audio/words/duku.wav",
    "GAJAH": "assets/audio/words/gajah.wav",
    "IKAN": "assets/audio/words/ikan.wav",
    "KUDA": "assets/audio/words/kuda.wav",
    "MATA": "assets/audio/words/mata.wav",
    "NAGA": "assets/audio/words/naga.wav",
    "RUSA": "assets/audio/words/rusa.wav",
    "TOPI": "assets/audio/words/topi.wav",
    "SEPEDA": "assets/audio/words/sepeda.wav",
    "KERETA": "assets/audio/words/kereta.wav",
    "SEPATU": "assets/audio/words/sepatu.wav",
    "PESAWAT": "assets/audio/words/pesawat.wav",
  };

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

  /// Speaks text using pre-recorded studio asset if available,
  /// otherwise seamlessly falls back to the system/web TTS engine.
  Future<void> speak(String text, {String? audioKey}) async {
    if (_isMuted) return;

    // 1. Resolve matching audio asset path if present
    String? assetPath;
    if (audioKey != null) {
      assetPath = audioKey.endsWith('.wav') || audioKey.endsWith('.mp3')
          ? audioKey
          : 'assets/audio/$audioKey.wav';
    } else if (_voiceKeyMap.containsKey(text)) {
      assetPath = _voiceKeyMap[text];
    } else if (text.startsWith('Huruf ') && text.length > 6) {
      final char = text[6].toLowerCase();
      if (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122) {
        assetPath = 'assets/audio/letters/$char.wav';
      }
    }

    // 2. Attempt asset audio playback
    if (assetPath != null) {
      final played = await _assetPlayer.play(assetPath);
      if (played) return;
    }

    // 3. Fallback to TTS engine
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
