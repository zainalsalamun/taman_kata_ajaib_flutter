import 'package:flutter/services.dart' show MethodChannel, SystemSound, SystemSoundType;
import 'asset_audio_player.dart';

class AssetAudioPlayerIo implements AssetAudioPlayer {
  static const MethodChannel _channel = MethodChannel('com.tamankata.app/audio');
  bool _isBgmPlaying = false;

  @override
  bool get isBgmPlaying => _isBgmPlaying;

  @override
  Future<bool> play(String assetPath) async {
    try {
      final res = await _channel.invokeMethod<bool>('playAsset', {'path': assetPath});
      return res ?? false;
    } catch (_) {
      return false; // Fallback to TTS on IO if file is missing
    }
  }

  @override
  void stop() {
    stopBgm();
  }

  @override
  void playProceduralSfx(String sfxType) {
    try {
      _channel.invokeMethod('playSfx', {'type': sfxType}).catchError((_) {
        // Fallback to platform clicks
        if (sfxType == 'ding' || sfxType == 'star' || sfxType == 'fanfare') {
          SystemSound.play(SystemSoundType.alert);
        } else {
          SystemSound.play(SystemSoundType.click);
        }
      });
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  @override
  void startBgm() {
    _isBgmPlaying = true;
    try {
      _channel.invokeMethod('startBgm').catchError((_) {});
    } catch (_) {}
  }

  @override
  void stopBgm() {
    _isBgmPlaying = false;
    try {
      _channel.invokeMethod('stopBgm').catchError((_) {});
    } catch (_) {}
  }
}

AssetAudioPlayer createPlatformAssetAudioPlayer() => AssetAudioPlayerIo();

