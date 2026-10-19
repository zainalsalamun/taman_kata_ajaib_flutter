import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_platform.dart';

class TtsPlatformIo implements TtsPlatform {
  final FlutterTts _flutterTts = FlutterTts();
  Completer<void>? _initCompleter;
  bool _isInitialized = false;
  String _activeVoiceName = 'id-ID';
  String _voiceGender = 'female'; // 'female' or 'male'

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

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();
    try {
      await _setupTts();
    } catch (_) {}
    _isInitialized = true;
    if (!_initCompleter!.isCompleted) {
      _initCompleter!.complete();
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  @override
  Future<void> setVoiceGender(String gender) async {
    _voiceGender = gender == 'male' ? 'male' : 'female';
    await _ensureInitialized();
    await _applyVoiceAndPitch();
  }

  Future<void> _setupTts() async {
    // 1. Android Engine Priority: Select Google TTS engine if available
    if (Platform.isAndroid) {
      try {
        final engines = await _flutterTts.getEngines;
        if (engines is List && engines.contains('com.google.android.tts')) {
          await _flutterTts.setEngine('com.google.android.tts');
        }
      } catch (_) {}

      try {
        // QUEUE_FLUSH mode (0): new speech interrupts immediately without laggy backlog
        await _flutterTts.setQueueMode(0);
      } catch (_) {}
    }

    // 2. iOS Audio Session Configuration
    if (Platform.isIOS) {
      try {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
        await _flutterTts.setSharedInstance(true);
      } catch (_) {}
    }

    // 3. Multi-Locale Fallbacks for Indonesian
    final candidateLocales = ['id-ID', 'id_ID', 'in-ID', 'in_ID', 'id'];
    bool languageSet = false;
    for (final loc in candidateLocales) {
      try {
        final isAvail = await _flutterTts.isLanguageAvailable(loc);
        if (isAvail == true || isAvail == 1) {
          await _flutterTts.setLanguage(loc);
          languageSet = true;
          _activeVoiceName = loc;
          break;
        }
      } catch (_) {}
    }

    if (!languageSet) {
      try {
        await _flutterTts.setLanguage('id-ID');
      } catch (_) {}
    }

    // 4. Apply Gender-Specific Voice Selection and Pitch Formant
    await _applyVoiceAndPitch();
  }

  Future<void> _applyVoiceAndPitch() async {
    final isMale = _voiceGender == 'male';

    // Search and score available voices matching the selected gender
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List && voices.isNotEmpty) {
        Map<String, String>? bestVoice;
        int bestScore = -1;

        for (final v in voices) {
          if (v is! Map) continue;
          final name = (v['name'] ?? '').toString().toLowerCase();
          final locale = (v['locale'] ?? '').toString().toLowerCase();

          final isIndonesian = locale.startsWith('id') ||
              locale.startsWith('in') ||
              locale.contains('indonesia') ||
              name.contains('indonesia') ||
              name.contains('bahasa') ||
              name.contains('id-id') ||
              name.contains('id_id');

          if (!isIndonesian) continue;

          int score = 10;
          if (name.contains('wavenet') ||
              name.contains('neural') ||
              name.contains('natural')) {
            score += 100;
          }
          if (name.contains('google')) {
            score += 60;
          }

          if (isMale) {
            // Favor male voice identifiers
            if (name.contains('male') ||
                name.contains('pria') ||
                name.contains('laki') ||
                name.contains('ardi') ||
                name.contains('#male')) {
              score += 90;
            } else if (name.contains('female') ||
                name.contains('wanita') ||
                name.contains('perempuan') ||
                name.contains('damayanti') ||
                name.contains('gadis') ||
                name.contains('#female')) {
              score -= 80;
            }
          } else {
            // Favor female voice identifiers
            if (name.contains('female') ||
                name.contains('wanita') ||
                name.contains('perempuan') ||
                name.contains('damayanti') ||
                name.contains('gadis') ||
                name.contains('#female')) {
              score += 90;
            } else if (name.contains('male') ||
                name.contains('pria') ||
                name.contains('laki') ||
                name.contains('ardi') ||
                name.contains('#male')) {
              score -= 80;
            }
          }

          if (locale == 'id-id' || locale == 'id_id') {
            score += 20;
          }
          if (name.contains('compact') || name.contains('espeak')) {
            score -= 40;
          }

          if (score > bestScore) {
            bestScore = score;
            bestVoice = {
              'name': v['name'].toString(),
              'locale': v['locale'].toString(),
            };
          }
        }

        if (bestVoice != null) {
          _activeVoiceName = bestVoice['name']!;
          await _flutterTts.setVoice(bestVoice);
        }
      }
    } catch (_) {}

    // Vocal parameters:
    // Female: Pitch 1.12 (cheerful, warm, mascot vocal tone)
    // Male: Pitch 0.88 (warm, friendly, mentor vocal tone)
    try {
      final targetPitch = isMale ? 0.88 : 1.12;
      await _flutterTts.setPitch(targetPitch);
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
    } catch (_) {}
  }

  @override
  Future<void> speak(String text) async {
    try {
      await _ensureInitialized();
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
  String getEngineStatus() {
    final genderStr = _voiceGender == 'male' ? 'Laki-laki (Cowok)' : 'Perempuan (Cewek)';
    return 'Suara $genderStr: $_activeVoiceName';
  }

  String _sanitizeText(String input) {
    if (input.isEmpty) return '';

    // 1. Soften ALL-CAPS words (length >= 2) so Android TTS does not spell them out letter-by-letter
    var text = input.replaceAllMapped(RegExp(r'\b([A-Z]{2,})\b'), (match) {
      final word = match.group(1)!;
      return word[0] + word.substring(1).toLowerCase();
    });

    // 2. Convert "Huruf X" or "huruf X" to authentic Indonesian phonics
    text = text.replaceAllMapped(RegExp(r'\b([Hh]uruf)\s+([A-Za-z])\b'), (match) {
      final prefix = match.group(1)!;
      final letter = match.group(2)!.toUpperCase();
      return '$prefix ${_phonicsMap[letter] ?? letter}';
    });

    // 3. Convert single standalone letters with punctuation/boundaries to authentic Indonesian phonics
    text = text.replaceAllMapped(
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

    // 4. Clean emojis and unwanted symbols while preserving sentence punctuation
    return text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[^\w\s.,!?-]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

TtsPlatform createTtsPlatform() => TtsPlatformIo();
