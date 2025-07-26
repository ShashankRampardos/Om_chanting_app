import 'package:flutter/material.dart';
import 'package:om/core/om_detection_controller.dart';
import 'package:om/widgets/settings_widgets/target_bottom_sheet.dart';
import 'package:om/widgets/settings_widgets/text_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void targetBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInBottomSheet) {
            return TargetBottomSheet();
          },
        );
      },
    );
  }

  void caliberateSound(BuildContext context) {
    final controller = OmDetectionController();
    bool isDone = false;
    bool isCalibrated = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx1, setButtonState) {
          return AlertDialog(
            title: Text('Caliberate'),
            content: Text(
              'caliberate with the background white noise like fan, wind,etc.',
            ),
            actions: [
              if (!isDone)
                ElevatedButton(
                  onPressed: isCalibrated
                      ? null
                      : () async {
                          setButtonState(() {
                            isCalibrated = true;
                          });
                          controller.calibrateWithBackgroundNoise();
                          await Future.delayed(Duration(seconds: 3));
                          setButtonState(() {
                            isDone = true;
                          });
                        },
                  child: Text('caliberate'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx1).pop();
                  },
                  child: Text('Done!'),
                ),
            ],
          );
        },
      ),
    );
  }

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
                  caliberateSound(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
