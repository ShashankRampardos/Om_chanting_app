import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Sound {
  final int id;
  final String name;
  final String previewUrl;
  final String downloadLink;
  final String localFullPath;
  final String localPreviewPath;

  const Sound({
    required this.id,
    required this.name,
    required this.previewUrl,
    required this.downloadLink,
    required this.localFullPath,
    required this.localPreviewPath,
  });

  // Factory constructor to create a Sound instance from JSON
  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      id: json['id'] as int,
      name: json['name'] as String,
      //the preview url is nest inside 'previews' object
      previewUrl: json['previews']['preview-hq-mp3'] as String,
      downloadLink: json['download'] as String,
      localPreviewPath: '',
      localFullPath: '',
    );
  }

  // async wala
  static Future<Sound?> fromJsonWithPaths(Map<String, dynamic> json) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String safeName = json['name']
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final previewPath = '${dir.path}/$safeName.mp3';

      return Sound(
        id: json['id'] as int,
        name: json['name'] as String,
        previewUrl: json['previews']['preview-hq-mp3'] as String,
        downloadLink: json['download'] as String,
        localFullPath: previewPath,
        localPreviewPath: previewPath,
      );
    } catch (e, st) {
      debugPrint('error in Sound.fromJsonWithPaths: $e');
      debugPrint('stackTrace: $st');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'previews': {
        //this is to match with the fromJson format
        'preview-hq-mp3': previewUrl,
      },
      'download': downloadLink,
      'localFullPath': localFullPath,
      'localPreviewPath': localPreviewPath,
    };
  }
}
