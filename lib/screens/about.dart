import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        ),
        backgroundColor: Theme.of(context).colorScheme.onSecondaryFixedVariant,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '✨ About Om App ✨\n'
                '\n'
                'Om App is designed to help you deepen your meditation journey.\n'
                '\n'
                '🕉️ Om Counter: Count your chants with a customizable target and gentle alert when you reach it.\n'
                '🧘 Silent Meditation: Timer + alert for focused silent practice.\n'
                '🎶 Background Music: Optional calming music to accompany your session.\n'
                '🎚️ Calibrate Mode: Adjust sensitivity to match your surrounding noise for accurate detection.\n'
                '🎨 Beautiful UI/UX: Simple, modern, and distraction-free design.\n'
                '\n'
                'Whether you chant Om or sit in silence, the app supports you in creating a consistent, mindful practice. 🙏',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
