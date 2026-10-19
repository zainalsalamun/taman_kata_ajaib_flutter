import 'dart:math';
import 'tts/tts_platform.dart';
import 'tts/tts_platform_selector.dart';
import 'audio/asset_audio_player.dart';
import 'audio/asset_audio_player_selector.dart';
import 'storage_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final TtsPlatform _platform = createPlatformTts();
  final AssetAudioPlayer _assetPlayer = createAssetAudioPlayer();
  bool _isMuted = false;
  bool _isBgmMuted = false;
  String _voiceGender = 'female';

  static final Map<String, String> _phonicsMap = {
    'A': 'Aa',
    'B': 'Beh',
    'C': 'Ceh',
    'D': 'Deh',
    'E': 'Eh',
    'F': 'Ef',
    'G': 'Geh',
    'H': 'Hah',
    'I': 'Ii',
    'J': 'Jeh',
    'K': 'Kah',
    'L': 'El',
    'M': 'Em',
    'N': 'En',
    'O': 'O',
    'P': 'Peh',
    'Q': 'Ki',
    'R': 'Er',
    'S': 'Es',
    'T': 'Teh',
    'U': 'Uu',
    'V': 'Feh',
    'W': 'Weh',
    'X': 'Eks',
    'Y': 'Ye',
    'Z': 'Zet',
  };

  AudioService._internal() {
    _platform.init();
    _initVoiceGender();
  }

  Future<void> _initVoiceGender() async {
    try {
      final saved = await StorageService.getVoiceGender();
      _voiceGender = saved;
      await _platform.setVoiceGender(_voiceGender);
    } catch (_) {}
  }

  bool get isMuted => _isMuted;
  bool get isBgmMuted => _isBgmMuted;
  bool get isBgmPlaying => _assetPlayer.isBgmPlaying;
  String get engineStatus => _platform.getEngineStatus();
  String get voiceGender => _voiceGender;

  /// Sets voice gender ('female' or 'male') and persists selection
  Future<void> setVoiceGender(String gender) async {
    _voiceGender = gender == 'male' ? 'male' : 'female';
    try {
      await StorageService.saveVoiceGender(_voiceGender);
      await _platform.setVoiceGender(_voiceGender);
    } catch (_) {}
  }

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

  /// Normalizes text for authentic Indonesian preschool phonics pronunciation.
  /// Converts single letters (e.g. 'B' -> 'Beh', 'C' -> 'Ceh') and softens ALL-CAPS words so TTS engines don't spell acronyms.
  static String normalizeIndonesianPhonics(String text) {
    if (text.isEmpty) return text;

    // 1. Soften ALL-CAPS words (length >= 2) so Android/iOS TTS does not spell them out letter-by-letter
    var result = text.replaceAllMapped(RegExp(r'\b([A-Z]{2,})\b'), (match) {
      final word = match.group(1)!;
      return word[0] + word.substring(1).toLowerCase();
    });

    // 2. Convert "Huruf X" or "huruf X" to authentic Indonesian phonics
    result = result.replaceAllMapped(RegExp(r'\b([Hh]uruf)\s+([A-Za-z])\b'), (match) {
      final prefix = match.group(1)!;
      final letter = match.group(2)!.toUpperCase();
      return '$prefix ${_phonicsMap[letter] ?? letter}';
    });

    // 3. Convert single standalone letters with boundaries to authentic Indonesian phonics
    result = result.replaceAllMapped(
      RegExp(r'(^|[\s.,!?:;("])([A-Za-z])(?=[\s.,!?:;)"]|$)'),
      (match) {
        final prefix = match.group(1)!;
        final letter = match.group(2)!.toUpperCase();
        if (_phonicsMap.containsKey(letter)) {
          return '$prefix${_phonicsMap[letter]}';
        }
        return match.group(0)!;
      },
    );

    return result;
  }

  /// Speaks text instantly using the local speech synthesis engine with natural human intonation.
  Future<void> speak(String text) async {
    if (_isMuted) return;
    try {
      final processed = normalizeIndonesianPhonics(text);
      await _platform.speak(processed);
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
      "Luar biasa! Selamat, kamu telah menuntaskan seluruh kata di $islandTitle! Kamu adalah Juara Sejati!",
      "Horeee! Pesta kembang api untukmu! Seluruh tantangan di $islandTitle berhasil kamu taklukkan!",
      "Wah mengagumkan! Mahkota emas untuk sang master di $islandTitle! Kamu hebat sekali!",
    ];
    final chosen = masteryQuotes[Random().nextInt(masteryQuotes.length)];
    await speak(chosen);
  }
}
