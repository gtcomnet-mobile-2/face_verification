import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:facetest/face_capture_config.dart';
import 'package:facetest/face_capture_cubit.dart';
import 'package:facetest/face_capture_state.dart';
import 'package:facetest/face_pose.dart';
import 'package:facetest/face_verification_repository.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';

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

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late final FaceCaptureController _controller;

  // Tracks the last phase we reacted to, so side effects (like auto-submit)
  // fire exactly once per transition instead of on every rebuild.
  FaceCapturePhase? _lastHandledPhase;
  final FaceCaptureConfig config = FaceCaptureConfig();
  // final FaceVerificationRepository repository = FaceVerificationRepository
  final String userId = "";
  @override
  void initState() {
    super.initState();
    _controller = FaceCaptureController(config: config);
    _controller.addListener(_handlePhaseSideEffects);
    _controller.initialize();
  }

  void _handlePhaseSideEffects() {
    final phase = _controller.state.phase;
    if (phase == _lastHandledPhase) return;
    _lastHandledPhase = phase;

    if (phase == FaceCapturePhase.allCaptured) {
      _controller.submit(userId: userId);
    } else if (phase == FaceCapturePhase.uploadSuccess) {
      widget.onSuccess?.call(_controller.state.captured);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handlePhaseSideEffects);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // ListenableBuilder is built into Flutter (foundation.dart) — it
      // rebuilds this subtree every time _controller calls notifyListeners().
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildForPhase(context),
      ),
    );
  }

  Widget _buildForPhase(BuildContext context) {
    final state = _controller.state;
    final config = FaceCaptureConfig();

    switch (state.phase) {
      case FaceCapturePhase.initializing:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );

      case FaceCapturePhase.permissionDenied:
        return _Message(
          text: 'Camera permission is required to verify your identity.',
          color: config.errorColor,
          onRetry: _controller.initialize,
        );

      case FaceCapturePhase.cameraError:
        return config.errorBuilder?.call(
              context,
              state.errorMessage ?? 'Camera error',
              _controller.retry,
            ) ??
            _Message(
              text:
                  state.errorMessage ?? 'Something went wrong with the camera.',
              color: config.errorColor,
              onRetry: _controller.retry,
            );

      case FaceCapturePhase.uploading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );

      case FaceCapturePhase.uploadFailure:
        return config.errorBuilder?.call(
              context,
              state.errorMessage ?? 'Upload failed',
              () => _controller.submit(userId: userId),
            ) ??
            _Message(
              text: state.errorMessage ?? 'Upload failed.',
              color: config.errorColor,
              onRetry: () => _controller.submit(userId: userId),
            );

      case FaceCapturePhase.uploadSuccess:
        return config.successBuilder?.call(context) ??
            Center(
              child: Icon(
                Icons.check_circle,
                color: config.successColor,
                size: 96,
              ),
            );

      case FaceCapturePhase.ready:
      case FaceCapturePhase.poseMatched:
      case FaceCapturePhase.allCaptured:
        return _CaptureBody(
          config: config,
          state: state,
          controller: _controller,
        );
    }
  }
}

class _CaptureBody extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureState state;
  final FaceCaptureController controller;

  const _CaptureBody({
    required this.config,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final camController = state.cameraController;
    final step = controller.currentStep;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (camController != null && camController.value.isInitialized)
          CameraPreview(camController)
        else
          const ColoredBox(color: Colors.black),

        // Overlay guide (fully replaceable)
        config.overlayBuilder?.call(context, state) ??
            DefaultFaceOverlay(state: state, config: config),

        // Progress indicator (fully replaceable). Custom builders keep the
        // original top-bar slot; the default is a ring around the face oval.
        if (config.progressBuilder != null)
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: config.progressBuilder!(
              context,
              state.captured.length,
              controller.stepsCount,
            ),
          )
        else
          _DefaultProgress(
            completed: state.captured.length,
            total: controller.stepsCount,
            color: config.primaryColor,
          ),
        Positioned(
          bottom: 100,
          left: 24,
          right: 24,
          child:
              config.instructionBuilder?.call(context, step) ??
              Image.asset(step.assetIcon!, width: 100, height: 150),
        ),

        // Manual capture button, only if autoCapture is off
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

class _DefaultInstruction extends StatelessWidget {
  final String text;
  _DefaultInstruction({required this.text});
  TextToSpeech tts = TextToSpeech();

  Future<List<String>?> getVoices() async {
    // List<String>? voices = await tts.getVoice();

    // String language = 'en-US';
    // List<String>? voices = await tts.getVoiceByLang(language);

    // final code = await tts.getLanguageCodeByName('Japan');
    // tts.setLanguage(code!);
  }




  @override
  Widget build(BuildContext context) {
    // getVoices();
    // final player = AudioPlayer();
    // await player.play(UrlSourc.com/my-a));
    tts.speak(text);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
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
