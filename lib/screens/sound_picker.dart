import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:om/models/sound.dart';
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
        'https://freesound.org/apiv2/search/text/?query=nature calm relax&fields=id,name,previews,download&sort=rating_desc&page_size=40';

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

      if (data.statusCode != 200) {
        print('fat gaya logic');
        throw TimeoutException('Request timed out');
      }

      final Map<String, dynamic> jsonData = json.decode(data.body);
      final List<dynamic> result = jsonData['results'];
      setState(() {
        _sounds.clear();
        for (final val in result) {
          _sounds.add(Sound.fromJson(val));
        }
        isLoading = false;
      });
      //registering all sounds in the provider if not already registered
      ref.read(soundsDownloadsStateProvider.notifier).initSounds(_sounds);
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isConnectionLost = true;
        isLoading = false;
      });
    }
  }

  bool _playingSound(Sound sound) {
    final localPath = sound.localPreviewPath;
    //play return true when playing and false when stopped
    return false;
  }

  @override
  void initState() {
    super.initState();
    _callApiAndFetchSounds();
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
        body: _isConnectionLost
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
    final isDownloaded =
        ref.watch(soundsDownloadsStateProvider)[widget.sound.name] ??
        false; //null ha tho false assign
    final downloadNotifier = ref.watch(soundsDownloadsStateProvider.notifier);

    return InkWell(
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
                            ? () {
                                // setState(() {
                                //   isPlaying = widget.playing(widget.sound);
                                // });
                              }
                            : () async {
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await downloadNotifier.downloadSound(
                                    widget.sound,
                                  );
                                } catch (e) {
                                  print(e);
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                        icon: Icon(
                          isDownloaded
                              ? (false
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
      onTap: () {},
    );
  }
}
