import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:om/models/sound.dart';
import 'package:om/providers/player.dart';
import 'package:om/providers/sounds_downloads_state.dart';

class SoundPickerScreen extends ConsumerStatefulWidget {
  const SoundPickerScreen({super.key, required this.title});

  final String title;

  @override
  ConsumerState<SoundPickerScreen> createState() => _SoundPickerScreenState();
}

class _SoundPickerScreenState extends ConsumerState<SoundPickerScreen> {
  final String _apiKey = 'pWSR0sapWqgLcZcAkTj1OdCmFjlwdBjJOXMn5c2O';
  final List<Sound> _sounds = [];
  bool isLoading = true;
  bool _isConnectionLost = false;

  Future<void> _callApiAndFetchSounds() async {
    final String url =
        'https://freesound.org/apiv2/search/text/?query=nature,calm,relax&fields=id,name,previews,download&sort=rating_desc&page_size=100';

    try {
      final data = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Token $_apiKey'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('10 seconds say pahle he fat gaya');
              throw TimeoutException('Request timed out');
            },
          );
      //print(data.body);
      if (data.statusCode != 200) {
        print('fat gaya logic');
        throw TimeoutException('Request timed out');
      }
      final Map<String, dynamic> jsonData = json.decode(data.body);
      final List<dynamic> result = jsonData['results'];
      for (final val in result) {
        final sound = await Sound.fromJsonWithPaths(
          val,
        ); //exception handling return null if file path not found
        if (sound != null) {
          _sounds.add(sound);
        }
      }

      setState(() {
        isLoading = false;
      });

      // registering all sounds in the provider
      ref.read(soundsDownloadsStateProvider.notifier).initSounds(_sounds);
      ref.read(soundPlayerProvider.notifier).initSounds(_sounds);
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isConnectionLost = true;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      _callApiAndFetchSounds();
    } catch (e, st) {
      debugPrint('error on calling sound api or fetching sounds: $e');
      debugPrint('stackTrace: $st');
    }
    //sound provider may konsa player use karna ha vo
    ref.read(soundPlayerProvider.notifier).setPlayer(widget.title);
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
            widget.title,
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onSecondaryFixedVariant,
        ),
        body: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              ref.read(soundPlayerProvider.notifier).stop(null);
            }
          },
          child: _isConnectionLost
              ? Center(
                  child: Text(
                    'Connection lost. Please try again later.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : isLoading
              ? Center(
                  child: SizedBox(
                    height: 160,
                    width: 160,
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: ListView(
                    children: [
                      for (final sound in _sounds) SoundCard(sound: sound),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class SoundCard extends ConsumerStatefulWidget {
  const SoundCard({super.key, required this.sound});
  final Sound sound;
  //bool isPlaying = false;
  @override
  ConsumerState<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends ConsumerState<SoundCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(soundPlayerProvider)[widget.sound.id];
    final SoundPlayerNotifier = ref.watch(soundPlayerProvider.notifier);
    if (isPlaying == null) {
      throw Exception('yahi ha vo');
    }
    final isDownloaded =
        ref.watch(soundsDownloadsStateProvider)[widget.sound.id] ??
        false; //null ha tho false assign
    final downloadNotifier = ref.watch(soundsDownloadsStateProvider.notifier);

    return InkWell(
      onTap: () {
        if (isDownloaded) {
          //downloaded kare bina pop kia tho gadbad
          SoundPlayerNotifier.stop(widget.sound.id);
          Navigator.of(context).pop(widget.sound);
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(
                    widget.sound.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: isLoading
                    ? CircularProgressIndicator()
                    : IconButton(
                        onPressed: isDownloaded
                            ? (isPlaying
                                  ? () {
                                      SoundPlayerNotifier.stop(widget.sound.id);
                                    }
                                  : () {
                                      SoundPlayerNotifier.play(
                                        widget.sound.localPreviewPath,
                                        widget.sound.id,
                                      );
                                    })
                            : () async {
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await downloadNotifier.downloadSound(
                                    widget.sound,
                                  );
                                } catch (e, stackTrace) {
                                  print('full Download failed: $e');
                                  print('trace: $stackTrace');
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                        icon: Icon(
                          isDownloaded
                              ? (isPlaying!
                                    ? Icons.stop
                                    : Icons
                                          .play_arrow) //badme replace kardunga false ko correct logic say
                              : Icons.download,
                        ),
                      ),
              ),
            ],
          ),
          Opacity(opacity: 0.8, child: Divider()),
        ],
      ),
    );
  }
}
