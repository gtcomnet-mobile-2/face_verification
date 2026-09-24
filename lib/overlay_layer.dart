import 'package:facetest/config/face_capture_config.dart';
import 'package:facetest/controller/face_capture_cubit.dart';
import 'package:facetest/controller/face_capture_state.dart';
import 'package:facetest/controller_select.dart';
import 'package:facetest/default_face_overlay.dart';
import 'package:flutter/material.dart';

class OverlayLayer extends StatefulWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;
  final VoidCallback? onClose;
  const OverlayLayer({super.key, 
    required this.config,
    required this.controller,
    this.onClose,
  });

  @override
  State<OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends State<OverlayLayer> {
  @override
  Widget build(BuildContext context) {
    return ControllerSelect<(FaceCapturePhase, bool, int)>(
      controller: widget.controller,
      selector: (state) =>
          (state.phase, state.faceDetected, state.currentStepIndex),
      builder: (context, _) {
        return widget.config.overlayBuilder?.call(
              context,
              widget.controller.state,
            ) ??
            DefaultFaceOverlay(
              state: widget.controller.state,
              config: widget.config,
            );
      },
    );
  }
}
