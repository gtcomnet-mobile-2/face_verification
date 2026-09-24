import 'package:facetest/config/face_capture_config.dart';
import 'package:facetest/controller/face_capture_state.dart';
import 'package:facetest/global_widgets/top_bar.dart';
import 'package:flutter/material.dart';

/// Oval cutout used by [DefaultFaceOverlay] and the default step-progress ring.
Rect faceOvalRect(Size size) {
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height * 0.559),
    width: size.width * 0.75,
    height: size.width * 0.75,
  );
}

/// Default guide: an oval cutout that turns [config.primaryColor] when a
/// face is detected and [config.successColor] when the pose matches.
///
/// The filled hole is isolated from the stroke so pose-match color changes
/// don't rerasterize the full-screen cutout.
class DefaultFaceOverlay extends StatefulWidget {
  final FaceCaptureState state;
  final FaceCaptureConfig config;
  final VoidCallback? onClose;
  const DefaultFaceOverlay({
    super.key,
    required this.state,
    required this.config,
    this.onClose,
  });

  @override
  State<DefaultFaceOverlay> createState() => _DefaultFaceOverlayState();
}

class _DefaultFaceOverlayState extends State<DefaultFaceOverlay> {
  final showAudio = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.state.phase == FaceCapturePhase.poseMatched
        ? widget.config.successColor
        : (widget.state.faceDetected
              ? widget.config.primaryColor
              : Colors.white70);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _OvalCutoutPainter(
                    backgroundColor: widget.config.overlayBackgroundColor,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              CustomPaint(
                painter: _OvalBorderPainter(borderColor: borderColor),
                child: const SizedBox.expand(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TopBar(
                showSound: true,
                onClose: widget.onClose,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OvalCutoutPainter extends CustomPainter {
  final Color backgroundColor;

  _OvalCutoutPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = faceOvalRect(size);
    final cutoutPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addOval(ovalRect),
    );
    canvas.drawPath(cutoutPath, Paint()..color = backgroundColor);
  }

  @override
  bool shouldRepaint(covariant _OvalCutoutPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}

class _OvalBorderPainter extends CustomPainter {
  final Color borderColor;

  _OvalBorderPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      faceOvalRect(size),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _OvalBorderPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
