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

        case 'firework':
          // Rising rocket whistle + booming burst + sparkling crackle
          final whistleOsc = ctx.createOscillator();
          final whistleGain = ctx.createGain();
          whistleOsc.type = 'sine';
          whistleOsc.frequency.setValueAtTime(450.0, t);
          whistleOsc.frequency.exponentialRampToValueAtTime(1400.0, t + 0.14);
          whistleGain.gain.setValueAtTime(0.2, t);
          whistleGain.gain.exponentialRampToValueAtTime(0.01, t + 0.15);
          whistleOsc.connect(whistleGain);
          whistleGain.connect(ctx.destination);
          whistleOsc.start(t);
          whistleOsc.stop(t + 0.15);

          // Deep explosion boom
          final burstTime = t + 0.14;
          final boomOsc = ctx.createOscillator();
          final boomGain = ctx.createGain();
          boomOsc.type = 'triangle';
          boomOsc.frequency.setValueAtTime(150.0, burstTime);
          boomOsc.frequency.exponentialRampToValueAtTime(35.0, burstTime + 0.35);
          boomGain.gain.setValueAtTime(0.45, burstTime);
          boomGain.gain.exponentialRampToValueAtTime(0.001, burstTime + 0.35);
          boomOsc.connect(boomGain);
          boomGain.connect(ctx.destination);
          boomOsc.start(burstTime);
          boomOsc.stop(burstTime + 0.36);

          // Crackling sparkles
          final sparkleFreqs = [1568.0, 1975.5, 2349.3, 1760.0];
          for (var i = 0; i < sparkleFreqs.length; i++) {
            final spTime = burstTime + 0.05 + i * 0.06;
            final spOsc = ctx.createOscillator();
            final spGain = ctx.createGain();
            spOsc.type = 'sine';
            spOsc.frequency.setValueAtTime(sparkleFreqs[i], spTime);
            spGain.gain.setValueAtTime(0.18, spTime);
            spGain.gain.exponentialRampToValueAtTime(0.001, spTime + 0.18);
            spOsc.connect(spGain);
            spGain.connect(ctx.destination);
            spOsc.start(spTime);
            spOsc.stop(spTime + 0.19);
          }
          break;

        case 'magic_chime':
          // Sweeping 7-note celestial harp glissando
          final harpNotes = [523.25, 659.25, 783.99, 987.77, 1046.50, 1318.51, 1567.98];
          for (var i = 0; i < harpNotes.length; i++) {
            final noteTime = t + i * 0.06;
            final osc = ctx.createOscillator();
            final gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(harpNotes[i], noteTime);
            gain.gain.setValueAtTime(0.22, noteTime);
            gain.gain.exponentialRampToValueAtTime(0.001, noteTime + 0.38);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(noteTime);
            osc.stop(noteTime + 0.39);
          }
          break;

        case 'cheer':
          // Joyous multi-chord fanfare
          final cheerChords = [
            [523.25, 659.25, 783.99], // C major
            [587.33, 698.46, 880.00], // F/D
            [659.25, 783.99, 1046.5], // G/C
            [783.99, 987.77, 1318.5], // Top triumph
          ];
          for (var c = 0; c < cheerChords.length; c++) {
            final chordTime = t + c * 0.14;
            for (final f in cheerChords[c]) {
              final osc = ctx.createOscillator();
              final gain = ctx.createGain();
              osc.type = 'triangle';
              osc.frequency.setValueAtTime(f, chordTime);
              gain.gain.setValueAtTime(0.18, chordTime);
              gain.gain.exponentialRampToValueAtTime(0.001, chordTime + 0.40);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(chordTime);
              osc.stop(chordTime + 0.41);
            }
          }
          break;

        case 'sparkle':
          // Fairy dust chime
          final spk = [1760.0, 2093.0, 2637.0, 3136.0];
          for (var i = 0; i < spk.length; i++) {
            final noteTime = t + i * 0.05;
            final osc = ctx.createOscillator();
            final gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(spk[i], noteTime);
            gain.gain.setValueAtTime(0.2, noteTime);
            gain.gain.exponentialRampToValueAtTime(0.001, noteTime + 0.25);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(noteTime);
            osc.stop(noteTime + 0.26);
          }
          break;
      }
    } catch (_) {}
  }
}

AssetAudioPlayer createPlatformAssetAudioPlayer() => AssetAudioPlayerWeb();
