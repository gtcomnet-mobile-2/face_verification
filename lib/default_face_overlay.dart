import 'package:facetest/face_capture_config.dart';
import 'package:facetest/face_capture_state.dart';
import 'package:flutter/material.dart';

/// Oval cutout used by [DefaultFaceOverlay] and the default step-progress ring.
Rect faceOvalRect(Size size) {
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height * 0.42),
    width: size.width * 0.72,
    height: size.width * 0.72 * 1.3,
  );
}

/// Default guide: an oval cutout that turns [config.primaryColor] when a
/// face is detected and [config.successColor] when the pose matches.
///
/// The filled hole is isolated from the stroke so pose-match color changes
/// don't rerasterize the full-screen cutout.
class DefaultFaceOverlay extends StatelessWidget {
  final FaceCaptureState state;
  final FaceCaptureConfig config;

  const DefaultFaceOverlay({
    super.key,
    required this.state,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = state.phase == FaceCapturePhase.poseMatched
        ? config.successColor
        : (state.faceDetected ? config.primaryColor : Colors.white70);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _OvalCutoutPainter(
                backgroundColor: config.overlayBackgroundColor,
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
