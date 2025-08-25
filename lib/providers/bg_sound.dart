import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:om/models/sound.dart';

class BackgroundSound extends StateNotifier<Sound?> {
  BackgroundSound() : super(null);

  void setSound(Sound sound) {
    state = sound;
  }

  Sound? getSound() {
    return state;
  }
}

final backgroundSoundNotifierProvider =
    StateNotifierProvider<BackgroundSound, Sound?>((ref) {
      return BackgroundSound();
    });
