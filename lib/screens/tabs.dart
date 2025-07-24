import 'package:flutter/material.dart';
import 'package:om/screens/om_counting.dart';
import 'package:om/screens/settings.dart';

class TabsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  void _openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withAlpha(150), // optional background dim
        pageBuilder: (_, __, ___) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_images/background1.jpg', // Replace with your image path
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
              icon: Icon(Icons.leaderboard),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered_rtl_sharp),
              label: 'Leadboard',
            ),
          ],
        ),
      ),
    );
  }
}
