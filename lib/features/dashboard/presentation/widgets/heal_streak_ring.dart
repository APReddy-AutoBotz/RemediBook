import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:remedibook/core/theme/remedi_theme.dart';

class HealStreakPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final double sweepAlpha;

  HealStreakPainter({
    required this.progress, 
    required this.pulse,
    this.sweepAlpha = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * (0.85 + (pulse * 0.05));
    
    // Background Glow - More subtle for premium feel
    final glowPaint = Paint()
      ..color = RemediTheme.deepTeal.withOpacity(0.02 + (pulse * 0.03))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius + 5, glowPaint);

    // Background Ring - Thinner (Stroke 8 instead of 14)
    final bgPaint = Paint()
      ..color = RemediTheme.mutedSage.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Active Progress Ring - Thinner
    final progressPaint = Paint()
      ..color = RemediTheme.deepTeal.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final currentSweep = 2 * math.pi * progress * sweepAlpha;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      currentSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HealStreakPainter oldDelegate) => 
    oldDelegate.progress != progress || 
    oldDelegate.pulse != pulse || 
    oldDelegate.sweepAlpha != sweepAlpha;
}
