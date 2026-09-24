import 'dart:math' as math;

import 'package:facetest/default_face_overlay.dart';
import 'package:flutter/material.dart';

class OvalStepProgressPainter extends CustomPainter {
  static const double _strokeWidth = 6;
  static const double _inflateBy = 12;

  final double progress;
  final int total;
  final Color color;

  OvalStepProgressPainter({
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
  bool shouldRepaint(covariant OvalStepProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.total != total ||
      oldDelegate.color != color;
}
