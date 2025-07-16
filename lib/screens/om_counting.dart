import 'package:flutter/material.dart';
import 'package:om/core/om_detection_controller.dart';

class OmApp extends StatefulWidget {
  const OmApp({super.key});
  @override
  State<OmApp> createState() => _OmAppState();
}

class _OmAppState extends State<OmApp> {
  final OmDetectionController controller = OmDetectionController();
  Offset position = Offset(0, 0);
  @override
  void initState() {
    super.initState();
    controller.start(setState);
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
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              position += details.delta;
            });
          },
          onTap: () {
            controller.resetCount(setState);
          },
          child: Container(
            width: 180,
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                width: 8,
              ),
            ),
            child: Text(
              controller.isRecording ? '${controller.omCount}' : 'Mic off',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
