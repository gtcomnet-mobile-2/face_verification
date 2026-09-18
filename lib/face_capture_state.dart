import 'package:camera/camera.dart';
import 'package:facetest/face_pose.dart';


enum FaceCapturePhase {
  initializing,
  permissionDenied,
  cameraError,
  ready, // camera live, waiting for face to line up
  poseMatched, // holding correct pose, counting down to auto-capture
  allCaptured, // all steps done, ready to submit
  uploading,
  uploadSuccess,
  uploadFailure,
}

/// Plain, immutable snapshot of where the capture flow currently is.
/// No base-class dependency (no Equatable) — just a value holder with
/// a copyWith, which is all a package needs.
class FaceCaptureState {
  final FaceCapturePhase phase;
  final CameraController? cameraController;
  final int currentStepIndex;
  final List<CapturedFaceImage> captured;
  final bool faceDetected;
  final String? errorMessage;
  final double holdProgress;

  const FaceCaptureState({
    this.phase = FaceCapturePhase.initializing,
    this.cameraController,
    this.currentStepIndex = 0,
    this.captured = const [],
    this.faceDetected = false,
    this.holdProgress = 0.0, // ADD THIS LINE

    this.errorMessage,
  });

  FaceCaptureState copyWith({
    FaceCapturePhase? phase,
    CameraController? cameraController,
    int? currentStepIndex,
    double? holdProgress, // ADD THIS PARAM

    List<CapturedFaceImage>? captured,
    bool? faceDetected,
    String? errorMessage,
  }) {
    return FaceCaptureState(
      phase: phase ?? this.phase,
      cameraController: cameraController ?? this.cameraController,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      captured: captured ?? this.captured,
      faceDetected: faceDetected ?? this.faceDetected,
      holdProgress: holdProgress ?? this.holdProgress, // ADD THIS LINE

      errorMessage: errorMessage, // deliberately NOT defaulted — see note below
    );
  }
}
