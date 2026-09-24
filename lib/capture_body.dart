import 'package:facetest/camera_layer.dart';
import 'package:facetest/config/face_capture_config.dart';
import 'package:facetest/controller/face_capture_cubit.dart';
import 'package:facetest/dots_layer.dart';
import 'package:facetest/instruction_layer.dart';
import 'package:facetest/overlay_layer.dart';
import 'package:flutter/material.dart';

class CaptureBody extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;
  final VoidCallback? onClose;
  const CaptureBody({
    super.key,
    required this.config,
    required this.controller,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraLayer(controller: controller),
        OverlayLayer(config: config, controller: controller, onClose: onClose),
        // _ProgressLayer(config: config, controller: controller),
        InstructionLayer(config: config, controller: controller),
        DotsLayer(config: config, controller: controller),

        if (!config.autoCapture)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child:
                  config.captureButtonBuilder?.call(
                    context,
                    controller.captureCurrentStep,
                  ) ??
                  FloatingActionButton(
                    backgroundColor: config.primaryColor,
                    onPressed: controller.captureCurrentStep,
                    child: const Icon(Icons.camera_alt),
                  ),
            ),
          ),
      ],
    );
  }
}
