class Sound {
  final int id;
  final String name;
  final String previewUrl;
  final String downloadLink;
  String? localFullPath;
  String? localPreviewPath;

  Sound({
    required this.id,
    required this.name,
    required this.previewUrl,
    required this.downloadLink,
    this.localFullPath,
    this.localPreviewPath,
  });

  // Factory constructor to create a Sound instance from JSON
  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      id: json['id'] as int,
      name: json['name'] as String,
      // The preview URL is nested inside the 'previews' object
      previewUrl: json['previews']['preview-hq-mp3'] as String,
      downloadLink: json['download'],
    );
  }
}
