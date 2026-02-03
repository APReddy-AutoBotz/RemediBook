// Design Bible Reference: docs/DESIGN_BIBLE.md - Section E (Motion System)
// Implements biophilic "breathing" background with 15-second inhale/exhale rhythm

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// BreathingBackground - Living, organic background with breath-like motion
/// 
/// Specification from Design Bible:
/// - 15-second loop (inhale/exhale rhythm)
/// - Soft mesh gradient: Limestone (#F2F0E6) ↔ Deep Limestone (#E8E5D5)
/// - Subtle drift: 2-4% movement
/// - Optional grain overlay for texture richness
/// 
/// Performance: Uses CustomPainter with cached repaints for 60fps on mid-range devices
class BreathingBackground extends StatefulWidget {
  /// Motion strength (0.0 = static, 1.0 = full motion)
  final double intensity;
  
  /// Enable subtle grain texture overlay
  final bool enableGrain;
  
  /// Accessibility: disable all motion
  final bool reduceMotion;

  const BreathingBackground({
    super.key,
    this.intensity = 1.0,
    this.enableGrain = true,
    this.reduceMotion = false,
  });

  @override
  State<BreathingBackground> createState() => _BreathingBackgroundState();
}

class _BreathingBackgroundState extends State<BreathingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    
    // 15-second breath cycle (Design Bible: Section E)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Gentle ease curve for breath-like motion
    _breathAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic, // Gentle Ease from Design Bible
    );

    // Start breathing loop (unless reduce motion is enabled)
    if (!widget.reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle reduce motion changes
    if (widget.reduceMotion && !oldWidget.reduceMotion) {
      _controller.stop();
      _controller.value = 0.5; // Neutral position
    } else if (!widget.reduceMotion && oldWidget.reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Breathing gradient background
        AnimatedBuilder(
          animation: _breathAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: BreathingGradientPainter(
                breathProgress: widget.reduceMotion ? 0.5 : _breathAnimation.value,
                intensity: widget.intensity,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Optional grain overlay for texture
        if (widget.enableGrain)
          Positioned.fill(
            child: GrainOverlay(),
          ),
      ],
    );
  }
}

/// Custom painter for breathing gradient mesh
/// Uses radial gradients with animated positions for organic movement
class BreathingGradientPainter extends CustomPainter {
  final double breathProgress; // 0.0 to 1.0 (inhale to exhale)
  final double intensity;

  // Design Bible color tokens
  static const Color limestone = Color(0xFFF2F0E6);
  static const Color deepLimestone = Color(0xFFE8E5D5);

  BreathingGradientPainter({
    required this.breathProgress,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Calculate drift based on breath progress (2-4% movement)
    final driftX = math.sin(breathProgress * 2 * math.pi) * 0.03 * intensity;
    final driftY = math.cos(breathProgress * 2 * math.pi) * 0.02 * intensity;

    // Create mesh gradient with multiple radial gradients
    // This creates organic, biophilic movement
    
    // Base gradient (full canvas)
    final baseGradient = RadialGradient(
      center: Alignment(driftX, driftY),
      radius: 1.5,
      colors: [
        deepLimestone,
        limestone,
      ],
      stops: const [0.0, 1.0],
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(rect);

    canvas.drawRect(rect, basePaint);

    // Overlay gradient for depth (subtle)
    final overlayGradient = RadialGradient(
      center: Alignment(-driftX * 0.5, -driftY * 0.5),
      radius: 1.2,
      colors: [
        limestone.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );

    final overlayPaint = Paint()
      ..shader = overlayGradient.createShader(rect)
      ..blendMode = BlendMode.overlay;

    canvas.drawRect(rect, overlayPaint);
  }

  @override
  bool shouldRepaint(BreathingGradientPainter oldDelegate) {
    // Only repaint if breath progress or intensity changed
    return oldDelegate.breathProgress != breathProgress ||
           oldDelegate.intensity != intensity;
  }
}

/// Grain overlay for visual texture richness
/// Subtle noise pattern at 5% opacity
class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GrainPainter(),
      size: Size.infinite,
    );
  }
}

/// Custom painter for grain texture
/// Uses random noise pattern for organic feel
class GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent grain

    // Draw random dots for grain effect
    // Optimized: Only draw visible grain (not full density)
    for (int i = 0; i < 500; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 0.8 + 0.2;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(GrainPainter oldDelegate) {
    // Grain is static, never repaint
    return false;
  }
}
