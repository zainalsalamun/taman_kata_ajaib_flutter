import 'package:flutter/services.dart' show rootBundle, SystemSound, SystemSoundType;
import 'asset_audio_player.dart';

class AssetAudioPlayerIo implements AssetAudioPlayer {
  @override
  Future<bool> play(String assetPath) async {
    return false; // Fallback to TTS on IO if no native player plugin is attached
  }

  @override
  void stop() {}

  @override
  void playProceduralSfx(String sfxType) {
    if (sfxType == 'ding' || sfxType == 'pop') {
      SystemSound.play(SystemSoundType.click);
    }
  }
}

AssetAudioPlayer createPlatformAssetAudioPlayer() => AssetAudioPlayerIo();
