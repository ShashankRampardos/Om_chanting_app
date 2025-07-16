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
        appBar: AppBar(
          centerTitle: true,
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
        body: OmApp(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {},
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dining_sharp),
              label: 'Categories',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          ],
        ),
      ),
    );
  }
}
