import 'dart:async';

import 'package:facetest/face_capture_cubit.dart';
import 'package:facetest/face_capture_screen.dart';
import 'package:facetest/face_pose.dart';
import 'package:flutter/material.dart';

class Facetest {
  /// Call once at app startup so camera discovery and the face-detection
  /// model are ready before the user opens capture.
  static Future<void> preload() => FaceCaptureController.preload();

  static void launchCamera(
    BuildContext context, {
    required void Function(List<CapturedFaceImage> files) onSuccess,
    VoidCallback? onCancel,
  }) {
    unawaited(FaceCaptureController.prepareCamera());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FaceCaptureScreen(onSuccess: onSuccess, onCancel: onCancel),
      ),
    );
  }

  void configure({
    Color? backgroundColor,
    Widget? topWidgets,
    Widget? bottomWidgets,
  }) {}
}
