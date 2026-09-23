import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:facetest/face_capture_config.dart';
import 'package:facetest/face_capture_cubit.dart';
import 'package:facetest/face_capture_state.dart';
import 'package:facetest/face_pose.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stts/stts.dart';

import 'default_face_overlay.dart';

/// Drop this into your app's navigation. It owns a [FaceCaptureController]
/// internally and renders entirely through [FaceCaptureConfig]'s builders —
/// the UI team edits the config, not this file.
///
/// No state-management package required — just a StatefulWidget holding a
/// ChangeNotifier, same pattern as owning a TextEditingController.
class FaceCaptureScreen extends StatefulWidget {
  final void Function(List<CapturedFaceImage> images)? onSuccess;
  final VoidCallback? onCancel;

  const FaceCaptureScreen({super.key, this.onSuccess, this.onCancel});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

/// Groups phases that share a widget tree so pose-match ticks don't rebuild
/// the camera preview or GIF.
enum _CaptureUi {
  initializing,
  permissionDenied,
  cameraError,
  capturing,
  uploading,
  uploadFailure,
  uploadSuccess,
}

_CaptureUi _uiFor(FaceCapturePhase phase) {
  return switch (phase) {
    FaceCapturePhase.initializing => _CaptureUi.initializing,
    FaceCapturePhase.permissionDenied => _CaptureUi.permissionDenied,
    FaceCapturePhase.cameraError => _CaptureUi.cameraError,
    FaceCapturePhase.uploading => _CaptureUi.uploading,
    FaceCapturePhase.uploadFailure => _CaptureUi.uploadFailure,
    FaceCapturePhase.uploadSuccess => _CaptureUi.uploadSuccess,
    FaceCapturePhase.ready ||
    FaceCapturePhase.poseMatched ||
    FaceCapturePhase.allCaptured => _CaptureUi.capturing,
  };
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late final FaceCaptureController _controller;

  // Tracks the last phase we reacted to, so side effects (like auto-submit)
  // fire exactly once per transition instead of on every rebuild.
  FaceCapturePhase? _lastHandledPhase;
  int? _lastSpokenStepIndex;
  Timer? _firstSpeakDelay;
  final FaceCaptureConfig config = const FaceCaptureConfig();
  final String userId = "";
  final Tts _tts = Tts();

  @override
  void initState() {
    super.initState();
    unawaited(FaceCaptureController.prepareCamera());
    _controller = FaceCaptureController(config: config);
    _controller.addListener(_handlePhaseSideEffects);
    unawaited(_controller.initialize());
  }

  void _handlePhaseSideEffects() {
    _maybeSpeakStep();

    final phase = _controller.state.phase;
    if (phase == _lastHandledPhase) return;
    _lastHandledPhase = phase;

    if (phase == FaceCapturePhase.allCaptured) {
      final images = List<CapturedFaceImage>.from(_controller.state.captured);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onSuccess?.call(images);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(images);
        }
      });
    }
  }

  void _maybeSpeakStep() {
    final state = _controller.state;
    final phase = state.phase;
    if (phase == FaceCapturePhase.initializing) {
      _lastSpokenStepIndex = null;
      return;
    }
    if (phase != FaceCapturePhase.ready &&
        phase != FaceCapturePhase.poseMatched) {
      return;
    }
    final index = state.currentStepIndex;
    if (_lastSpokenStepIndex == index) return;
    _lastSpokenStepIndex = index;
    final instruction = _controller.currentStep.instruction;
    if (index == 0 && phase == FaceCapturePhase.ready) {
      _firstSpeakDelay?.cancel();
      _firstSpeakDelay = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        unawaited(_tts.start(instruction));
      });
      return;
    }
    unawaited(_tts.start(instruction));
  }

  @override
  void dispose() {
    _firstSpeakDelay?.cancel();
    _controller.removeListener(_handlePhaseSideEffects);
    _controller.dispose();
    unawaited(_tts.stop());
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _ControllerSelect<_CaptureUi>(
        controller: _controller,
        selector: (state) => _uiFor(state.phase),
        builder: (context, ui) => _buildForUi(context, ui),
      ),
    );
  }

  Widget _buildForUi(BuildContext context, _CaptureUi ui) {
    final state = _controller.state;
    return switch (ui) {
      _CaptureUi.initializing => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      _CaptureUi.permissionDenied => _Message(
        text: 'Camera permission is required to verify your identity.',
        color: config.errorColor,
        onRetry: _controller.initialize,
      ),
      _CaptureUi.cameraError =>
        config.errorBuilder?.call(
              context,
              state.errorMessage ?? 'Camera error',
              _controller.retry,
            ) ??
            _Message(
              text:
                  state.errorMessage ?? 'Something went wrong with the camera.',
              color: config.errorColor,
              onRetry: _controller.retry,
            ),
      _CaptureUi.uploading => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      _CaptureUi.uploadFailure =>
        config.errorBuilder?.call(
              context,
              state.errorMessage ?? 'Upload failed',
              () => _controller.submit(userId: userId),
            ) ??
            _Message(
              text: state.errorMessage ?? 'Upload failed.',
              color: config.errorColor,
              onRetry: () => _controller.submit(userId: userId),
            ),
      _CaptureUi.uploadSuccess =>
        config.successBuilder?.call(context) ??
            Center(
              child: Icon(
                Icons.check_circle,
                color: config.successColor,
                size: 96,
              ),
            ),
      _CaptureUi.capturing => _CaptureBody(
        config: config,
        controller: _controller,
      ),
    };
  }
}

