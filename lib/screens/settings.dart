import 'package:flutter/material.dart';
import 'package:om/core/om_detection_controller.dart';
import 'package:om/screens/sound_picker.dart';
import 'package:om/widgets/settings_widgets/target_bottom_sheet.dart';
import 'package:om/widgets/settings_widgets/text_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double? _alert_volume = 0.5;
  double? _background_volume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSoundLevel();
  }

  void _targetBottomSheet(BuildContext context) {
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

  Future<void> _loadSoundLevel() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
      _alert_volume = pref.getDouble('alert_volume_level') ?? 0.5;
      _background_volume = pref.getDouble('background_volume_level') ?? 0.5;
    });
  }

  Future<void> _saveAlertSoundLevel(double volume) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble('alert_volume_level', volume);
  }

  Future<void> _saveBackgroundSoundLevel(double volume) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble('background_volume_level', volume);
  }

  void _showBackgroundVolumeSlider() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx1, setLevelState) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              //Wrap the Slider with a Column
              child: Column(
                //Set mainAxisSize to min to make the column shrink-wrap its content
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    min: 0.0,
                    max: 1.0,
                    value: _background_volume!,
                    onChanged: (newVolume) {
                      setLevelState(() {
                        _background_volume = newVolume;
                      });
                      _saveBackgroundSoundLevel(newVolume);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAlertVolumeSlider() {
    //the AlertDialog widget is not the part of the main widget tree its seperate, and for this reason we uses StatufulBuilder widget its a kind of seperate space of widget tree and its stateful alwell
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx1, setLevelState) {
          return Align(
            alignment: Alignment.topCenter,
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      min: 0.0,
                      max: 1.0,
                      value: _alert_volume!,
                      onChanged: (newVolume) {
                        setLevelState(() {
                          _alert_volume = newVolume;
                        });
                        _saveAlertSoundLevel(newVolume);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _caliberateSound(BuildContext context) {
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
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          title: Text(
            'Settings',
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onSecondaryFixedVariant,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: ListView(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextTile(
                text: 'Target set',
                icon: Icons.flag,
                executeSetting: () {
                  _targetBottomSheet(context);
                },
              ),
              TextTile(
                text: 'Volume of alert sound',
                icon: Icons.notifications,
                executeSetting: () {
                  _showAlertVolumeSlider();
                },
              ),
              TextTile(
                text: 'Volume of background sound',
                icon: Icons.graphic_eq,
                executeSetting: () {
                  _showBackgroundVolumeSlider();
                },
              ),
              TextTile(
                text: 'Set background sound',
                icon: Icons.library_music,
                executeSetting: () {},
              ),
              TextTile(
                text: 'Set alert sound',
                icon: Icons.alarm,
                executeSetting: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const SoundPickerScreen(title: 'alert sound'),
                    ),
                  );
                },
              ),
              TextTile(
                text: 'Caliberate with background noise',
                icon: Icons.hearing,
                executeSetting: () {
                  _caliberateSound(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
