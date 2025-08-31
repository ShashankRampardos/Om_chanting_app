import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:om/providers/target.dart';
import 'package:om/providers/target_time.dart';

class TargetBottomSheet extends ConsumerWidget {
  const TargetBottomSheet({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetNotifier = ref.watch(targetNotifierProvider.notifier);
    final targetProvider = ref.watch(targetNotifierProvider);
    final targetMinutesNotifier = ref.watch(
      targetTimeNotifierProvider.notifier,
    );
    final targetMinutes = ref.watch(targetTimeNotifierProvider);

    final controller = TextEditingController(text: targetProvider.toString());
    bool isChanting = title == 'chanting';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              textAlign: TextAlign.center,
              isChanting
                  ? 'Set target chanting'
                  : 'Set target meditation in minutes',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Divider(thickness: 1, color: Colors.black),
          SizedBox(height: 10),
          SizedBox(
            height: 53,
            width: 150,
            child: NumberInputWithIncrementDecrement(
              controller: controller,
              min: 0,
              max: 1000,
              incDecFactor: 1,
              initialValue: isChanting ? targetProvider : targetMinutes ~/ 60,
              numberFieldDecoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'cancel',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newTarget =
                      int.tryParse(controller.text) ??
                      (isChanting ? targetProvider : targetMinutes);
                  if (isChanting) {
                    targetNotifier.setTarget(newTarget);
                  } else {
                    targetMinutesNotifier.setTargetTimeInMinutes(newTarget);
                  }

                  Navigator.of(context).pop();
                },
                child: Text(
                  'set',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
