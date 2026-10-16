abstract class AssetAudioPlayer {
  Future<bool> play(String assetPath);
  void stop();
  void playProceduralSfx(String sfxType);
  void startBgm();
  void stopBgm();
  bool get isBgmPlaying;
}

