import 'package:facetest/oval_step_progress.dart';
import 'package:flutter/material.dart';

class DefaultProgress extends StatelessWidget {
  final int completed;
  final int total;
  final Color color;

  const DefaultProgress({
    super.key,
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
            painter: OvalStepProgressPainter(
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
