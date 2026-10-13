import 'dart:async';
import 'dart:js_interop';
import 'tts_platform.dart';

@JS('speechSynthesis')
external SpeechSynthesis? get _synth;

@JS('MmsTtsEngine')
external JSMmsTtsEngine? get _mmsEngine;

@JS()
extension type JSMmsTtsEngine._(JSObject _) implements JSObject {
  external JSPromise<JSBoolean> speak(String text);
  external void stop();
  external bool isReady();
  external String getStatus();
  external String getStatusMessage();
  external void setMmsEnabled(bool enabled);
  external bool hasCached(String text);
  external void preload(String text);
}

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
  int _speakRequestId = 0;

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

  void _loadVoices() {
    try {
      final synth = _getSynth();
      if (synth == null) return;
      final voices = synth.getVoices().toDart;
      
      SpeechSynthesisVoice? bestVoice;
      int bestScore = -1;

      for (final v in voices) {
        final lang = v.lang.toLowerCase();
        final name = v.name.toLowerCase();

        final isIndonesian = lang.startsWith('id') ||
            lang.contains('indonesia') ||
            name.contains('indonesia') ||
            name.contains('bahasa');

        if (!isIndonesian) continue;

        int score = 10;

        // Microsoft / Edge Natural & Neural voices (highest fidelity human recordings)
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
      final cleaned = _sanitizeText(text);
      if (cleaned.isEmpty) return;

      // Ensure voices are loaded
      if (_indonesianVoice == null) {
        _loadVoices();
      }

      final mms = _mmsEngine;

      // 1. Instant 0ms memory playback if preloaded/cached in MmsTtsEngine AudioBuffer
      if (mms != null && mms.hasCached(cleaned)) {
        try {
          final jsPromise = mms.speak(cleaned);
          final res = await jsPromise.toDart;
          if (res.toDart) {
            return; // Spoken instantly in 0ms!
          }
        } catch (_) {}
      }

      // 2. High-quality Web Speech API with natural human settings
      // If browser has a ranked natural human voice (Google Bahasa Indonesia,
      // Damayanti Siri, or Microsoft Gadis Natural), speak IMMEDIATELY (0ms)!
      final synth = _getSynth();
      if (synth != null && _indonesianVoice != null) {
        final currentId = ++_speakRequestId;

        synth.cancel();
        if (synth.paused) {
          synth.resume();
        }

        if (currentId != _speakRequestId) return;

        final utterance = SpeechSynthesisUtterance();
        utterance.text = cleaned;
        utterance.rate = 0.94; // Natural human cadence for clear comprehension
        utterance.pitch = 1.0;  // Authentic human vocal pitch (eliminates robotic distortion)
        utterance.volume = 1.0;
        utterance.voice = _indonesianVoice;
        utterance.lang = _indonesianVoice!.lang;

        // Silent error handler ensures cancellations never throw or log error spam
        utterance.onError = ((JSObject _) {}).toJS;
        utterance.onEnd = ((JSObject _) {}).toJS;

        synth.speak(utterance);

        // Preload into audio cache in the background for instant AudioBuffer next time
        if (mms != null) {
          mms.preload(cleaned);
        }
        return;
      }

      // 3. Fallback to MMS engine (fetches stream or ONNX inference)
      if (mms != null) {
        try {
          final jsPromise = mms.speak(cleaned);
          final res = await jsPromise.toDart;
          if (res.toDart) return;
        } catch (_) {}
      }

      // 4. Ultimate fallback to standard Web Speech
      if (synth != null) {
        synth.cancel();
        if (synth.paused) synth.resume();

        final utterance = SpeechSynthesisUtterance();
        utterance.text = cleaned;
        utterance.rate = 0.94;
        utterance.pitch = 1.0;
        utterance.volume = 1.0;
        utterance.lang = 'id-ID';
        utterance.onError = ((JSObject _) {}).toJS;
        utterance.onEnd = ((JSObject _) {}).toJS;

        synth.speak(utterance);
      }
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      _mmsEngine?.stop();
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
    final mms = _mmsEngine;
    if (mms != null && mms.isReady()) {
      return 'AI Offline (Meta MMS-TTS Aktif)';
    }
    if (_indonesianVoice != null) {
      return 'Suara Alami: ${_indonesianVoice!.name}';
    }
    return 'Web Speech Alami (id-ID)';
  }

  String _sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[^\w\s.,!?-]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

TtsPlatform createTtsPlatform() => TtsPlatformWeb();
