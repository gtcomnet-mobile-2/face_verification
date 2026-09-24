import 'dart:async';

import 'package:facetest/capture_body.dart';
import 'package:facetest/config/app_enum.dart';
import 'package:facetest/config/face_capture_config.dart';
import 'package:facetest/controller/face_capture_cubit.dart';
import 'package:facetest/controller/face_capture_state.dart';
import 'package:facetest/controller/repo.dart';
import 'package:facetest/controller_select.dart';
import 'package:facetest/face_pose.dart';
import 'package:facetest/message.dart';
import 'package:flutter/material.dart';
import 'package:stts/stts.dart';

class FaceCaptureScreen extends StatefulWidget {
  final void Function(List<CapturedFaceImage> images)? onSuccess;
  final VoidCallback? onCancel;

  const FaceCaptureScreen({super.key, this.onSuccess, this.onCancel});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late final FaceCaptureController _controller;

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
    if (!Repo.isSoundOn) return;

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
      body: ControllerSelect<CaptureUi>(
        controller: _controller,
        selector: (state) => uiFor(state.phase),
        builder: (context, ui) => _buildForUi(context, ui),
      ),
    );
  }

  Widget _buildForUi(BuildContext context, CaptureUi ui) {
    final state = _controller.state;
    return switch (ui) {
      CaptureUi.initializing => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      CaptureUi.permissionDenied => Message(
        text: 'Camera permission is required to verify your identity.',
        color: config.errorColor,
        onRetry: _controller.initialize,
      ),
      CaptureUi.cameraError =>
        config.errorBuilder?.call(
              context,
              state.errorMessage ?? 'Camera error',
              _controller.retry,
            ) ??
            Message(
              text:
                  state.errorMessage ?? 'Something went wrong with the camera.',
              color: config.errorColor,
              onRetry: _controller.retry,
            ),
      CaptureUi.uploading => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      CaptureUi.uploadFailure =>
        config.errorBuilder?.call(
              context,
              state.errorMessage ?? 'Upload failed',
              () => _controller.submit(userId: userId),
            ) ??
            Message(
              text: state.errorMessage ?? 'Upload failed.',
              color: config.errorColor,
              onRetry: () => _controller.submit(userId: userId),
            ),
      CaptureUi.uploadSuccess =>
        config.successBuilder?.call(context) ??
            Center(
              child: Icon(
                Icons.check_circle,
                color: config.successColor,
                size: 96,
              ),
            ),
      CaptureUi.capturing => CaptureBody(
        config: config,
        controller: _controller,
        onClose: () {
          widget.onCancel?.call();
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
    };
  }
}
