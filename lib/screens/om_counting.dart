import 'package:flutter/material.dart';
import 'package:om/core/om_detection_controller.dart';

final containerKey = GlobalKey();

class OmApp extends StatefulWidget {
  const OmApp({super.key});
  @override
  State<OmApp> createState() => _OmAppState();
}

class _OmAppState extends State<OmApp> {
  final controller = OmDetectionController();
  Offset position = Offset(0, 0);
  bool isControllerActive = false;
  @override
  void initState() {
    super.initState();
    controller.start(setState);
    isControllerActive = true;
  }

  @override
  void dispose() {
    super.dispose();
    controller.stop(setState);
  }

  @override
  Widget build(BuildContext ctx) => Stack(
    children: [
      Positioned(
        left: position.dx,
        top: position.dy,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              // extramly useful bhai, just remember if forever "GestureDetector OP"
              onPanUpdate: (details) {
                setState(() {
                  position += details.delta;
                });
              },
              onTapDown: (TapDownDetails detail) {
                final radius = containerKey.currentContext!.size!.width / 2;

                print(
                  'WIDTH DEKH LA ABH FINALLY ON CONSOL SCREEN PAY !!!! $radius',
                );
                final local = detail.localPosition;
                final center = Offset(radius, radius);
                final dx = local.dx - center.dx;
                final dy = local.dy - center.dy;
                final boundaryValue =
                    radius * (0.666666667); //i got this value by 60/90
                final levelValue =
                    radius * (0.111111111); //i got this value by 10/90

                if (dx <= -boundaryValue && (dy >= -10 && dy <= 10)) {
                  controller.resetCount(setState); // Left
                } else if (dx >= boundaryValue &&
                    (dy >= -levelValue && dy <= levelValue)) {
                  isControllerActive = controller.pauseOrPlayCounting(
                    setState,
                  ); // Right
                } else if (dy >= boundaryValue &&
                    (dx >= -levelValue && dx <= levelValue)) {
                  //coordinates system on screen is not exactyl similar to cartician system
                  controller.decrementCount(setState); // Bottom
                } else if (dy <= -boundaryValue &&
                    (dx >= -levelValue && dx <= levelValue)) {
                  controller.incrementCount(setState); // Top
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
                    color: Theme.of(context).colorScheme.inversePrimary,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.onTertiary.withAlpha(140),
                      spreadRadius: 15, // this makes it glow outside
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CountDisplayIcon(icon: Icons.add),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CountDisplayIcon(icon: Icons.restore),
                        Text(
                          controller.isRecording
                              ? '${controller.omCount}'
                              : 'Mic off',
                          textAlign: TextAlign.center,

                          style:
                              (controller.isRecording
                                      ? Theme.of(context).textTheme.displaySmall
                                      : Theme.of(
                                          context,
                                        ).textTheme.headlineSmall)!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiary.withAlpha(225),
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

class CountDisplayIcon extends StatelessWidget {
  const CountDisplayIcon({super.key, required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Icon(size: 27, color: const Color.fromARGB(255, 255, 175, 69), icon);
  }
}
