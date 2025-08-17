import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:om/models/sound.dart';
import 'package:path_provider/path_provider.dart';

class SoundsDownloadsState extends StateNotifier<Map<int, bool>> {
  SoundsDownloadsState() : super({});
  final String _apiKey = 'pWSR0sapWqgLcZcAkTj1OdCmFjlwdBjJOXMn5c2O';

  void initSounds(List<Sound> sounds) {
    final currentMap = {...state};
    for (final sound in sounds) {
      currentMap[sound.id] = currentMap[sound.id] ?? false;
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
            .get(Uri.parse(url), headers: {'Authorization': 'Token $_apiKey'})
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

  Future<void> _downloadPreview(Sound s, String previewPath) async {
    // Download preview
    http.Response? previewRes;
    try {
      previewRes = await http
          .get(
            Uri.parse(s.previewUrl),
            headers: {'Authorization': 'Token $_apiKey'},
          )
          .timeout(Duration(seconds: 10));

      print('${previewRes.statusCode} ${s.previewUrl}');
    } on TimeoutException {
      try {
        final res = await _retryDownload(s.previewUrl);
        if (res != null) {
          //null ha tho ignore do nothing
          previewRes = res;
        }
      } catch (e, st) {
        print('Error during retry: $e');
        print('stackTrace: $st');
      }
    }

    try {
      if (previewRes != null && previewRes.statusCode == 200) {
        final file = File(previewPath);
        await file.writeAsBytes(previewRes.bodyBytes);
        state = {...state, s.id: true};
        print('downloaded to path: $previewPath');
      }
    } catch (e, st) {
      print('error during preview download $e');
      print('stackTrace: $st');
    }
  }

  Future<void> downloadSound(Sound s) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String safeName = _sanitizeFileName(s.name);
      final previewPath =
          '${dir.path}/$safeName.mp3'; //do i need to write .mp3 to store the file after the file name
      //final fullPath = '${dir.path}/${safeName}_full.mp3';

      //download preview sound first
      await _downloadPreview(s, previewPath);
      // Download full, this one is tough and code bulkey
      // await _downloadFull(s, fullPath);
      //print('Download complete to: $dir');
    } catch (e, st) {
      print('error during Download: $e');
      print('stackTrace: $st');
    }
  }
}

final soundsDownloadsStateProvider =
    StateNotifierProvider<SoundsDownloadsState, Map<int, bool>>(
      (ref) => SoundsDownloadsState(),
    );

//REDUNDAND OLD CODE

//download full requireing the Oauth2 authentication which is making the UX bad so i am skipping it.

  // Future<void> _downloadFull(Sound s, String fullPath) async {
  //   http.Response? fullRes;
  //   try {
  //     //final downloadUrl = '${s.downloadLink}?token=$_apiKey';
  //     final fullRes = await http
  //         .get(
  //           Uri.parse(s.downloadLink),
  //           // headers: {'Authorization': 'Token $_apiKey'},
  //           headers: {'Authorization': 'Bearer $accessToken'}
  //         )
  //         .timeout(Duration(seconds: 10));
  //     //print('after timeout: $downloadUrl');
  //     if (fullRes.statusCode != 200) {
  //       print(
  //         'suspected here -> Download failed with status code: ${fullRes.statusCode}',
  //       );
  //       throw TimeoutException('Request timed out');
  //     }
  //   } on TimeoutException {
  //     try {
  //       final res = await _retryDownload(s.downloadLink);
  //       if (res != null) {
  //         fullRes = res;
  //       }
  //     } catch (e) {
  //       throw Exception(e); //propogating to caller
  //     }
  //   }
  //   if (fullRes != null && fullRes.statusCode == 200) {
  //     print('enter for saving');
  //     final file = File(fullPath);
  //     print('enter for saving2');
  //     await file.writeAsBytes(fullRes.bodyBytes);
  //     print('enter for saving3');
  //     state = {...state, s.name: true};
  //     s.localFullPath = fullPath;
  //   }
  // }
