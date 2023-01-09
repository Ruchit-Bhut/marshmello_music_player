import 'package:audio_service/audio_service.dart';

Future<AudioHandler> initAudioService() async {
  return  AudioService.init(
    builder: MyAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}
class MyAudioHandler extends BaseAudioHandler {
  // TODO: Override needed methods
  // final _player = AudioPlayer();
  // final _playlist = ConcatenatingAudioSource(children: []);
  //
  // MyAudioHandler() {
  //   _loadEmptyPlaylist();
  // }
  // Future<void> _loadEmptyPlaylist() async {
  //   try {
  //     await _player.setAudioSource(_playlist);
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }
}