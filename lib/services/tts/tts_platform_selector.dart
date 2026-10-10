import 'tts_platform.dart';
import 'tts_platform_web.dart'
    if (dart.library.io) 'tts_platform_io.dart';

TtsPlatform createPlatformTts() => createTtsPlatform();
