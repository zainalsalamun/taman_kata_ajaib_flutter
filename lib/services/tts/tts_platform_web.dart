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
      for (final v in voices) {
        final lang = v.lang;
        if (lang.isNotEmpty) {
          final langLower = lang.toLowerCase();
          if (langLower.startsWith('id') || langLower.contains('indonesia')) {
            _indonesianVoice = v;
            break;
          }
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> speak(String text) async {
    try {
      final cleaned = _sanitizeText(text);
      if (cleaned.isEmpty) return;

      // 1. Prioritize Meta MMS-TTS Engine if available and ready
      final mms = _mmsEngine;
      if (mms != null && mms.isReady()) {
        try {
          final jsPromise = mms.speak(cleaned);
          final res = await jsPromise.toDart;
          if (res.toDart) {
            return; // Successfully spoken via Meta MMS-TTS!
          }
        } catch (_) {}
      }

      // 2. Fallback to clean Web Speech API
      final synth = _getSynth();
      if (synth == null) return;

      final currentId = ++_speakRequestId;

      synth.cancel();
      if (synth.paused) {
        synth.resume();
      }

      // Small async delay allows browser's speech synthesis engine
      // to cleanly flush cancellation before queuing the next utterance
      await Future<void>.delayed(const Duration(milliseconds: 35));

      // Drop if superseded by a newer speak request during the brief wait
      if (currentId != _speakRequestId) return;

      final utterance = SpeechSynthesisUtterance();
      utterance.text = cleaned;
      utterance.rate = 0.90; // Natural Indonesian pacing for early learners
      utterance.pitch = 1.20; // Cheerful tone for kids
      utterance.volume = 1.0;

      if (_indonesianVoice != null) {
        utterance.voice = _indonesianVoice;
        utterance.lang = _indonesianVoice!.lang;
      } else {
        utterance.lang = 'id-ID';
      }

      // Silent error handler ensures cancellations never throw or log error spam
      utterance.onError = ((JSObject _) {}).toJS;
      utterance.onEnd = ((JSObject _) {}).toJS;

      synth.speak(utterance);
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
    if (mms != null) {
      if (mms.isReady()) {
        return 'AI Indonesia (Meta MMS-TTS Aktif)';
      }
      return mms.getStatusMessage();
    }
    return 'Web Speech API Bawaan';
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
