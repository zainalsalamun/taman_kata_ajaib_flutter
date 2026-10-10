abstract class AssetAudioPlayer {
  Future<bool> play(String assetPath);
  void stop();
  void playProceduralSfx(String sfxType);
}
