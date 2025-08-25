import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:om/models/sound.dart';

class SoundPlayerState extends StateNotifier<Map<int, bool>> {
  SoundPlayerState() : super({}); // null = no file playing
  final alertPlayer = AudioPlayer();
  final backgroundPlayer = AudioPlayer();
  String? playerInfo;
  AudioPlayer? player;

  bool isPlaying() {
    if (player != null) {
      return player!.playing;
    } else {
      return false;
    }
  }

  void initSounds(List<Sound> sounds) {
    final currentMap = {...state};
    for (final sound in sounds) {
      currentMap[sound.id] = currentMap[sound.id] ?? false;
    }
    state = currentMap;
  }

  void setPlayer(String? mode) {
    if (mode == null) {
      player = alertPlayer;
      playerInfo = 'alert player';
    } else if (mode == 'alert sound') {
      player = alertPlayer;
      playerInfo = 'alert sound';
    } else if (mode == 'background sound') {
      player = backgroundPlayer;
      playerInfo = 'background sound';
    }
  }

  String getPlayerInfo() {
    return playerInfo ?? 'no player';
  }

  void setPlayerInfo(String info) {
    playerInfo = info;
  }

  void setVolume(double volume) {
    player!.setVolume(volume);
  }

  Future<void> play(String filePath, int soundId) async {
    try {
      if (player!.playing) {
        //stopping a sound if another sound is already playing
        await player!.stop();
        int activeId = 0;
        for (final entry in state.entries) {
          if (entry.value) {
            activeId = entry.key;
            break;
          }
        }
        state = {
          ...state,
          activeId: false,
        }; // mark previoius playing sound as stopped, i wanna play one sound at a time only
      }
      if (await File(filePath).exists()) {
        print('file path before setFilePath:$filePath');
        await player!.setFilePath(filePath);
        state = {...state, soundId: true}; // mark this sound as playing
        print('file path before playing:$filePath');
        await player!.play();
        state = {...state, soundId: false}; // mark this sound as not playing
        print('file path after playing:$filePath');
      } else {
        print('file does not exist at path: $filePath');
      }
    } catch (e, st) {
      print('error playing: $e');
      print('stackTrace: $st');
    }
  }

  Future<void> stop(int? soundId) async {
    //if we got null in the argument then we will just stop a sound that is playing or do nothing if no sound is playing
    //kind of method polymorphysm
    try {
      if (soundId == null) {
        if (player!.playing) {
          //stopping a sound if a sound is playing
          await player!.stop();
          int activeId = 0;
          for (final entry in state.entries) {
            if (entry.value) {
              activeId = entry.key;
              break;
            }
          }
          state = {
            ...state,
            activeId: false,
          }; // mark previoius playing sound as stopped, i wanna play one sound at a time only
        }
      } else {
        await player!.stop();
        state = {...state, soundId: false}; // mark this sound as not playing
      }
    } catch (e, st) {
      print('error stopping sound: $e');
      print('stackTrace: $st');
    } finally {
      state = {...state, soundId!: false};
    }
  }
}

final soundPlayerProvider =
    StateNotifierProvider<SoundPlayerState, Map<int, bool>>(
      (ref) => SoundPlayerState(),
    );
