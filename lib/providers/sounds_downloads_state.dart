import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:om/models/sound.dart';
import 'package:path_provider/path_provider.dart';

class SoundsDownloadsState extends StateNotifier<Map<String, bool>> {
  SoundsDownloadsState() : super({});

  void initSounds(List<Sound> sounds) {
    final currentMap = {...state};
    for (final sound in sounds) {
      currentMap[sound.name] = currentMap[sound.name] ?? false;
    }
    state = currentMap;
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
  }

  Future<http.Response?> _retryDownload(String url) async {
    for (int i = 0; i < 3; i++) {
      try {
        final res = await http
            .get(Uri.parse(url))
            .timeout(Duration(seconds: 10));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return res;
        } //try again in next iteration
      } on TimeoutException {
        //wati for one second
        await Future.delayed(Duration(seconds: 1));
      } catch (e) {
        throw Exception("Unexpected error: $e");
      }
    }
    return null;
  }

  Future<void> downloadSound(Sound s) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String safeName = _sanitizeFileName(s.name);
      final previewPath = '${dir.path}/${safeName}_preview.mp3';
      final fullPath = '${dir.path}/${safeName}_full.mp3';

      // Download preview
      http.Response? previewRes;
      try {
        previewRes = await http
            .get(Uri.parse(s.previewUrl))
            .timeout(Duration(seconds: 10));
      } on TimeoutException {
        try {
          final res = await _retryDownload(s.previewUrl);
          if (res != null) {
            //null ha tho ignore do nothing
            previewRes = res;
          }
        } catch (e) {
          //do nothing ignore
        }
      }
      if (previewRes != null && previewRes.statusCode == 200) {
        final file = File(previewPath);
        await file.writeAsBytes(previewRes.bodyBytes);
        state = {...state, s.name: true};
        s.localPreviewPath = previewPath;
      }

      // Download full
      http.Response? fullRes;
      try {
        fullRes = await http
            .get(Uri.parse(s.downloadLink))
            .timeout(Duration(seconds: 120));
      } on TimeoutException {
        try {
          final res = await _retryDownload(s.downloadLink);
          if (res != null) {
            fullRes = res;
          }
        } catch (e) {
          //do nothing ignore
        }
      }
      if (fullRes != null && fullRes.statusCode == 200) {
        final file = File(fullPath);
        await file.writeAsBytes(fullRes.bodyBytes);
        //state = {...state, s.name: true};
        s.localFullPath = fullPath;
      }
      //print('Download complete to: $dir');
    } catch (e) {
      throw Exception(e); //print('Download failed: $e');
    }
  }
}

final soundsDownloadsStateProvider =
    StateNotifierProvider<SoundsDownloadsState, Map<String, bool>>(
      (ref) => SoundsDownloadsState(),
    );
