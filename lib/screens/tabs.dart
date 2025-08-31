import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:om/core/om_detection_controller.dart';
import 'package:om/providers/bg_sound.dart';
//import 'package:om/providers/omDetectionController.dart';
import 'package:om/providers/player.dart';
import 'package:om/screens/meditation_timer.dart';
import 'package:om/screens/om_counting.dart';
import 'package:om/screens/settings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  bool _isBgPlaying = false;
  Widget _body = OmApp();
  int currentIndex = 0;

  void _openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,

        barrierColor: const Color.fromARGB(
          129,
          0,
          0,
          0,
        ).withAlpha(150), // optional background dim
        pageBuilder: (_, __, ___) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final omCtrl = ref.watch(omDetectionControllerProvider.notifier);
    // final omState = ref.watch(omDetectionControllerProvider);

    final sound = ref.watch(backgroundSoundNotifierProvider);
    final playerInfo = ref.watch(soundPlayerProvider.notifier);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_images/background1.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(child: _body),
          ],
        ),
        appBar: AppBar(
          centerTitle: false,
          title: Text('Chanting'),
          actions: [
            IconButton(
              onPressed: () {
                if (sound != null && !_isBgPlaying) {
                  playerInfo.setPlayer('background sound');
                  playerInfo.play(sound.localPreviewPath, sound.id);
                  setState(() {
                    _isBgPlaying = true;
                  });
                } else {
                  //playerInfo.stop(sound.id);
                  print(playerInfo.getPlayerInfo());
                  print(
                    'baba baba black sheep, humpty dumpty setp on the wall',
                  );
                  print(_isBgPlaying);
                  print(sound == null);
                  if (sound != null) {
                    playerInfo.stop(sound.id);
                    playerInfo.setPlayer(null);
                    setState(() {
                      _isBgPlaying = false;
                    });
                  }
                }
              },
              icon: (!_isBgPlaying)
                  ? Icon(Icons.music_off_rounded)
                  : Icon(Icons.music_note_rounded),
            ),
            IconButton(
              onPressed: () {
                _openSettings();
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        //body: OmApp(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
              if (index == 0) {
                if (ref.read(soundPlayerProvider.notifier).isPlaying()) {
                  ref.read(soundPlayerProvider.notifier).stop(null);
                }
                _body = const OmApp();
              } else if (index == 1) {
                if (ref.read(soundPlayerProvider.notifier).isPlaying()) {
                  ref.read(soundPlayerProvider.notifier).stop(null);
                }
                _body =
                    const MeditationApp(); // Replace with your Silent meditation widget
              }
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.om),
              label: 'Chanting',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.light_mode_rounded),
              label: 'Silent meditation',
            ),
          ],
        ),
      ),
    );
  }
}
