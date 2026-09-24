import 'package:facetest/config/face_capture_config.dart';
import 'package:facetest/controller/face_capture_cubit.dart';
import 'package:facetest/controller_select.dart';
import 'package:facetest/default_progress.dart';
import 'package:flutter/material.dart';

class ProgressLayer extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;

  const ProgressLayer({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ControllerSelect<int>(
      controller: controller,
      selector: (state) => state.captured.length,
      builder: (context, completed) {
        if (config.progressBuilder != null) {
          return Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: config.progressBuilder!(
              context,
              completed,
              controller.stepsCount,
            ),
          );
        }
        return RepaintBoundary(
          child: DefaultProgress(
            completed: completed,
            total: controller.stepsCount,
            color: config.primaryColor,
          ),
        );
      },
    );
  }
}
