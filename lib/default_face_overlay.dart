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
///overlayBackgroundColor
/// This whole widget is skipped entirely if the UI team supplies
/// [FaceCaptureConfig.overlayBuilder] — swap in an SVG mask, a square
/// frame, a custom shader, whatever the design calls for.
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
      child: CustomPaint(
        painter: _OvalOverlayPainter(
          borderColor: borderColor,
          backgroundColor: config.overlayBackgroundColor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _OvalOverlayPainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;

  _OvalOverlayPainter({
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = faceOvalRect(size);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final cutoutPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      ovalPath,
    );

    canvas.drawPath(cutoutPath, Paint()..color = backgroundColor);

    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _OvalOverlayPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
