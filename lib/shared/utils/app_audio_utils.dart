import 'package:just_audio/just_audio.dart';

abstract class AppAudioUtils {
  static Future<void> playAndDisposeAudio(String sourcePath) async {
    final AudioPlayer player = AudioPlayer();
    try {
      player.playerStateStream.listen((state) async {
        if (state.processingState == ProcessingState.completed) {
          await player.dispose();
        }
      });
      if (sourcePath.startsWith('http://') ||
          sourcePath.startsWith('https://')) {
        await player.setUrl(sourcePath);
      } else if (sourcePath.startsWith('assets/')) {
        await player.setAsset(sourcePath);
      } else {
        await player.setFilePath(sourcePath);
      }
      await player.play();
    } catch (e) {
      await player.dispose();
    }
  }
}
