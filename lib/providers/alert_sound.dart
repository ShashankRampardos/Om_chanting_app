import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:om/models/sound.dart';

class AlertSound extends StateNotifier<Sound?> {
  AlertSound() : super(null);

  void setSound(Sound sound) {
    state = sound;
  }

  Sound? getSound() {
    return state;
  }
}

final alertSoundNotifierProvider = StateNotifierProvider<AlertSound, Sound?>((
  ref,
) {
  return AlertSound();
});
