import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:facetest/config/face_capture_config.dart';
import 'package:facetest/face_pose.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

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

  FaceCaptureController({required this.config}) {
    _steps = config.resolvedSteps;
  }

  static Future<void>? _preloadFuture;
  static Future<void>? _detectorWarmFuture;
  static Future<List<CameraDescription>>? _camerasFuture;
  static FaceDetector? _sharedDetector;
  static Future<CameraController>? _cameraPrepareFuture;
  static CameraController? _preparedCamera;

  static const _guideAssets = [
    'assets/front.gif',
    'assets/left.gif',
    'assets/right.gif',
    'assets/up.gif',
    'assets/down.gif',
    'assets/smile.gif',
  ];

  static const _warmWidth = 640;
  static const _warmHeight = 480;
  static const _maxDetectWidth = 480;
  static const _skipInitialStreamFrames = 2;
  static const _previewSettleDelay = Duration(milliseconds: 200);

  static FaceDetectorOptions get _detectorOptions => FaceDetectorOptions(
    enableClassification: true,
    enableTracking: false,
    performanceMode: FaceDetectorMode.fast,
  );

  /// Loads camera names, pose GIFs, and the face-detection model.
  /// Call from app startup (after [runApp] or [WidgetsFlutterBinding.ensureInitialized])
  /// so the capture screen does not hitch on first open.
  static Future<void> preload() {
    return _preloadFuture ??= _preload();
  }

  /// Starts the front camera while the capture route is opening.
  /// Does not wait for GIF decode or ML Kit warmup.
  static Future<CameraController> prepareCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    _camerasFuture ??= availableCameras();
    unawaited(_ensureDetectorWarmed());
    unawaited(preload());
    final existing = _preparedCamera;
    if (existing != null && existing.value.isInitialized) {
      return existing;
    }
    return _cameraPrepareFuture ??= _openPreparedCamera();
  }

  static Future<void> _preload() async {
    WidgetsFlutterBinding.ensureInitialized();
    _camerasFuture ??= availableCameras();
    await Future.wait<void>([
      _camerasFuture!.then((_) {}),
      _ensureDetectorWarmed(),
      _preloadGuideAssets(),
    ]);
  }

  static Future<void> _ensureDetectorWarmed() {
    return _detectorWarmFuture ??= _warmDetector();
  }

  static Future<void> _warmDetector() async {
    final detector = _sharedDetector ??= FaceDetector(options: _detectorOptions);
    final isAndroid = Platform.isAndroid;
    final bytes = isAndroid
        ? Uint8List(_warmWidth * _warmHeight + (_warmWidth * _warmHeight ~/ 2))
        : Uint8List(_warmWidth * _warmHeight * 4);
    bytes.fillRange(0, bytes.length, 128);
    final image = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(_warmWidth.toDouble(), _warmHeight.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
        bytesPerRow: isAndroid ? _warmWidth : _warmWidth * 4,
      ),
    );
    try {
      await detector.processImage(image);
    } catch (_) {
      _detectorWarmFuture = null;
    }
  }

  static Future<void> _preloadGuideAssets() async {
    const config = ImageConfiguration();
    await Future.wait(
      _guideAssets.map((path) => _precacheGuideAsset(path, config)),
    );
  }

  static Future<void> _precacheGuideAsset(
    String path,
    ImageConfiguration config,
  ) async {
    for (final provider in [
      AssetImage(path, package: 'facetest'),
      AssetImage(path),
    ]) {
      if (await _precacheProvider(provider, config)) return;
    }
  }

  static Future<bool> _precacheProvider(
    ImageProvider provider,
    ImageConfiguration config,
  ) async {
    final stream = provider.resolve(config);
    final loaded = Completer<bool>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!loaded.isCompleted) loaded.complete(true);
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!loaded.isCompleted) loaded.complete(false);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return loaded.future;
  }

  static Future<CameraController> _openPreparedCamera() async {
    final cameras = await (_camerasFuture ?? availableCameras());
    if (cameras.isEmpty) {
      _cameraPrepareFuture = null;
      throw CameraException(
        'NoCamerasAvailable',
        'No camera is available on this device.',
      );
    }
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    try {
      await controller.initialize();
      _preparedCamera = controller;
      return controller;
    } catch (e) {
      _cameraPrepareFuture = null;
      _preparedCamera = null;
      try {
        await controller.dispose();
      } catch (_) {}
      rethrow;
    }
  }

  late final List<FacePoseStep> _steps;

  CameraController? _cameraController;
  bool _isDetecting = false;
  bool _isCapturing = false;
  int _streamFramesSkipped = 0;
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
    final current = _state;
    if (current.phase == newState.phase &&
        identical(current.cameraController, newState.cameraController) &&
        current.currentStepIndex == newState.currentStepIndex &&
        identical(current.captured, newState.captured) &&
        current.faceDetected == newState.faceDetected &&
        current.holdProgress == newState.holdProgress &&
        current.errorMessage == newState.errorMessage) {
      return;
    }
    _state = newState;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_disposed) return;
    _update(const FaceCaptureState());

    CameraController? camController;
    try {
      late final CameraController prepared;
      await Future.wait<void>([
        prepareCamera().then((c) => prepared = c),
        _ensureDetectorWarmed(),
      ]);
      camController = prepared;
      if (_disposed) {
        await _releaseCamera();
        return;
      }
      _cameraController = camController;
      _update(
        _state.copyWith(
          phase: FaceCapturePhase.ready,
          cameraController: camController,
        ),
      );

      await _waitForPreviewToSettle();
      if (_disposed) return;
      if (camController.value.isInitialized &&
          !camController.value.isStreamingImages) {
        _streamFramesSkipped = 0;
        await camController.startImageStream(_onCameraFrame);
      }
    } on CameraException catch (e) {
      if (_cameraController != camController) {
        try {
          await camController?.dispose();
        } catch (_) {}
      }
      if (_disposed) return;
      final denied =
          e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted';
      _update(
        _state.copyWith(
          phase: denied
              ? FaceCapturePhase.permissionDenied
              : FaceCapturePhase.cameraError,
          errorMessage: e.description ?? e.code,
        ),
      );
    } catch (e) {
      if (_cameraController != camController) {
        try {
          await camController?.dispose();
        } catch (_) {}
      }
      if (_disposed) return;
      _update(
        _state.copyWith(
          phase: FaceCapturePhase.cameraError,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _waitForPreviewToSettle() async {
    final binding = WidgetsBinding.instance;
    await binding.endOfFrame;
    await binding.endOfFrame;
    await Future<void>.delayed(_previewSettleDelay);
  }

  void _onCameraFrame(CameraImage image) {
    if (_disposed || _isDetecting || _isCapturing) return;
    if (_state.phase != FaceCapturePhase.ready &&
        _state.phase != FaceCapturePhase.poseMatched) {
      return;
    }
    if (_streamFramesSkipped < _skipInitialStreamFrames) {
      _streamFramesSkipped++;
      return;
    }
    // Copy / downsample now so the camera can recycle this frame. Holding the
    // original CameraImage across processImage() freezes the iOS preview
    // while the face-detection model loads.
    final inputImage = _toInputImage(image);
    if (inputImage == null) return;
    _isDetecting = true;
    _detectFace(inputImage).whenComplete(() => _isDetecting = false);
  }

  Future<void> _detectFace(InputImage inputImage) async {
    if (_disposed) return;

    final detector = _sharedDetector ??= FaceDetector(options: _detectorOptions);
    final faces = await detector.processImage(inputImage);
    if (_disposed) return;
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
      final alreadyMatched = _state.phase == FaceCapturePhase.poseMatched;
      if (!alreadyMatched || !_state.faceDetected) {
        _update(
          _state.copyWith(
            phase: FaceCapturePhase.poseMatched,
            faceDetected: true,
          ),
        );
      }
      if (!alreadyMatched) {
        _startHoldTimer();
      }
    } else {
      _holdTimer?.cancel();
      if (_state.phase != FaceCapturePhase.ready || !_state.faceDetected) {
        _update(
          _state.copyWith(phase: FaceCapturePhase.ready, faceDetected: true),
        );
      }
    }
  }

  bool _poseMatches(Face face, FacePose pose) {
    // Positive yaw = user turned toward their left (matches Android ML Kit).
    // iOS mirrors the front-camera stream, which flips that sign.
    var yaw = face.headEulerAngleY ?? 0;
    if (Platform.isIOS &&
        _cameraController?.description.lensDirection ==
            CameraLensDirection.front) {
      yaw = -yaw;
    }
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
      await _stopImageStream(camController);
      if (_disposed) return;
      final xfile = await camController.takePicture();
      if (_disposed) return;

      final updatedCaptured = [
        ..._state.captured,
        CapturedFaceImage(pose: currentStep.pose, file: File(xfile.path)),
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

      if (!isDone && !_disposed && !camController.value.isStreamingImages) {
        _streamFramesSkipped = 0;
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

    try {
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
    await _releaseCamera();
    if (_disposed) return;
    await initialize();
  }

  Future<void> _stopImageStream(CameraController controller) async {
    try {
      if (controller.value.isInitialized && controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } on CameraException catch (e) {
      if (e.code != 'No camera is streaming images') rethrow;
    } catch (_) {}
  }

  Future<void> _releaseCamera() async {
    final inFlight = _cameraPrepareFuture;
    final camController = _cameraController ?? _preparedCamera;
    _cameraController = null;
    _preparedCamera = null;
    _cameraPrepareFuture = null;

    CameraController? toDispose = camController;
    if (toDispose == null && inFlight != null) {
      try {
        toDispose = await inFlight;
      } catch (_) {
        return;
      }
    }
    if (toDispose == null) return;
    await _stopImageStream(toDispose);
    try {
      await toDispose.dispose();
    } catch (_) {}
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
      late final Uint8List bytes;
      late final int width;
      late final int height;
      late final int bytesPerRow;

      if (!Platform.isAndroid && image.width > _maxDetectWidth) {
        final factor = (image.width / _maxDetectWidth).ceil().clamp(1, 8);
        width = image.width ~/ factor;
        height = image.height ~/ factor;
        bytesPerRow = width * 4;
        bytes = _downsampleBgra(
          plane.bytes,
          image.width,
          image.height,
          plane.bytesPerRow,
          factor,
        );
      } else {
        bytes = Uint8List.fromList(plane.bytes);
        width = image.width;
        height = image.height;
        bytesPerRow = plane.bytesPerRow;
      }

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Uint8List _downsampleBgra(
    Uint8List src,
    int width,
    int height,
    int srcBytesPerRow,
    int factor,
  ) {
    final dw = width ~/ factor;
    final dh = height ~/ factor;
    final dst = Uint8List(dw * dh * 4);
    var di = 0;
    for (var y = 0; y < dh; y++) {
      final sy = y * factor * srcBytesPerRow;
      for (var x = 0; x < dw; x++) {
        final si = sy + x * factor * 4;
        if (si + 3 >= src.length) {
          di += 4;
          continue;
        }
        dst[di] = src[si];
        dst[di + 1] = src[si + 1];
        dst[di + 2] = src[si + 2];
        dst[di + 3] = src[si + 3];
        di += 4;
      }
    }
    return dst;
  }

  /// IMPORTANT: call this from your widget's `dispose()`, same as any
  /// other ChangeNotifier-based controller (e.g. a TextEditingController).
  @override
  void dispose() {
    _disposed = true;
    _holdTimer?.cancel();
    unawaited(_releaseCamera());
    super.dispose();
  }
}
