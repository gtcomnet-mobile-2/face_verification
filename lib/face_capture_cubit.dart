import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:facetest/face_capture_config.dart';
import 'package:facetest/face_pose.dart';
import 'package:facetest/face_verification_repository.dart';
import 'package:flutter/foundation.dart'; // ChangeNotifier lives here
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'face_capture_state.dart';

/// Owns the camera, runs ML Kit face detection, sequences the capture
/// steps, and uploads the result. This is a plain [ChangeNotifier] —
/// no bloc/riverpod/provider dependency. Any widget can listen to it
/// with `ListenableBuilder` or `AnimatedBuilder`, both built into Flutter.
///
/// Usage:
/// ```dart
/// final controller = FaceCaptureController(config: config, repository: repo);
/// await controller.initialize();
/// // controller.state has everything the UI needs
/// controller.addListener(() { ... rebuild ... });
/// controller.dispose(); // when done
/// ```
class FaceCaptureController extends ChangeNotifier {
  final FaceCaptureConfig config;

  FaceCaptureController({required this.config, }) {
    _steps = config.resolvedSteps;
  }

  late final List<FacePoseStep> _steps;
  final dio = Dio();


  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // needed for smilingProbability
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  CameraController? _cameraController;
  bool _isDetecting = false;
  bool _isCapturing = false;
  Timer? _holdTimer;
  bool _disposed = false;

  FaceCaptureState _state = const FaceCaptureState();

  /// Current snapshot. Read this in your widget's build method.
  FaceCaptureState get state => _state;

  /// Total number of steps in this flow (respects a custom [config.steps]).
  int get stepsCount => _steps.length;

  FacePoseStep get currentStep => _steps[_state.currentStepIndex];

  /// Replaces the internal state and notifies listeners — the ChangeNotifier
  /// equivalent of `emit()` in the old cubit version.
  void _update(FaceCaptureState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  Future<void> initialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _update(_state.copyWith(phase: FaceCapturePhase.permissionDenied));
      return;
    }

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final camController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await camController.initialize();
      _cameraController = camController;

      _update(
        _state.copyWith(
          phase: FaceCapturePhase.ready,
          cameraController: camController,
        ),
      );

      await camController.startImageStream(_onCameraFrame);
    } catch (e) {
      _update(
        _state.copyWith(
          phase: FaceCapturePhase.cameraError,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onCameraFrame(CameraImage image) {
    if (_isDetecting || _isCapturing) return;
    if (_state.phase != FaceCapturePhase.ready &&
        _state.phase != FaceCapturePhase.poseMatched) {
      return;
    }
    _isDetecting = true;
    _detectFace(image).whenComplete(() => _isDetecting = false);
  }

  Future<void> _detectFace(CameraImage image) async {
    final inputImage = _toInputImage(image);
    if (inputImage == null) return;

    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      _holdTimer?.cancel();
      if (_state.faceDetected || _state.phase == FaceCapturePhase.poseMatched) {
        _update(
          _state.copyWith(faceDetected: false, phase: FaceCapturePhase.ready),
        );
      }
      return;
    }

    final face = faces.first;
    final matches = _poseMatches(face, currentStep.pose);

    if (matches) {
      if (_state.phase != FaceCapturePhase.poseMatched) {
        _update(
          _state.copyWith(
            phase: FaceCapturePhase.poseMatched,
            faceDetected: true,
          ),
        );
        _startHoldTimer();
      }
    } else {
      _holdTimer?.cancel();
      if (_state.phase != FaceCapturePhase.ready) {
        _update(
          _state.copyWith(phase: FaceCapturePhase.ready, faceDetected: true),
        );
      }
    }
  }

  bool _poseMatches(Face face, FacePose pose) {
    final yaw = face.headEulerAngleY ?? 0; // left/right turn
    final pitch = face.headEulerAngleX ?? 0; // up/down tilt
    final smileProb = face.smilingProbability ?? 0;

    switch (pose) {
      case FacePose.straight:
        return yaw.abs() <= config.straightYawTolerance &&
            pitch.abs() <= config.straightPitchTolerance;
      case FacePose.left:
        return yaw >= config.yawThreshold;
      case FacePose.right:
        return yaw <= -config.yawThreshold;
      case FacePose.up:
        return pitch >= config.pitchThreshold;
      case FacePose.down:
        return pitch <= -config.pitchThreshold;
      case FacePose.smile:
        return smileProb >= config.smileThreshold;
    }
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = Timer(config.holdDuration, () {
      if (_state.phase == FaceCapturePhase.poseMatched) {
        captureCurrentStep();
      }
    });
  }

  /// Called automatically after the hold duration, or manually if
  /// [FaceCaptureConfig.autoCapture] is false and your UI wires up a button.
  Future<void> captureCurrentStep() async {
    final camController = _cameraController;
    if (camController == null || _isCapturing) return;
    _isCapturing = true;

    try {
      await camController.stopImageStream();
      final xfile = await camController.takePicture();

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/face_${currentStep.pose.name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(xfile.path).copy(path);

      final updatedCaptured = [
        ..._state.captured,
        CapturedFaceImage(pose: currentStep.pose, file: savedFile),
      ];

      final nextIndex = _state.currentStepIndex + 1;
      final isDone = nextIndex >= _steps.length;

      _update(
        _state.copyWith(
          captured: updatedCaptured,
          currentStepIndex: isDone ? _state.currentStepIndex : nextIndex,
          phase: isDone ? FaceCapturePhase.allCaptured : FaceCapturePhase.ready,
          faceDetected: false,
        ),
      );

      if (!isDone) {
        await camController.startImageStream(_onCameraFrame);
      }
    } catch (e) {
      _update(
        _state.copyWith(
          phase: FaceCapturePhase.cameraError,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> submit({required String userId}) async {
    _update(_state.copyWith(phase: FaceCapturePhase.uploading));
    final FaceVerificationRepository repository = DioFaceVerificationRepository(
      dio,
    );

    try {
      await repository.submitVerification(
        userId: userId,
        images: _state.captured,
      );
      _update(_state.copyWith(phase: FaceCapturePhase.uploadSuccess));
    } catch (e) {
      _update(
        _state.copyWith(
          phase: FaceCapturePhase.uploadFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Reset and start the whole sequence over (e.g. after an error).
  Future<void> retry() async {
    _holdTimer?.cancel();
    for (final img in _state.captured) {
      if (await img.file.exists()) await img.file.delete();
    }
    _update(const FaceCaptureState());
    await initialize();
  }

  InputImage? _toInputImage(CameraImage image) {
    final camController = _cameraController;
    if (camController == null) return null;

    try {
      final camera = camController.description;
      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final format = Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888;

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// IMPORTANT: call this from your widget's `dispose()`, same as any
  /// other ChangeNotifier-based controller (e.g. a TextEditingController).
  @override
  void dispose() {
    _disposed = true;
    _holdTimer?.cancel();

    // Camera/detector cleanup is async, but ChangeNotifier.dispose() is
    // synchronous — so we fire it off without awaiting. This is the
    // standard pattern for async cleanup inside a sync dispose().
    final camController = _cameraController;
    if (camController != null) {
      camController.stopImageStream().catchError((_) {}).whenComplete(() {
        camController.dispose();
      });
    }
    _faceDetector.close();

    super.dispose();
  }
}