class _CaptureBody extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;

  const _CaptureBody({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _CameraLayer(controller: controller),
        _OverlayLayer(config: config, controller: controller),
        _ProgressLayer(config: config, controller: controller),
        _InstructionLayer(config: config, controller: controller),
        if (!config.autoCapture)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child:
                  config.captureButtonBuilder?.call(
                    context,
                    controller.captureCurrentStep,
                  ) ??
                  FloatingActionButton(
                    backgroundColor: config.primaryColor,
                    onPressed: controller.captureCurrentStep,
                    child: const Icon(Icons.camera_alt),
                  ),
            ),
          ),
      ],
    );
  }
}

class _CameraLayer extends StatelessWidget {
  final FaceCaptureController controller;

  const _CameraLayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _ControllerSelect<CameraController?>(
      controller: controller,
      selector: (state) => state.cameraController,
      builder: (context, camController) {
        return RepaintBoundary(
          child: camController != null && camController.value.isInitialized
              ? CameraPreview(camController)
              : const ColoredBox(color: Colors.black),
        );
      },
    );
  }
}

class _OverlayLayer extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;

  const _OverlayLayer({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _ControllerSelect<(FaceCapturePhase, bool, int)>(
      controller: controller,
      selector: (state) =>
          (state.phase, state.faceDetected, state.currentStepIndex),
      builder: (context, _) {
        return config.overlayBuilder?.call(context, controller.state) ??
            DefaultFaceOverlay(state: controller.state, config: config);
      },
    );
  }
}

class _ProgressLayer extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;

  const _ProgressLayer({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _ControllerSelect<int>(
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
          child: _DefaultProgress(
            completed: completed,
            total: controller.stepsCount,
            color: config.primaryColor,
          ),
        );
      },
    );
  }
}

class _InstructionLayer extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;

  const _InstructionLayer({required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 24,
      right: 24,
      child: _ControllerSelect<int>(
        controller: controller,
        selector: (state) => state.currentStepIndex,
        builder: (context, _) {
          final step = controller.currentStep;
          return config.instructionBuilder?.call(context, step) ??
              RepaintBoundary(
                child: _PoseGuideGif(assetPath: step.assetIcon!),
              );
        },
      ),
    );
  }
}

/// Pose GIFs live in this package. Host apps load them as
/// `packages/facetest/...`; running facetest itself uses `assets/...`.
class _PoseGuideGif extends StatefulWidget {
  final String assetPath;

  const _PoseGuideGif({required this.assetPath});

  @override
  State<_PoseGuideGif> createState() => _PoseGuideGifState();
}

class _PoseGuideGifState extends State<_PoseGuideGif> {
  static const _packageName = 'facetest';
  static String? _package;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resolvePackage());
  }

  Future<void> _resolvePackage() async {
    if (_package != null) {
      if (mounted) setState(() => _ready = true);
      return;
    }
    final assets = (await AssetManifest.loadFromAssetBundle(
      rootBundle,
    )).listAssets();
    _package = assets.any((asset) => asset.startsWith('packages/$_packageName/'))
        ? _packageName
        : '';
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(width: 100, height: 150);
    }
    return Image.asset(
      widget.assetPath,
      width: 100,
      height: 150,
      package: _package!.isEmpty ? null : _package,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      filterQuality: FilterQuality.low,
    );
  }
}

/// Rebuilds only when [selector] returns a different value.
class _ControllerSelect<T> extends StatefulWidget {
  final FaceCaptureController controller;
  final T Function(FaceCaptureState state) selector;
  final Widget Function(BuildContext context, T value) builder;

  const _ControllerSelect({
    required this.controller,
    required this.selector,
    required this.builder,
  });

  @override
  State<_ControllerSelect<T>> createState() => _ControllerSelectState<T>();
}

class _ControllerSelectState<T> extends State<_ControllerSelect<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.selector(widget.controller.state);
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(_ControllerSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
    final next = widget.selector(widget.controller.state);
    if (next != _value) {
      _value = next;
    }
  }

  void _handleChange() {
    final next = widget.selector(widget.controller.state);
    if (next == _value) return;
    setState(() => _value = next);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}

class _DefaultProgress extends StatelessWidget {
  final int completed;
  final int total;
  final Color color;

  const _DefaultProgress({
    required this.completed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final target = completed.clamp(0, total).toDouble();
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _OvalStepProgressPainter(
              progress: value,
              total: total,
              color: color,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _OvalStepProgressPainter extends CustomPainter {
  static const double _strokeWidth = 6;
  static const double _inflateBy = 12;

  final double progress;
  final int total;
  final Color color;

  _OvalStepProgressPainter({
    required this.progress,
    required this.total,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final rect = faceOvalRect(size).inflate(_inflateBy);
    final sweepPerStep = (math.pi * 2) / total;

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    canvas.drawOval(rect, trackPaint);

    for (var i = 0; i < total; i++) {
      final filled = (progress - i).clamp(0.0, 1.0);
      if (filled <= 0) continue;
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * sweepPerStep,
        sweepPerStep * filled,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OvalStepProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.total != total ||
      oldDelegate.color != color;
}

class _Message extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onRetry;

  const _Message({
    required this.text,
    required this.color,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: color, size: 48),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
