abstract class TtsPlatform {
  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
  void dispose();
  String getEngineStatus();
  Future<void> setVoiceGender(String gender);
}
