import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetTime extends StateNotifier<int> {
  TargetTime() : super(11 * 60);

  void setTargetTimeInMinutes(int minutes) {
    state = minutes * 60; //storing in seconds not in minutes
  }
}

final targetTimeNotifierProvider = StateNotifierProvider<TargetTime, int>((
  ref,
) {
  return TargetTime();
});
