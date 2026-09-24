import 'package:camera/camera.dart';
import 'package:facetest/controller/face_capture_cubit.dart';
import 'package:facetest/controller_select.dart';
import 'package:flutter/material.dart';

class CameraLayer extends StatelessWidget {
  final FaceCaptureController controller;

  const CameraLayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ControllerSelect<CameraController?>(
      controller: controller,
      selector: (state) => state.cameraController,
      builder: (context, camController) {
        return RepaintBoundary(
          child: camController != null && camController.value.isInitialized
              ? CameraPreview(camController)
              : const ColoredBox(color: Colors.black),
        );
      },
    );
  }
}
