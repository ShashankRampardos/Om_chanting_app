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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'About Om App\n\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Om App is designed to help you deepen your meditation journey.\n\n',
                    ),
                    const TextSpan(
                      text: 'Om Counter: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'Count your chants with a customizable target and gentle alert when you reach it.\n',
                    ),
                    const TextSpan(
                      text: 'Silent Meditation: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: 'Timer + alert for focused silent practice.\n',
                    ),
                    const TextSpan(
                      text: 'Background Music: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'Optional calming music to accompany your session.\n',
                    ),
                    const TextSpan(
                      text: 'Calibrate Mode: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'Adjust sensitivity to match your surrounding noise for accurate detection.\n',
                    ),
                    const TextSpan(
                      text: 'Beautiful UI/UX: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: 'Simple, modern, and distraction-free design.\n\n',
                    ),
                    const TextSpan(
                      text:
                          'Whether you chant Om or sit in silence, the app supports you in creating a consistent, mindful practice. 🙏',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
