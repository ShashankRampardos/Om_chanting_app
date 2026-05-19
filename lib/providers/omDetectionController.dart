// om_detection_controller.dart
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:om/models/omDetectionState.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:om/om_bindings.dart';

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
///
///

final omBindings = OmBindings(dylib);

class OmDetectionController extends AutoDisposeNotifier<OmDetectionState> {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  static const MethodChannel _channel = MethodChannel('native_audio');

  static const int maxCountUps = 31;

  int _sampleRate = 44100;
  int _omBuffer = 0;
  bool _verdict = false;

  @override
  OmDetectionState build() {
    // Provider ke lifecycle me ye call hota hai
    return OmDetectionState.initial;
  }

  Future<void> start() async {
    // stream active
    if (state.isStreamActive) return;
    state = state.copyWith(isStreamActive: true);

    await _audioCapture.init();
    try {
      final rate = await _channel.invokeMethod<int>('getSampleRate');
      if (rate != null) _sampleRate = rate;
    } on PlatformException {
      // default rahega 44100
    }

    if (!await Permission.microphone.request().isGranted) {
      state = state.copyWith(isStreamActive: false);
      return;
    }

    await _audioCapture.start(
      _listener,
      _onError,
      sampleRate: _sampleRate,
      bufferSize: 2048,
    );

    state = state.copyWith(isRecording: true);
  }

  void stop() {
    if (state.isStreamActive == false) return;
    _audioCapture.stop();
    resetOmState();
    _omBuffer = 0;
    _verdict = false;

    state = state.copyWith(
      isRecording: false,
      isStreamActive: false,
      isDetected: false,
    );
  }

  void resetCount() {
    if (state.omCount != 0) {
      state = state.copyWith(omCount: 0);
    }
  }

  void incrementCount() {
    state = state.copyWith(omCount: state.omCount + 1);
  }

  void decrementCount() {
    if (state.omCount > 0) {
      state = state.copyWith(omCount: state.omCount - 1);
    }
  }

  bool togglePausePlay() {
    if (state.isStreamActive) {
      stop();
      return false;
    } else {
      start();
      return true;
    }
  }

  int _lastCalibrateTime = 0;

  void _listener(dynamic obj) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - _lastCalibrateTime >= 2000) {
      calibrate();
      _lastCalibrateTime = now;
    }
    debugPrint('freq: ${getRawFreq()}');
    final Float32List buffer = Float32List.fromList(List<double>.from(obj));
    final Pointer<Float> samplePtr = calloc<Float>(buffer.length);

    for (int i = 0; i < buffer.length; i++) {
      samplePtr[i] = buffer[i];
    }

    final detected = omDetection(samplePtr, buffer.length);
    calloc.free(samplePtr);

    if (detected) {
      _omBuffer++;
      if (!_verdict && _omBuffer >= maxCountUps) {
        _verdict = true;
        state = state.copyWith(omCount: state.omCount + 1);
      }
    } else {
      _verdict = false;
      _omBuffer = 0;
    }

    state = state.copyWith(isDetected: detected);
  }

  void calibrateWithBackgroundNoise() {
    calibrate();
  }

  double getThreshold() => getMagnitudeThreshold();
  double getRawFreq() => getRawFrequency();
  double getRawMag() => getRawMagnitude();

  void _onError(Object e) {
    // log if needed
  }

  void dispose() {
    stop(); // stop stream safely
    // No need to call super.dispose() as Notifier does not define it
  }
}

// Riverpod provider for controller
final omDetectionControllerProvider =
    NotifierProvider.autoDispose<OmDetectionController, OmDetectionState>(
      OmDetectionController.new,
    );
