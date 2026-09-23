import 'package:facetest/face_capture_state.dart';
import 'package:facetest/face_pose.dart';
import 'package:flutter/material.dart';

/// Everything the UI team can tune WITHOUT touching camera/detection logic.
///
/// Pass a [FaceCaptureConfig] into [FaceCaptureScreen]. Any builder you
/// leave null falls back to a sensible default widget, so the screen works
/// out of the box and can be reskinned piece by piece.
class FaceCaptureConfig {
  /// The sequence of poses to capture, in order.
  final List<FacePoseStep> steps;

  /// How far off-center (degrees) the head can be and still count as
  /// "straight". Smaller = stricter.
  final double straightYawTolerance;
  final double straightPitchTolerance;

  /// Minimum head yaw angle (degrees) to count as "turned left/right".
  /// Positive yaw is the user turning toward their left. iOS front-camera
  /// frames are mirrored, so that sign is flipped before this comparison.
  final double yawThreshold;

  /// Minimum head pitch angle (degrees) to count as "up/down".
  /// ML Kit's headEulerAngleX: positive = tilted up.
  final double pitchThreshold;

  /// Minimum smiling probability (0.0–1.0) to count as "smile".
  final double smileThreshold;

  /// How long the correct pose must be held before auto-capturing.
  final Duration holdDuration;

  /// If false, the user must tap a capture button instead of auto-capture.
  final bool autoCapture;

  /// Theme colors — used by the default widgets, ignored if you supply
  /// your own builders below.
  final Color primaryColor;
  final Color successColor;
  final Color errorColor;
  final Color overlayBackgroundColor;

  // ---- Full widget replacement points ----

  /// Paints the guide over the camera preview (e.g. an oval, a square
  /// frame, a custom SVG mask). Receives the current state so it can
  /// react (e.g. turn green when pose is matched).
  final Widget Function(BuildContext context, FaceCaptureState state)?
  overlayBuilder;

  /// The instruction text/card shown for the current step.
  final Widget Function(BuildContext context, FacePoseStep step)?
  instructionBuilder;

  /// Progress indicator (dots, bar, step counter, whatever the UI team wants).
  final Widget Function(
    BuildContext context,
    int completedSteps,
    int totalSteps,
  )?
  progressBuilder;

  /// Manual capture button (only rendered if [autoCapture] is false).
  final Widget Function(BuildContext context, VoidCallback onCapture)?
  captureButtonBuilder;

  /// Full-screen success widget shown once all steps are captured
  /// and upload succeeds.
  final Widget Function(BuildContext context)? successBuilder;

  /// Full-screen error widget. Receives the error message and a retry callback.
  final Widget Function(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  )?
  errorBuilder;

  const FaceCaptureConfig({
    List<FacePoseStep>? steps,
    this.straightYawTolerance = 8.0,
    this.straightPitchTolerance = 8.0,
    this.yawThreshold = 20.0,
    this.pitchThreshold = 15.0,
    this.smileThreshold = 0.7,
    this.holdDuration = const Duration(milliseconds: 600),
    this.autoCapture = true,
    this.primaryColor = const Color(0xFF2E7DFF),
    this.successColor = const Color(0xFF34C759),
    this.errorColor = const Color(0xFFFF3B30),
    this.overlayBackgroundColor = const Color(0xFFFFFFFF),
    this.overlayBuilder,
    this.instructionBuilder,
    this.progressBuilder,
    this.captureButtonBuilder,
    this.successBuilder,
    this.errorBuilder,
  }) : steps = steps ?? const [];

  List<FacePoseStep> get resolvedSteps =>
      steps.isEmpty ? FacePoseStep.defaultSteps() : steps;
}
