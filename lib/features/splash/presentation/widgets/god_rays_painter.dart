import 'package:flutter/material.dart';
import 'dart:math' as math;

class GodRaysPainter extends CustomPainter {
  final Animation<double> animation;
  GodRaysPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 1.2,
        colors: [
          const Color(0xFFFFD700).withOpacity(0.2 * animation.value),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final center = Offset(size.width / 2, size.height * 0.3);
    const rayCount = 12;
    final maxRayLength = size.height;

    for (var i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount) + (animation.value * 0.1);
      final path = Path();
      path.moveTo(center.dx, center.dy);
      
      final x = center.dx + math.cos(angle) * maxRayLength;
      final y = center.dy + math.sin(angle) * maxRayLength;
      
      path.lineTo(x, y);
      path.lineTo(x + 50, y); // Width of ray
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
