import 'asset_audio_player.dart';
import 'asset_audio_player_web.dart'
    if (dart.library.io) 'asset_audio_player_io.dart';

AssetAudioPlayer createAssetAudioPlayer() => createPlatformAssetAudioPlayer();
