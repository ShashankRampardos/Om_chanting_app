import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0);
  Timer? _timer;

  void initializeTimer(int seconds) {
    state = seconds;
  }

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void reset(int seconds) {
    state = seconds;
    _timer?.cancel();
  }

  void increment() {
    state += 5;
  }

  void decrement() {
    if (state > 5) {
      state -= 5;
    } else {
      state = 0;
    }
  }

  void stop() {
    _timer?.cancel();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, int>((ref) {
  return TimerNotifier();
});
