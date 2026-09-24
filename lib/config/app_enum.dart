import 'package:facetest/controller/face_capture_state.dart';

enum CaptureUi {
  initializing,
  permissionDenied,
  cameraError,
  capturing,
  uploading,
  uploadFailure,
  uploadSuccess,
}
CaptureUi uiFor(FaceCapturePhase phase) {
  return switch (phase) {
    FaceCapturePhase.initializing => CaptureUi.initializing,
    FaceCapturePhase.permissionDenied => CaptureUi.permissionDenied,
    FaceCapturePhase.cameraError => CaptureUi.cameraError,
    FaceCapturePhase.uploading => CaptureUi.uploading,
    FaceCapturePhase.uploadFailure => CaptureUi.uploadFailure,
    FaceCapturePhase.uploadSuccess => CaptureUi.uploadSuccess,
    FaceCapturePhase.ready ||
    FaceCapturePhase.poseMatched ||
    FaceCapturePhase.allCaptured => CaptureUi.capturing,
  };
}
