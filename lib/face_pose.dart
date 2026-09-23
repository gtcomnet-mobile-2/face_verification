import 'dart:io';

import 'package:facetest/constants/app_images.dart';
import 'package:flutter/material.dart';

/// Every pose the flow can ask the user to perform.
/// Add/remove/reorder freely — nothing else in the package assumes
/// a fixed count or order.
enum FacePose { straight, left, right, up, down, smile }

/// One step in the capture sequence: which pose, what to tell the user,
/// and (optionally) an icon for the instruction UI.
class FacePoseStep {
  final FacePose pose;
  final String instruction;
  final String subtitle;
  final String number;
  final IconData? icon; // optional, e.g. Icons.arrow_left
  final String? assetIcon; // optional, e.g. 'assets/icons/turn_left.svg'

  const FacePoseStep({
    required this.pose,
    required this.number,
    required this.subtitle,
    required this.instruction,
    this.icon,
    this.assetIcon,
  });

  static List<FacePoseStep> defaultSteps() => const [
    FacePoseStep(
      pose: FacePose.straight,
      assetIcon: AppImages.front,
      instruction: 'Look Into The Camera',
      number: "1",
      subtitle: 'Slowly tilt your head into the circle',
      icon: Icons.camera_alt,
    ),
    FacePoseStep(
      pose: FacePose.left,
      assetIcon: AppImages.left,
      instruction: 'Turn Left',
      icon: Icons.arrow_left,
      number: "2",

      subtitle: 'Slowly turn your head to the left',
    ),
    FacePoseStep(
      pose: FacePose.up,
      assetIcon: AppImages.up,
      instruction: 'Look Up',
      number: "3",

      subtitle: 'Slowly tilt your head upward',
      icon: Icons.arrow_upward,
    ),
    FacePoseStep(
      pose: FacePose.right,
      assetIcon: AppImages.right,
      number: "4",

      subtitle: 'Slowly turn your head to the right',
      instruction: 'Turn Right',
      icon: Icons.arrow_right,
    ),
    FacePoseStep(
      pose: FacePose.down,
      assetIcon: AppImages.down,
      subtitle: 'Slowly tilt your head downward',
      number: "5",

      instruction: 'Look Down',
      icon: Icons.arrow_downward,
    ),
    FacePoseStep(
      pose: FacePose.smile,
      number: "6",

      assetIcon: AppImages.smile,
      subtitle: 'Give us a natural smile',
      instruction: 'Smile',
      icon: Icons.sentiment_satisfied,
    ),
  ];
}

/// One completed capture: which pose it was for + the saved file.
class CapturedFaceImage {
  final FacePose pose;
  final File file;

  const CapturedFaceImage({required this.pose, required this.file});
}
