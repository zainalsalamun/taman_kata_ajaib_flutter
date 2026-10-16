import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'asset_audio_player.dart';

@JS('Audio')
extension type JSAudio._(JSObject _) implements JSObject {
  external JSAudio([String src]);
  external void play();
  external void pause();
  external set volume(double v);
}

@JS('AudioContext')
extension type JSAudioContext._(JSObject _) implements JSObject {
  external JSAudioContext();
  external double get currentTime;
  external JSObject get destination;
  external JSOscillator createOscillator();
  external JSGain createGain();
}

@JS()
extension type JSOscillator._(JSObject _) implements JSObject {
  external void connect(JSObject destination);
  external void start([double when]);
  external void stop([double when]);
  external String type;
  external JSAudioParam get frequency;
}

@JS()
extension type JSGain._(JSObject _) implements JSObject {
  external void connect(JSObject destination);
  external JSAudioParam get gain;
}

@JS()
extension type JSAudioParam._(JSObject _) implements JSObject {
  external double value;
  external void setValueAtTime(double value, double startTime);
  external void exponentialRampToValueAtTime(double value, double endTime);
  external void linearRampToValueAtTime(double value, double endTime);
}

class AssetAudioPlayerWeb implements AssetAudioPlayer {
  JSAudio? _activeAudio;
  JSAudioContext? _ctx;
  bool _isBgmPlaying = false;
  Timer? _bgmTimer;

  @override
  bool get isBgmPlaying => _isBgmPlaying;

  JSAudioContext? _getContext() {
    try {
      _ctx ??= JSAudioContext();
      return _ctx;
    } catch (_) {
      return null;
    }
  }

  Set<String>? _availableAssets;
  bool _isLoadingManifest = false;

