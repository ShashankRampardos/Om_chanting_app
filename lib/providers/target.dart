import 'package:flutter_riverpod/flutter_riverpod.dart';

class Target extends StateNotifier<int> {
  Target() : super(11);
  void setTarget(int target) {
    state = target;
  }
}

final targetNotifierProvider = StateNotifierProvider<Target, int>((ref) {
  return Target();
});
