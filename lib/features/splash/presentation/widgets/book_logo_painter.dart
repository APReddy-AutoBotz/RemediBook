import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class BookLogoPainter extends CustomPainter {
  final Animation<double> animation;
  
  BookLogoPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    
    // Draw 3D open book
    _drawOpenBook(canvas, center);
    
    // Draw sprouting leaves on top
    _drawLeaves(canvas, center);
  }

  void _drawOpenBook(Canvas canvas, Offset center) {
    const bookWidth = 200.0;
    const bookHeight = 140.0;
    const pageThickness = 8.0;
    
    // Ivory stone color palette
    final ivoryLight = Paint()..color = const Color(0xFFF5F3E7);
    final ivoryMid = Paint()..color = const Color(0xFFE8E4D0);
    final ivoryDark = Paint()..color = const Color(0xFFD4CFC1);
    final ivoryShadow = Paint()..color = const Color(0xFF9C9380);
    
    // Book spine (center)
    final spinePath = Path();
    spinePath.moveTo(center.dx, center.dy - bookHeight / 2);
    spinePath.lineTo(center.dx, center.dy + bookHeight / 2);
    canvas.drawPath(
      spinePath,
      Paint()
        ..color = ivoryShadow.color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke,
    );
    
    // Left page
    final leftPagePath = Path();
    leftPagePath.moveTo(center.dx, center.dy - bookHeight / 2);
    leftPagePath.quadraticBezierTo(
      center.dx - bookWidth / 3,
      center.dy - bookHeight / 4,
      center.dx - bookWidth / 2,
      center.dy,
    );
    leftPagePath.quadraticBezierTo(
      center.dx - bookWidth / 3,
      center.dy + bookHeight / 4,
      center.dx,
      center.dy + bookHeight / 2,
    );
    leftPagePath.close();
    
    // Left page gradient
    canvas.drawPath(
      leftPagePath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx - bookWidth / 2, center.dy),
          Offset(center.dx, center.dy),
          [ivoryMid.color, ivoryLight.color],
        ),
    );
    
    // Right page
    final rightPagePath = Path();
    rightPagePath.moveTo(center.dx, center.dy - bookHeight / 2);
    rightPagePath.quadraticBezierTo(
      center.dx + bookWidth / 3,
      center.dy - bookHeight / 4,
      center.dx + bookWidth / 2,
      center.dy,
    );
    rightPagePath.quadraticBezierTo(
      center.dx + bookWidth / 3,
      center.dy + bookHeight / 4,
      center.dx,
      center.dy + bookHeight / 2,
    );
    rightPagePath.close();
    
    // Right page gradient
    canvas.drawPath(
      rightPagePath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx, center.dy),
          Offset(center.dx + bookWidth / 2, center.dy),
          [ivoryLight.color, ivoryDark.color],
        ),
    );
    
    // Page edges (3D effect)
    canvas.drawPath(
      leftPagePath,
      Paint()
        ..color = ivoryShadow.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      rightPagePath,
      Paint()
        ..color = ivoryShadow.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    
    // Add page texture lines
    _drawPageLines(canvas, center, bookWidth, bookHeight, true);
    _drawPageLines(canvas, center, bookWidth, bookHeight, false);
  }

  void _drawPageLines(Canvas canvas, Offset center, double bookWidth, double bookHeight, bool isLeft) {
    final linePaint = Paint()
      ..color = const Color(0xFFD4CFC1).withOpacity(0.3)
      ..strokeWidth = 0.5;
    
    for (var i = 0; i < 8; i++) {
      final y = center.dy - bookHeight / 3 + (i * 15.0);
      final startX = isLeft ? center.dx - bookWidth / 2 + 20 : center.dx + 10;
      final endX = isLeft ? center.dx - 10 : center.dx + bookWidth / 2 - 20;
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        linePaint,
      );
    }
  }

  void _drawLeaves(Canvas canvas, Offset center) {
    final leafGreen = Paint()
      ..color = const Color(0xFF8FA998)
      ..style = PaintingStyle.fill;
    
    final leafDark = Paint()
      ..color = const Color(0xFF6B8575)
      ..style = PaintingStyle.fill;
    
    // Central stem
    canvas.drawLine(
      Offset(center.dx, center.dy - 70),
      Offset(center.dx, center.dy - 110),
      Paint()
        ..color = const Color(0xFF7A9085)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    
    // Left leaf
    final leftLeaf = Path();
    leftLeaf.moveTo(center.dx, center.dy - 100);
    leftLeaf.quadraticBezierTo(
      center.dx - 25,
      center.dy - 110,
      center.dx - 35,
      center.dy - 90,
    );
    leftLeaf.quadraticBezierTo(
      center.dx - 15,
      center.dy - 95,
      center.dx,
      center.dy - 100,
    );
    canvas.drawPath(leftLeaf, leafGreen);
    
    // Right leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(center.dx, center.dy - 100);
    rightLeaf.quadraticBezierTo(
      center.dx + 25,
      center.dy - 110,
      center.dx + 35,
      center.dy - 90,
    );
    rightLeaf.quadraticBezierTo(
      center.dx + 15,
      center.dy - 95,
      center.dx,
      center.dy - 100,
    );
    canvas.drawPath(rightLeaf, leafDark);
    
    // Top leaf
    final topLeaf = Path();
    topLeaf.moveTo(center.dx, center.dy - 110);
    topLeaf.quadraticBezierTo(
      center.dx - 10,
      center.dy - 130,
      center.dx,
      center.dy - 140,
    );
    topLeaf.quadraticBezierTo(
      center.dx + 10,
      center.dy - 130,
      center.dx,
      center.dy - 110,
    );
    canvas.drawPath(topLeaf, leafGreen);
    
    // Leaf veins
    final veinPaint = Paint()
      ..color = const Color(0xFF6B8575).withOpacity(0.5)
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset(center.dx, center.dy - 100),
      Offset(center.dx - 20, center.dy - 100),
      veinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 100),
      Offset(center.dx + 20, center.dy - 100),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BookLogoPainter oldDelegate) => true;
}
