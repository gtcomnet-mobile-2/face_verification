import 'dart:io';

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
  final IconData? icon; // optional, e.g. Icons.arrow_left
  final String? assetIcon; // optional, e.g. 'assets/icons/turn_left.svg'

  const FacePoseStep({
    required this.pose,
    required this.instruction,
    this.icon,
    this.assetIcon,
  });

  static List<FacePoseStep> defaultSteps() => const [
    FacePoseStep(
      pose: FacePose.straight,
      assetIcon: 'assets/front.gif',
      instruction: 'Look straight into the camera',
      icon: Icons.camera_alt,
    ),
    FacePoseStep(
      pose: FacePose.left,
      assetIcon: 'assets/left.gif',
      instruction: 'Slowly turn your head left',
      icon: Icons.arrow_left,
    ),
    FacePoseStep(
      pose: FacePose.up,
      assetIcon: 'assets/up.gif',
      instruction: 'Tilt your head up',
      icon: Icons.arrow_upward,
    ),
    FacePoseStep(
      pose: FacePose.right,
      assetIcon: 'assets/right.gif',
      instruction: 'Slowly turn your head right',
      icon: Icons.arrow_right,
    ),
    FacePoseStep(
      pose: FacePose.down,
      assetIcon: 'assets/down.gif',

      instruction: 'Tilt your head down',
      icon: Icons.arrow_downward,
    ),
    FacePoseStep(
      pose: FacePose.smile,
      assetIcon: 'assets/smile.gif',

      instruction: 'Give us a smile',
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
