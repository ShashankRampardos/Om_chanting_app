import 'package:flutter/material.dart';

class TextTile extends StatelessWidget {
  const TextTile({
    super.key,
    required this.text,
    required this.icon,
    required this.executeSetting,
  });
  final String text;
  final IconData icon;
  final void Function() executeSetting;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: executeSetting,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: Divider(
              color: Theme.of(context).colorScheme.onSurface,
              thickness: 1,
              indent: 1,
              endIndent: 1,
            ),
          ),
        ],
      ),
    );
  }
}
