import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:om/providers/bg_sound.dart';
import 'package:om/providers/player.dart';
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
            OmApp(),
          ],
        ),
        appBar: AppBar(
          centerTitle: false,
          title: Text('Chanting'),
          actions: [
            IconButton(
              onPressed: () {
                if (sound != null) {
                  if (playerInfo.getPlayerInfo() == 'no player' ||
                      playerInfo.getPlayerInfo() == 'alert sound') {
                    playerInfo.setPlayer('background sound');
                    playerInfo.play(sound.localPreviewPath, sound.id);
                  } else {
                    //playerInfo.stop(sound.id);
                    print(playerInfo.getPlayerInfo());
                    print(
                      'baba baba black sheep, humpty dumpty setp on the wall',
                    );
                  }
                }
              },
              icon:
                  (playerInfo.getPlayerInfo() == 'no player' ||
                      playerInfo.getPlayerInfo() == 'alert sound' ||
                      sound == null)
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
          currentIndex: 1,
          onTap: (index) {},
          items: const [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.om),
              label: 'Chanting',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.spa),
              label: 'Silent meditation',
            ),
          ],
        ),
      ),
    );
  }
}
