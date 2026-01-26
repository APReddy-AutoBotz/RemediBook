import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class EnhancedGodRaysPainter extends CustomPainter {
  final Animation<double> animation;
  
  EnhancedGodRaysPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.35);
    
    // Dark mossy forest background (out of focus)
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size.height * 0.6,
        [
          const Color(0xFF0A1810).withOpacity(0.95), // Dark forest green
          const Color(0xFF1A2820).withOpacity(0.9),
          const Color(0xFF0F1A14).withOpacity(0.95),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Offset.zero & size, bgPaint);
    
    // Volumetric god rays (ethereal golden light from top)
    _drawVolumetricRays(canvas, size, center);
    
    // Dust motes in the air
    _drawDustMotes(canvas, size, center);
    
    // Subtle vignette for depth
    _drawVignette(canvas, size);
  }

  void _drawVolumetricRays(Canvas canvas, Size size, Offset center) {
    const rayCount = 16;
    final maxLength = size.height * 1.2;
    
    for (var i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount) + (animation.value * 0.05);
      final rayWidth = 20.0 + (math.sin(animation.value * 2 * math.pi + i) * 10);
      
      // Create volumetric effect with gradient
      final path = Path();
      final rayStart = Offset(center.dx, -50);
      final rayEndX = center.dx + math.cos(angle) * maxLength;
      final rayEndY = center.dy + math.sin(angle) * maxLength;
      
      path.moveTo(rayStart.dx - rayWidth / 2, rayStart.dy);
      path.lineTo(rayEndX - rayWidth, rayEndY);
      path.lineTo(rayEndX + rayWidth, rayEndY);
      path.lineTo(rayStart.dx + rayWidth / 2, rayStart.dy);
      path.close();
      
      final rayPaint = Paint()
        ..shader = ui.Gradient.linear(
          rayStart,
          Offset(rayEndX, rayEndY),
          [
            Color(0xFFFFD700).withOpacity(0.15 * animation.value), // Golden
            Color(0xFFFFA500).withOpacity(0.08 * animation.value),
            Colors.transparent,
          ],
          [0.0, 0.3, 1.0],
        )
        ..blendMode = BlendMode.plus;
      
      canvas.drawPath(path, rayPaint);
    }
    
    // Central glow around logo area
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        150,
        [
          Color(0xFFFFD700).withOpacity(0.25 * animation.value),
          Color(0xFFFFA500).withOpacity(0.12 * animation.value),
          Colors.transparent,
        ],
      )
      ..blendMode = BlendMode.plus;
    
    canvas.drawCircle(center, 200, glowPaint);
  }

  void _drawDustMotes(Canvas canvas, Size size, Offset center) {
    final random = math.Random(42); // Seeded for consistency
    final dustPaint = Paint()
      ..color = Color(0xFFFFD700).withOpacity(0.4)
      ..blendMode = BlendMode.plus;
    
    for (var i = 0; i < 40; i++) {
      // Create floating dust particles in the light beams
      final x = size.width * (random.nextDouble() * 0.6 + 0.2);
      final offset = (animation.value * 2 * math.pi + i * 0.5) % (2 * math.pi);
      final y = (size.height * random.nextDouble() + offset * 50) % size.height;
      final moteSize = 1.0 + random.nextDouble() * 2.5;
      
      // Only show motes in lit areas
      final distanceFromCenter = math.sqrt(
        math.pow(x - center.dx, 2) + math.pow(y - center.dy, 2)
      );
      
      if (distanceFromCenter < 300) {
        final motePaint = Paint()
          ..color = Color(0xFFFFD700).withOpacity(
            0.3 * (1 - distanceFromCenter / 300) * animation.value
          )
          ..blendMode = BlendMode.plus;
        
        canvas.drawCircle(Offset(x, y), moteSize, motePaint);
      }
    }
  }

  void _drawVignette(Canvas canvas, Size size) {
    final vignettePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height / 2),
        size.height * 0.6,
        [
          Colors.transparent,
          const Color(0xFF000000).withOpacity(0.5),
        ],
        [0.5, 1.0],
      );
    
    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant EnhancedGodRaysPainter oldDelegate) => true;
}
