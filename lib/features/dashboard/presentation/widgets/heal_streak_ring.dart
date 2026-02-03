// Design Bible Reference: docs/DESIGN_BIBLE.md - Phase 3 (Liquid Heal Streak)
// Implements liquid fill progress ring with physics-based wave motion

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:remedibook/core/theme/remedi_theme.dart';

/// LiquidHealStreakPainter - Liquid fill progress ring with wave animation
/// 
/// Specification from Design Bible:
/// - Deep Teal fill (#1F4E5F)
/// - Splash and settle animation on progress change
/// - ElasticOut curve (tuned calm, no aggressive bounce)
/// - Wave motion using sine equation
/// - Reduce motion support (static fill)
class LiquidHealStreakPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double wavePhase; // Animation phase for wave motion
  final double waveHeight; // Wave amplitude (0.0 to 1.0)
  final bool reduceMotion; // Accessibility: disable wave animation

  LiquidHealStreakPainter({
    required this.progress,
    required this.wavePhase,
    this.waveHeight = 1.0,
    this.reduceMotion = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;

    // Background ring (subtle)
    final bgPaint = Paint()
      ..color = RemediTheme.mutedSage.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Liquid fill
    if (progress > 0) {
      _drawLiquidFill(canvas, center, radius);
    }

    // Outer ring border for definition
    final borderPaint = Paint()
      ..color = RemediTheme.deepTeal.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawLiquidFill(Canvas canvas, Offset center, double radius) {
    // Calculate fill level based on progress
    final fillLevel = progress;

    // Create clipping circle
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.clipPath(clipPath);

    // Calculate wave parameters
    final waveAmplitude = reduceMotion ? 0.0 : 8.0 * waveHeight;
    final frequency = 2.0; // Wave frequency

    // Create wave path
    final wavePath = Path();
    // Fix: 0% is at (center.dy + radius), 100% is at (center.dy - radius)
    final waveY = center.dy + radius - (fillLevel * 2 * radius);

    // Start from left edge
    wavePath.moveTo(center.dx - radius, waveY);

    // Draw wave using sine function
    for (double x = -radius; x <= radius; x += 2) {
      final normalizedX = x / radius; // -1 to 1
      final wave = math.sin((normalizedX * frequency * math.pi) + wavePhase) * waveAmplitude;
      final y = waveY + wave;
      wavePath.lineTo(center.dx + x, y);
    }

    // Complete the fill path
    wavePath.lineTo(center.dx + radius, center.dy + radius * 2);
    wavePath.lineTo(center.dx - radius, center.dy + radius * 2);
    wavePath.close();

    // Draw liquid fill
    final fillPaint = Paint()
      ..color = RemediTheme.deepTeal.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    canvas.drawPath(wavePath, fillPaint);

    // Add subtle gradient overlay for depth
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          RemediTheme.deepTeal.withOpacity(0.3),
          RemediTheme.deepTeal.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(wavePath, gradientPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LiquidHealStreakPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.wavePhase != wavePhase ||
      oldDelegate.waveHeight != waveHeight ||
      oldDelegate.reduceMotion != reduceMotion;
}

/// LiquidHealStreakRing - Stateful widget for animated liquid fill ring
/// 
/// Handles animation controllers for:
/// - Wave motion (continuous loop)
/// - Splash and settle on progress change (ElasticOut)
class LiquidHealStreakRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final bool reduceMotion;

  const LiquidHealStreakRing({
    super.key,
    required this.progress,
    this.size = 160,
    this.reduceMotion = false,
  });

  @override
  State<LiquidHealStreakRing> createState() => _LiquidHealStreakRingState();
}

class _LiquidHealStreakRingState extends State<LiquidHealStreakRing>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _splashController;
  late Animation<double> _wavePhaseAnimation;
  late Animation<double> _waveHeightAnimation;

  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Wave motion controller (continuous loop)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Slow, ceremonial wave
    );

    _wavePhaseAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi * 2, // Full wave cycle
    ).animate(_waveController);

    // Splash and settle controller (triggered on progress change)
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Design Bible: 0.8s
    );

    // ElasticOut curve tuned for calm motion (no aggressive bounce)
    _waveHeightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.elasticOut, // Tuned calm elastic
    ));

    _previousProgress = widget.progress;

    // Start wave animation (unless reduce motion)
    if (!widget.reduceMotion) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(LiquidHealStreakRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger splash animation on progress change
    if (widget.progress != _previousProgress && !widget.reduceMotion) {
      _splashController.forward(from: 0.0);
      _previousProgress = widget.progress;
    }

    // Handle reduce motion changes
    if (widget.reduceMotion != oldWidget.reduceMotion) {
      if (widget.reduceMotion) {
        _waveController.stop();
      } else {
        _waveController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _splashController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: LiquidHealStreakPainter(
            progress: widget.progress,
            wavePhase: _wavePhaseAnimation.value,
            waveHeight: _waveHeightAnimation.value,
            reduceMotion: widget.reduceMotion,
          ),
        );
      },
    );
  }
}

/// Legacy HealStreakPainter - Kept for backward compatibility
/// Use LiquidHealStreakPainter for new implementations
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
