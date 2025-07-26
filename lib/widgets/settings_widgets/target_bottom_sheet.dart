import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class TargetBottomSheet extends StatelessWidget {
  const TargetBottomSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              textAlign: TextAlign.center,
              'Set your target chanting',
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
              controller: TextEditingController(),
              min: 0,
              max: 1000,
              incDecFactor: 1,
              initialValue: 11,
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
                onPressed: () {},
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
