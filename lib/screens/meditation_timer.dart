import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:om/providers/alert_sound.dart';

import 'package:om/providers/player.dart';
import 'package:om/providers/target_time.dart';
import 'package:om/providers/timer.dart';

final containerKey = GlobalKey();

class MeditationApp extends ConsumerStatefulWidget {
  const MeditationApp({super.key});
  @override
  ConsumerState<MeditationApp> createState() => _MeditationAppState();
}

class _MeditationAppState extends ConsumerState<MeditationApp> {
  Offset position = Offset(0, 0);
  bool isTimerRunning = false;
  bool targetMatched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(timerProvider.notifier)
          .initializeTimer(ref.read(targetTimeNotifierProvider));
    });
    //isTimerRunning = true;
  }

  @override
  Widget build(BuildContext ctx) {
    final targetTime = ref.watch(targetTimeNotifierProvider);

    final alertSound = ref.watch(alertSoundNotifierProvider);
    final playerNotifier = ref.watch(soundPlayerProvider.notifier);

    final runningTime = ref.watch(timerProvider);
    final runningTimeNotifier = ref.watch(timerProvider.notifier);

    ref.listen<int>(timerProvider, (prev, next) {
      // final target = ref.read(targetNotifierProvider);
      // final alertSound = ref.read(alertSoundNotifierProvider);

      if (next == 0) {
        setState(() {
          targetMatched = true;
          isTimerRunning = false;
        }); //ruk gaya time
        if (alertSound != null) {
          final playerNotifier = ref.read(soundPlayerProvider.notifier);
          playerNotifier.setPlayer('alert sound');
          playerNotifier.play(alertSound.localPreviewPath, alertSound.id);
        }
        runningTimeNotifier.reset(targetTime);

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
                    //if target matched then dont use these methods
                    // this extra condition fixed a bug
                    runningTimeNotifier.reset(targetTime); // Left
                    setState(
                      () {
                        isTimerRunning = false;
                      },
                    ); //when reset timer is reset and it is no more activily running
                  } else if (dx >= boundaryValue &&
                      (dy >= -levelValue && dy <= levelValue) &&
                      targetMatched != true) {
                    if (isTimerRunning) {
                      runningTimeNotifier.stop();
                      setState(
                        () {
                          isTimerRunning = false;
                        },
                      ); //when stop timer is stopped and it is no more activily running
                    } else {
                      runningTimeNotifier.start();
                      setState(() {
                        isTimerRunning = true;
                      });
                    } // Right
                  } else if (dy >= boundaryValue &&
                      (dx >= -levelValue && dx <= levelValue) &&
                      targetMatched != true) {
                    //coordinates system on screen is not exactyl similar to cartician system
                    runningTimeNotifier.decrement(); // Bottom
                  } else if (dy <= -boundaryValue &&
                      (dx >= -levelValue && dx <= levelValue) &&
                      targetMatched != true) {
                    runningTimeNotifier.increment(); // Top
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
                      color: (targetMatched == true)
                          ? const Color.fromARGB(255, 255, 176, 28)
                          : Theme.of(context).colorScheme.inversePrimary,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiary.withAlpha(140),
                        spreadRadius: targetMatched == true
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
                                  setState(() {
                                    runningTimeNotifier.reset(targetTime);
                                    playerNotifier.stop(null);
                                    targetMatched = false;
                                    isTimerRunning = false;
                                  });
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
                                    runningTimeNotifier.reset(targetTime);
                                    playerNotifier.stop(alertSound.id);
                                    setState(() {
                                      targetMatched = false;
                                      isTimerRunning = false;
                                    });
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
                                  isTimerRunning
                                      ? '${(runningTime ~/ 60).toString().padLeft(2, '0')}:${((runningTime > targetTime ? 0 : runningTime) % 60).toString().padLeft(2, '0')}'
                                      : 'Start now',
                                  textAlign: TextAlign.center,

                                  style:
                                      (isTimerRunning
                                              ? Theme.of(
                                                  context,
                                                ).textTheme.headlineMedium
                                              : Theme.of(
                                                  context,
                                                ).textTheme.titleMedium)!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                                .withAlpha(225),
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                                CountDisplayIcon(
                                  icon: isTimerRunning
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
