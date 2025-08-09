import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class SoundPlayerState extends StateNotifier<String?> {
  SoundPlayerState() : super(null); // null = no file playing

  final player = AudioPlayer();

  Future<void> play(String filePath) async {
    await player.setFilePath(filePath);
    await player.play();
    state = filePath;
  }

  Future<void> stop() async {
    await player.stop();
    state = null;
  }
}

final soundPlayerProvider = StateNotifierProvider<SoundPlayerState, String?>(
  (ref) => SoundPlayerState(),
);