  Future<void> _ensureManifest() async {
    if (_availableAssets != null || _isLoadingManifest) return;
    _isLoadingManifest = true;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _availableAssets = manifest.listAssets().toSet();
    } catch (_) {
      _availableAssets = <String>{};
    } finally {
      _isLoadingManifest = false;
    }
  }

  @override
  Future<bool> play(String assetPath) async {
    try {
      // 1. Verify file exists in AssetManifest without making failing HTTP network requests
      await _ensureManifest();
      if (_availableAssets == null || !_availableAssets!.contains(assetPath)) {
        return false; // File not present in bundle yet, silently fallback to TTS
      }

      // Stop previous asset playback if running
      _activeAudio?.pause();
      _activeAudio = null;

      // In Flutter Web, assets are served at 'assets/' + assetPath
      final url = 'assets/$assetPath';
      final audio = JSAudio(url);
      audio.volume = 1.0;
      audio.play();
      _activeAudio = audio;
      return true;
    } catch (_) {
      return false; // Fallback to TTS
    }
  }

  @override
  void stop() {
    try {
      _activeAudio?.pause();
      _activeAudio = null;
      stopBgm();
    } catch (_) {}
  }

  @override
  void startBgm() {
    if (_isBgmPlaying) return;
    _isBgmPlaying = true;
    _playBgmPhrase();
    _bgmTimer?.cancel();
    _bgmTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (_isBgmPlaying) {
        _playBgmPhrase();
      }
    });
  }

  @override
  void stopBgm() {
    _isBgmPlaying = false;
    _bgmTimer?.cancel();
    _bgmTimer = null;
  }

  void _playBgmPhrase() {
    try {
      final ctx = _getContext();
      if (ctx == null) return;
      final t = ctx.currentTime;
      // Cheerful pentatonic music-box melody: C5, E5, G5, A5, G5, E5, D5, C5
      final notes = [523.25, 659.25, 783.99, 880.00, 783.99, 659.25, 587.33, 523.25];
      for (var i = 0; i < notes.length; i++) {
        final noteTime = t + i * 0.35;
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(notes[i], noteTime);
        gain.gain.setValueAtTime(0.045, noteTime);
        gain.gain.exponentialRampToValueAtTime(0.0001, noteTime + 0.32);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(noteTime);
        osc.stop(noteTime + 0.33);
      }
    } catch (_) {}
  }

  @override
  void playProceduralSfx(String sfxType) {
    try {
      final ctx = _getContext();
      if (ctx == null) return;
      final t = ctx.currentTime;

      switch (sfxType) {
        case 'pop':
          // Cute balloon pop frequency drop
          final osc = ctx.createOscillator();
          final gain = ctx.createGain();
          osc.type = 'sine';
          osc.frequency.setValueAtTime(650.0, t);
          osc.frequency.exponentialRampToValueAtTime(80.0, t + 0.08);
          gain.gain.setValueAtTime(0.4, t);
          gain.gain.exponentialRampToValueAtTime(0.01, t + 0.08);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(t);
          osc.stop(t + 0.09);
          break;

        case 'ding':
          // Pleasant correct chime bell
          final osc = ctx.createOscillator();
          final gain = ctx.createGain();
          osc.type = 'triangle';
          osc.frequency.setValueAtTime(1046.5, t); // C6
          gain.gain.setValueAtTime(0.35, t);
          gain.gain.exponentialRampToValueAtTime(0.001, t + 0.35);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(t);
          osc.stop(t + 0.36);
          break;

        case 'star':
          // 4-note celebration arpeggio
          final notes = [523.25, 659.25, 783.99, 1046.5]; // C5, E5, G5, C6
          for (var i = 0; i < notes.length; i++) {
            final noteTime = t + i * 0.08;
            final osc = ctx.createOscillator();
            final gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(notes[i], noteTime);
            gain.gain.setValueAtTime(0.25, noteTime);
            gain.gain.exponentialRampToValueAtTime(0.001, noteTime + 0.25);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(noteTime);
            osc.stop(noteTime + 0.26);
          }
          break;

        case 'tuut':
          // Two-tone train whistle
          for (final f in [440.0, 554.37]) {
            final osc = ctx.createOscillator();
            final gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(f, t);
            gain.gain.setValueAtTime(0.25, t);
            gain.gain.exponentialRampToValueAtTime(0.001, t + 0.45);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(t);
            osc.stop(t + 0.46);
          }
          break;

        case 'whoosh':
          // Smooth slide sweep
          final osc = ctx.createOscillator();
          final gain = ctx.createGain();
          osc.type = 'sine';
          osc.frequency.setValueAtTime(250.0, t);
          osc.frequency.exponentialRampToValueAtTime(600.0, t + 0.15);
          gain.gain.setValueAtTime(0.2, t);
          gain.gain.exponentialRampToValueAtTime(0.01, t + 0.15);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(t);
          osc.stop(t + 0.16);
          break;

        case 'twinkle':
          // High shimmering bell
          final twinkleNotes = [1318.5, 1568.0, 2093.0];
          for (var i = 0; i < twinkleNotes.length; i++) {
            final noteTime = t + i * 0.08;
            final osc = ctx.createOscillator();
            final gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(twinkleNotes[i], noteTime);
            gain.gain.setValueAtTime(0.2, noteTime);
            gain.gain.exponentialRampToValueAtTime(0.001, noteTime + 0.2);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(noteTime);
            osc.stop(noteTime + 0.21);
          }
          break;

        case 'boing':
          // Playful spring cartoon bounce
          final osc = ctx.createOscillator();
          final gain = ctx.createGain();
          osc.type = 'triangle';
          osc.frequency.setValueAtTime(160.0, t);
          osc.frequency.linearRampToValueAtTime(380.0, t + 0.18);
          gain.gain.setValueAtTime(0.3, t);
          gain.gain.exponentialRampToValueAtTime(0.01, t + 0.25);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(t);
          osc.stop(t + 0.26);
          break;

        case 'fanfare':
          // Grand victory fanfare chords
          final fanfareNotes = [523.25, 659.25, 783.99, 1046.5];
          for (var i = 0; i < fanfareNotes.length; i++) {
            final noteTime = t + i * 0.1;
            final osc = ctx.createOscillator();
            final gain = ctx.createGain();
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(fanfareNotes[i], noteTime);
            gain.gain.setValueAtTime(0.3, noteTime);
            gain.gain.exponentialRampToValueAtTime(0.001, noteTime + 0.45);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(noteTime);
            osc.stop(noteTime + 0.46);
          }
          break;
      }
    } catch (_) {}
  }
}

AssetAudioPlayer createPlatformAssetAudioPlayer() => AssetAudioPlayerWeb();
