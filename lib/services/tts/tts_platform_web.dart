import 'dart:async';
import 'dart:js_interop';
import 'tts_platform.dart';

@JS('speechSynthesis')
external SpeechSynthesis? get _synth;

@JS()
extension type SpeechSynthesis._(JSObject _) implements JSObject {
  external void cancel();
  external JSArray<SpeechSynthesisVoice> getVoices();
  external void speak(SpeechSynthesisUtterance utterance);
  external void resume();
  external bool get paused;
  @JS('onvoiceschanged')
  external set onvoiceschanged(JSFunction? listener);
}

@JS()
extension type SpeechSynthesisUtterance._(JSObject _) implements JSObject {
  external SpeechSynthesisUtterance();
  external String lang;
  external double pitch;
  external double rate;
  external String text;
  external SpeechSynthesisVoice? voice;
  external double volume;
  @JS('onend')
  external set onEnd(JSFunction listener);
  @JS('onerror')
  external set onError(JSFunction listener);
}

@JS()
extension type SpeechSynthesisVoice._(JSObject _) implements JSObject {
  external String get lang;
  external String get name;
}

class TtsPlatformWeb implements TtsPlatform {
  SpeechSynthesisVoice? _indonesianVoice;
  String _voiceGender = 'female';
  double _speechRateMultiplier = 1.0;

  SpeechSynthesis? _getSynth() {
    try {
      return _synth;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> init() async {
    try {
      _loadVoices();
      final synth = _getSynth();
      if (synth != null) {
        synth.onvoiceschanged = (() {
          _loadVoices();
        }).toJS;
      }
    } catch (_) {}
  }

  @override
  Future<void> setVoiceGender(String gender) async {
    _voiceGender = gender == 'male' ? 'male' : 'female';
    _loadVoices();
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _speechRateMultiplier = rate.clamp(0.5, 1.5);
  }

  void _loadVoices() {
    try {
      final synth = _getSynth();
      if (synth == null) return;
      final voices = synth.getVoices().toDart;

      SpeechSynthesisVoice? bestVoice;
      int bestScore = -1;
      final isMale = _voiceGender == 'male';

      for (final v in voices) {
        final lang = v.lang.toLowerCase();
        final name = v.name.toLowerCase();

        final isIndonesian = lang.startsWith('id') ||
            lang.contains('indonesia') ||
            name.contains('indonesia') ||
            name.contains('bahasa');

        if (!isIndonesian) continue;

        int score = 10;

        // Gender-specific matching
        if (isMale) {
          if (name.contains('male') ||
              name.contains('ardi') ||
              name.contains('pria') ||
              name.contains('laki')) {
            score += 90;
          } else if (name.contains('female') ||
              name.contains('gadis') ||
              name.contains('damayanti') ||
              name.contains('wanita') ||
              name.contains('perempuan')) {
            score -= 80;
          }
        } else {
          if (name.contains('female') ||
              name.contains('gadis') ||
              name.contains('damayanti') ||
              name.contains('wanita') ||
              name.contains('perempuan')) {
            score += 90;
          } else if (name.contains('male') ||
              name.contains('ardi') ||
              name.contains('pria') ||
              name.contains('laki')) {
            score -= 80;
          }
        }

        // Microsoft Natural / Neural voices
        if (name.contains('natural') || name.contains('neural')) {
          score += 100;
        }
        // Google online cloud natural voice in Chrome
        if (name.contains('google')) {
          score += 85;
        }
        // Apple Damayanti / Siri Premium voices in macOS & iOS
        if (name.contains('damayanti') ||
            name.contains('siri') ||
            name.contains('premium') ||
            name.contains('enhanced')) {
          score += 75;
        }
        // Specific natural persona names (Gadis, Ardi, etc.)
        if (name.contains('gadis') || name.contains('ardi')) {
          score += 50;
        }
        // Exact locale match
        if (lang == 'id-id' || lang == 'id_id') {
          score += 20;
        }
        // Penalize robotic/compact synthesizers
        if (name.contains('compact') || name.contains('espeak')) {
          score -= 40;
        }

        if (score > bestScore) {
          bestScore = score;
          bestVoice = v;
        }
      }

      if (bestVoice != null) {
        _indonesianVoice = bestVoice;
      }
    } catch (_) {}
  }

  @override
  Future<void> speak(String text) async {
    try {
      final synth = _getSynth();
      if (synth == null) return;

      final cleaned = _sanitizeText(text);
      if (cleaned.isEmpty) return;

      if (_indonesianVoice == null) {
        _loadVoices();
      }

      // Immediately cancel any previous speech for instant 0ms response
      synth.cancel();
      if (synth.paused) {
        synth.resume();
      }

      final utterance = SpeechSynthesisUtterance();
      utterance.text = cleaned;
      // Natural human conversational pace: articulate, cheerful, and smooth, scaled by speed rate
      utterance.rate = (0.90 * _speechRateMultiplier).clamp(0.4, 2.0);
      // Vocal pitch intonation based on selected gender
      utterance.pitch = _voiceGender == 'male' ? 0.88 : 1.12;
      utterance.volume = 1.0;

      if (_indonesianVoice != null) {
        utterance.voice = _indonesianVoice;
        utterance.lang = _indonesianVoice!.lang;
      } else {
        utterance.lang = 'id-ID';
      }

      utterance.onError = ((JSObject _) {}).toJS;
      utterance.onEnd = ((JSObject _) {}).toJS;

      synth.speak(utterance);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      final synth = _getSynth();
      if (synth != null) {
        synth.cancel();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    stop();
  }

  @override
  String getEngineStatus() {
    final genderStr = _voiceGender == 'male' ? 'Laki-laki (Cowok)' : 'Perempuan (Cewek)';
    if (_indonesianVoice != null) {
      return 'Suara $genderStr: ${_indonesianVoice!.name}';
    }
    return 'Suara $genderStr: Web Speech Alami (id-ID)';
  }

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

  String _sanitizeText(String input) {
    if (input.isEmpty) return '';

    // 1. Soften ALL-CAPS words (length >= 2) so TTS does not spell them out letter-by-letter
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

TtsPlatform createTtsPlatform() => TtsPlatformWeb();
