import 'dart:async';
import 'dart:typed_data';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';
import 'package:om/om_bindings.dart';

bool kDebugMode = true;

/// Load C++ library and bind
final dylib = Platform.isAndroid
    ? DynamicLibrary.open("libom.so")
    : DynamicLibrary.process();
final omBindings = OmBindings(dylib);

class OmDetectionController {
  OmDetectionController._();
  static final OmDetectionController _instance = OmDetectionController._();
  factory OmDetectionController() => _instance;

  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  static const MethodChannel _channel = MethodChannel('native_audio');

  bool isRecording = false;
  double? peakFrequency;
  double? peakMagnitude;
  int omCount = 0;
  bool _verdict = false;
  int _sampleRate = 44100;

  void Function(void Function())? _refreshUi;

  Future<void> start(void Function(void Function()) refreshUi) async {
    _refreshUi = refreshUi;
    await _audioCapture.init();
    try {
      final rate = await _channel.invokeMethod<int>('getSampleRate');
      if (rate != null) _sampleRate = rate;
      if (kDebugMode) print('SampleRate: $_sampleRate');
    } on PlatformException {
      if (kDebugMode) print('Defaulting to 44100');
    }

    if (!await Permission.microphone.request().isGranted) {
      if (kDebugMode) print('Mic denied');
      return;
    }

    await _audioCapture.start(
      (obj) => _listener(obj),
      _onError,
      sampleRate: _sampleRate,
      bufferSize: 2048,
    );
    isRecording = true;
    refreshUi(() {});
  }

  void stop(void Function(void Function()) refreshUi) {
    _audioCapture.stop();
    isRecording = false;
    refreshUi(() {});
  }

  void resetCount(void Function(void Function()) refreshUi) {
    refreshUi(() {
      omCount = 0;
    });
  }

  void _listener(dynamic obj) {
    final Float32List buffer = Float32List.fromList(List<double>.from(obj));
    final Pointer<Float> samplePtr = malloc.allocate<Float>(
      buffer.length * sizeOf<Float>(),
    );
    for (int i = 0; i < buffer.length; i++) {
      samplePtr[i] = buffer[i];
    }

    final Pointer<Double> freqPtr = malloc.allocate<Double>(sizeOf<Double>());
    final Pointer<Double> magPtr = malloc.allocate<Double>(sizeOf<Double>());

    final int detected = omBindings.detect_om(
      samplePtr,
      buffer.length,
      freqPtr,
      magPtr,
    );
    final double freq = freqPtr.value;
    final double mag = magPtr.value;

    malloc.free(samplePtr);
    malloc.free(freqPtr);
    malloc.free(magPtr);

    peakFrequency = freq;
    peakMagnitude = mag;

    if (detected == 1) {
      if (!_verdict) {
        omCount++;
        _verdict = true;
      }
    } else {
      _verdict = false;
    }

    if (kDebugMode) {
      print('[OM Detected: $detected] $freq Hz | $mag');
    }

    _refreshUi?.call(() {});
  }

  void _onError(Object e) {
    if (kDebugMode) print('Audio Error: $e');
  }
}
