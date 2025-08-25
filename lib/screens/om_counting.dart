import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:om/core/om_detection_controller.dart';
import 'package:om/providers/alert_sound.dart';
import 'package:om/providers/om_controller.dart';
import 'package:om/providers/player.dart';
import 'package:om/providers/target.dart';

final containerKey = GlobalKey();

class OmApp extends ConsumerStatefulWidget {
  const OmApp({super.key});
  @override
  ConsumerState<OmApp> createState() => _OmAppState();
}

class _OmAppState extends ConsumerState<OmApp> {
  final controller = OmDetectionController();
  Offset position = Offset(0, 0);
  bool isControllerActive = false;

  @override
  void initState() {
    super.initState();
    controller.start(setState, ref);
    isControllerActive = true;

    // listen to target changes
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.listen<int>(targetNotifierProvider, (prev, next) {
    //     if (next == omCount) {
    //       final alertSound = ref.read(alertSoundNotifierProvider);
    //       if (alertSound != null) {
    //         final playerNotifier = ref.read(soundPlayerProvider.notifier);
    //         playerNotifier.setPlayer('alert sound');
    //         playerNotifier.play(alertSound.localPreviewPath, alertSound.id);
    //         controller.stop();
    //       }
    //     }
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
    controller.stop();
  }

  bool targetMatched = false;
  @override
  Widget build(BuildContext ctx) {
    final target = ref.read(targetNotifierProvider);
    final alertSound = ref.read(alertSoundNotifierProvider);
    final playerNotifier = ref.read(soundPlayerProvider.notifier);
    final omCount = ref.watch(omControllerProvider);

    ref.listen<int>(omControllerProvider, (prev, next) {
      // final target = ref.read(targetNotifierProvider);
      // final alertSound = ref.read(alertSoundNotifierProvider);

      if (next == target) {
        targetMatched = true;
        if (alertSound != null) {
          final playerNotifier = ref.read(soundPlayerProvider.notifier);
          playerNotifier.setPlayer('alert sound');
          playerNotifier.play(alertSound.localPreviewPath, alertSound.id);
        }
        controller
            .resetCount(); //ye bhul gaya tha, it created a bug but now fixed
        controller.stop();

        //print('$target || $next');
      }
    });

    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                // extramly useful bhai, just remember it forever "GestureDetector OP"
                onPanUpdate: (details) {
                  setState(() {
                    position += details.delta;
                  });
                },
                onTapDown: (TapDownDetails detail) {
                  final radius = containerKey.currentContext!.size!.width / 2;
                  // print(
                  //   'WIDTH DEKH LA ABH FINALLY ON CONSOL SCREEN PAY !!!! $radius',
                  // );
                  final local = detail.localPosition;
                  final center = Offset(radius, radius);
                  final dx = local.dx - center.dx;
                  final dy = local.dy - center.dy;
                  final boundaryValue =
                      radius * (0.666666667); //i got this value by 60/90
                  final levelValue =
                      radius * (0.111111111); //i got this value by 10/90

                  if (dx <= -boundaryValue &&
                      (dy >= -10 && dy <= 10) &&
                      targetMatched != true) {
                    // this extra condition fixed a bug
                    controller.resetCount(); // Left
                  } else if (dx >= boundaryValue &&
                      (dy >= -levelValue && dy <= levelValue) &&
                      targetMatched != true) {
                    isControllerActive = controller.pauseOrPlayCounting(
                      setState,
                      ref,
                    ); // Right
                  } else if (dy >= boundaryValue &&
                      (dx >= -levelValue && dx <= levelValue) &&
                      targetMatched != true) {
                    //coordinates system on screen is not exactyl similar to cartician system
                    controller.decrementCount(); // Bottom
                  } else if (dy <= -boundaryValue &&
                      (dx >= -levelValue && dx <= levelValue) &&
                      targetMatched != true) {
                    controller.incrementCount(); // Top
                  }
                },
                child: Container(
                  width: 151,
                  height: 151,
                  key: containerKey,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (controller.isDetected || targetMatched == true)
                          ? const Color.fromARGB(255, 255, 176, 28)
                          : Theme.of(context).colorScheme.inversePrimary,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiary.withAlpha(140),
                        spreadRadius:
                            controller.isDetected || targetMatched == true
                            ? 20
                            : 15, // this makes it glow outside
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: (targetMatched == true)
                      ? ((alertSound == null)
                            ? (TextButton(
                                onPressed: () {
                                  controller.start(setState, ref);
                                  targetMatched = false;
                                },
                                child: Text(
                                  'Tap here to restart (no sound selected to play)',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ))
                            : Opacity(
                                opacity: 0.8,
                                child: IconButton(
                                  onPressed: () {
                                    controller.start(setState, ref);
                                    //controller.resetCount();

                                    playerNotifier.stop(alertSound.id);

                                    //playerNotifier.setPlayer('background sound');
                                    //playerNotifier.play();background again continue
                                    targetMatched = false;
                                  },
                                  icon: Icon(Icons.stop_rounded, size: 84),
                                ),
                              ))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CountDisplayIcon(icon: Icons.add),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CountDisplayIcon(icon: Icons.restore),
                                Text(
                                  controller.isRecording
                                      ? '$omCount'
                                      : 'Mic off',
                                  textAlign: TextAlign.center,

                                  style:
                                      (controller.isRecording
                                              ? Theme.of(
                                                  context,
                                                ).textTheme.displaySmall
                                              : Theme.of(
                                                  context,
                                                ).textTheme.headlineSmall)!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                                .withAlpha(225),
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                                CountDisplayIcon(
                                  icon: isControllerActive
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ],
                            ),
                            CountDisplayIcon(icon: Icons.remove),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CountDisplayIcon extends StatelessWidget {
  const CountDisplayIcon({super.key, required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Icon(size: 27, color: const Color.fromARGB(255, 255, 175, 69), icon);
  }
}
