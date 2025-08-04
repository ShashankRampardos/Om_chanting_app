import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:om/models/sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SoundPickerScreen extends StatefulWidget {
  const SoundPickerScreen({super.key, required this.title});

  final String title;

  @override
  State<SoundPickerScreen> createState() => _SoundPickerScreenState();
}

class _SoundPickerScreenState extends State<SoundPickerScreen> {
  final String _apiKey = 'pWSR0sapWqgLcZcAkTj1OdCmFjlwdBjJOXMn5c2O';
  final List<Sound> _sounds = [];
  bool isLoading = true;

  Future<void> callApiAndFetchSounds() async {
    final String url =
        'https://freesound.org/apiv2/search/text/?query=nature calm relax&fields=id,name,previews,download&sort=rating_desc&page_size=40';
    final data = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Token $_apiKey'},
    );
    final Map<String, dynamic> jsonData = json.decode(data.body);
    final List<dynamic> result = jsonData['results'];
    setState(() {
      _sounds.clear();
      for (final val in result) {
        _sounds.add(Sound.fromJson(val));
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _downloadSound(Sound s) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final previewPath = '${dir.path}/${s.name}_preview.mp3';
      final fullPath = '${dir.path}/${s.name}_full.mp3';

      // Download preview
      final previewRes = await http.get(Uri.parse(s.previewUrl));
      if (previewRes.statusCode == 200) {
        final file = File(previewPath);
        await file.writeAsBytes(previewRes.bodyBytes);
      }

      // Download full
      final fullRes = await http.get(Uri.parse(s.downloadLink));
      if (fullRes.statusCode == 200) {
        final file = File(fullPath);
        await file.writeAsBytes(fullRes.bodyBytes);
      }

      //print('Download complete to: $dir');
    } catch (e) {
      return print(Exception(e)); //print('Download failed: $e');
    }
  }

  Future<bool> _fileExists(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';
    return File(filePath).exists();
  }

  bool _playingSound(Sound sound) {
    //play return true when playing and false when stopped
    return true;
  }

  @override
  void initState() {
    super.initState();
    callApiAndFetchSounds();
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
        body: isLoading
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
                    for (final sound in _sounds)
                      SoundCard(
                        sound: sound,
                        download: _downloadSound,
                        isDownloaded: _fileExists,
                        playing: _playingSound,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class SoundCard extends StatefulWidget {
  const SoundCard({
    super.key,
    required this.sound,
    required this.download,
    required this.isDownloaded,
    required this.playing,
  });
  final Sound sound;
  final Future<void> Function(Sound) download;
  final Future<bool> Function(String) isDownloaded;
  final bool Function(Sound) playing;

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> {
  bool alreadyExists = false;
  bool isPlaying = false;
  @override
  void initState() {
    //because of this we have to make this class as stateful
    _setAlreadyExist();
    super.initState();
  }

  void _setAlreadyExist() async {
    final exists = await widget.isDownloaded('${widget.sound.name}_full.mp3');
    setState(() {
      alreadyExists = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: IconButton(
                  onPressed: alreadyExists
                      ? () {
                          setState(() {
                            isPlaying = widget.playing(widget.sound);
                          });
                        }
                      : () async {
                          await widget.download(widget.sound);
                          setState(() {
                            alreadyExists = true;
                          });
                        },
                  icon: Icon(
                    alreadyExists
                        ? (isPlaying ? Icons.stop : Icons.play_arrow)
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
