import 'package:flutter/material.dart';
import 'package:om/core/om_detection_controller.dart';

class OmApp extends StatefulWidget {
  const OmApp({super.key});
  @override
  State<OmApp> createState() => _OmAppState();
}

class _OmAppState extends State<OmApp> {
  final OmDetectionController controller = OmDetectionController();
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
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: Text(
        controller.isRecording
            ? 'Om Count: ${controller.omCount.toString()}'
            : 'Mic off',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 22),
      ),
    ),
  );
}
