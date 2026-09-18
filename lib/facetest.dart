import 'dart:io';

import 'package:facetest/face_capture_screen.dart';
import 'package:facetest/face_pose.dart';
import 'package:flutter/material.dart';

class Facetest {
   void launchCamera(
    BuildContext context, {
    required void Function(List<CapturedFaceImage> files) onSuccess,
    VoidCallback? onCancel,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FaceCaptureScreen(onSuccess: onSuccess, onCancel: onCancel),
      ),
    );
  }


  void configure({Color? backgroundColor, Widget? topWidgets, Widget? bottomWidgets}){

    
  }
}
