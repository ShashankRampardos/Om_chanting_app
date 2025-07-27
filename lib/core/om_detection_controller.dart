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

// dart:ffi typedefs............

typedef SetThreshNative = Void Function(Double);
typedef GetMagnitudeThreshold = Double Function();
typedef Calibration = Void Function();
typedef ResetOmState = Void Function();
typedef OmDetectionNative = Bool Function(Pointer<Float>, Int32);
typedef GetRawFrequency = Double Function();
typedef GetRawMagnitude = Double Function();

final DynamicLibrary dylib = () {
  if (Platform.isAndroid) return DynamicLibrary.open('libom.so');
  if (Platform.isIOS) return DynamicLibrary.process();
  if (Platform.isLinux) return DynamicLibrary.open('libom.so');
  if (Platform.isMacOS) return DynamicLibrary.open('libom.dylib');
  if (Platform.isWindows) return DynamicLibrary.open('om.dll');
  throw UnsupportedError('Unsupported platform');
}();

//these are like <nativeDeclaration,dartDeclaration>('native_function_name');
final omDetection = dylib
    .lookupFunction<OmDetectionNative, bool Function(Pointer<Float>, int)>(
      'detect_om',
    );

final calibrate = dylib.lookupFunction<Calibration, void Function()>(
  'calibrate',
);
final resetOmState = dylib.lookupFunction<ResetOmState, void Function()>(
  'resetOmState',
);
final setThresh = dylib.lookupFunction<SetThreshNative, void Function(double)>(
  'setMagnitudeThreshold',
);
final getMagnitudeThreshold = dylib
    .lookupFunction<GetMagnitudeThreshold, double Function()>(
      'getMagnitudeThreshold',
    );
final getRawFrequency = dylib
    .lookupFunction<GetRawFrequency, double Function()>('getRawFrequency');
final getRawMagnitude = dylib
    .lookupFunction<GetRawMagnitude, double Function()>('getRawMagnitude');
//...............

/// Load C++ library and bind

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
  static const int maxCountUps = 31;
  bool isDetected = false;

  int omBuffer = 0;
  bool _verdict = false; //for om detection if else condition
  int _sampleRate = 44100;
  bool isStreamActive =
      false; //false means inactive, this if for play/pause button on counter circle

  void Function(void Function())? _refreshUi;

  Future<void> start(void Function(void Function()) refreshUi) async {
    isStreamActive = true;
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
    isStreamActive = false;
    _audioCapture.stop();
    resetOmState();
    isRecording = false;
    refreshUi(() {});
  }

  void resetCount(void Function(void Function()) refreshUi) {
    refreshUi(() {
      omCount = 0;
    });
  }

  void incrementCount(void Function(void Function()) refreshUi) {
    refreshUi(() {
      omCount++;
    });
  }

  void decrementCount(void Function(void Function()) refreshUi) {
    refreshUi(() {
      if (omCount > 0) omCount--;
    });
  }

  bool pauseOrPlayCounting(void Function(void Function()) refreshUi) {
    if (isStreamActive) {
      //if stream is active
      stop(refreshUi);
      return false; //now deactive, deactive status is false
    } else {
      start(refreshUi);
      return true; //now active, active status is true
    }
  }

  void _listener(dynamic obj) {
    final Float32List buffer = Float32List.fromList(List<double>.from(obj));
    final Pointer<Float> samplePtr = malloc.allocate<Float>(
      buffer.length * sizeOf<Float>(),
    );

    for (int i = 0; i < buffer.length; i++) {
      samplePtr[i] = buffer[i];
    }

    isDetected = omDetection(samplePtr, buffer.length);

    malloc.free(samplePtr);

    if (isDetected) {
      omBuffer++;
      if (!_verdict && omBuffer >= maxCountUps) {
        omCount++;
        _verdict = true;
      }
    } else {
      _verdict = false;
      omBuffer = 0;
    }

    if (kDebugMode) {
      print(
        '[OM Detected: ${isDetected ? '1' : '0'}] thrashold: ${getMagnitudeThreshold()} ${getRawFrequency()} Hz | ${getRawMagnitude()}',
      );
    }

    _refreshUi?.call(() {});
  }

  void calibrateWithBackgroundNoise() {
    calibrate();
  }

  double getThreshold() {
    return getMagnitudeThreshold();
  }

  double getRawFreq() {
    return getRawFrequency();
  }

  double getRawMag() {
    return getRawMagnitude();
  }

  void _onError(Object e) {
    if (kDebugMode) print('Audio Error: $e');
  }

  //caliberation code part below.....
  bool isCalibrating = false;
}
