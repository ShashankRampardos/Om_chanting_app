import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:scidart/scidart.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void targetBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInBottomSheet) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      'Set your target chanting',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.black),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 53,
                    width: 150,
                    child: NumberInputWithIncrementDecrement(
                      controller: TextEditingController(),
                      min: 0,
                      max: 1000,
                      incDecFactor: 1,
                      initialValue: 11,
                      numberFieldDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'cancel',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'set',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void calibrateSound() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextTile(
                text: 'Target set',
                icon: Icons.flag,
                executeSetting: () {
                  targetBottomSheet(context);
                },
              ),
              TextTile(
                text: 'Volume of alert sound',
                icon: Icons.notifications,
                executeSetting: () {},
              ),
              TextTile(
                text: 'Volume of background sound',
                icon: Icons.graphic_eq,
                executeSetting: () {},
              ),
              TextTile(
                text: 'Set background sound',
                icon: Icons.library_music,
                executeSetting: () {},
              ),
              TextTile(
                text: 'Set alert sound',
                icon: Icons.alarm,
                executeSetting: () {},
              ),
              TextTile(
                text: 'Caliberate with background noise',
                icon: Icons.hearing,
                executeSetting: () {
                  //calibratenSound();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextTile extends StatelessWidget {
  const TextTile({
    super.key,
    required this.text,
    required this.icon,
    required this.executeSetting,
  });
  final String text;
  final IconData icon;
  final void Function() executeSetting;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: executeSetting,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: Divider(
              color: Theme.of(context).colorScheme.onSurface,
              thickness: 1,
              indent: 1,
              endIndent: 1,
            ),
          ),
        ],
      ),
    );
  }
}
