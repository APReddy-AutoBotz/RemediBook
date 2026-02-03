// Design Bible Reference: docs/DESIGN_BIBLE.md - Phase 6 (Artifact)
// Implements wax seal stamp animation for PDF generation confirmation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// WaxSealStampAnimation - Ceremonial seal animation for PDF confirmation
/// 
/// Specification from Design Bible:
/// - 3D-looking seal with gradients (Ember Gold)
/// - Scale-down animation (1.5 → 1.0)
/// - Rotation settle (5° → 0°)
/// - Haptic pulse at impact (heavy impact)
/// - Gentle ease curve (800ms)
/// - Reduce motion support
class WaxSealStampAnimation extends StatefulWidget {
  /// Size of the seal
  final double size;
  
  /// Callback when animation completes
  final VoidCallback? onComplete;
  
  /// Enable haptic feedback
  final bool enableHaptics;
  
  /// Accessibility: disable animations
  final bool reduceMotion;
  
  /// Auto-start animation on mount
  final bool autoStart;
  
  /// Custom seal icon (default: verified icon)
  final IconData? sealIcon;

  const WaxSealStampAnimation({
    super.key,
    this.size = 120,
    this.onComplete,
    this.enableHaptics = true,
    this.reduceMotion = false,
    this.autoStart = true,
    this.sealIcon,
  });

  @override
  State<WaxSealStampAnimation> createState() => _WaxSealStampAnimationState();
}

class _WaxSealStampAnimationState extends State<WaxSealStampAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Design Bible: 0.8s
    );

    // Scale animation: 1.5 → 1.0 (stamp coming down)
    _scaleAnimation = Tween<double>(
      begin: 1.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic, // Gentle ease
    ));

    // Rotation animation: 5° → 0° (settle)
    _rotationAnimation = Tween<double>(
      begin: 5 * math.pi / 180, // 5 degrees in radians
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    // Opacity animation: 0.0 → 1.0
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _controller.addListener(_checkForImpact);
    _controller.addStatusListener(_handleAnimationComplete);

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _checkForImpact() {
    // Trigger haptic at 80% completion (impact moment)
    if (_controller.value >= 0.8 && !_hasTriggeredHaptic && widget.enableHaptics) {
      _hasTriggeredHaptic = true;
      HapticFeedback.heavyImpact(); // Heavy impact for seal stamp
    }
  }

  void _handleAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete?.call();
    }
  }

  void _startAnimation() {
    if (widget.reduceMotion) {
      // Instant reveal for reduce motion
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  /// Manually trigger animation
  void start() {
    _hasTriggeredHaptic = false;
    _controller.reset();
    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _WaxSealPainter(
                  progress: _controller.value,
                  sealIcon: widget.sealIcon,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for 3D wax seal
class _WaxSealPainter extends CustomPainter {
  final double progress;
  final IconData? sealIcon;

  _WaxSealPainter({
    required this.progress,
    this.sealIcon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw 3D wax seal with gradients
    _drawWaxSeal(canvas, center, radius);
    
    // Draw seal icon/emblem
    _drawSealEmblem(canvas, center, radius);
  }

  void _drawWaxSeal(Canvas canvas, Offset center, double radius) {
    // Base wax circle with gradient (Ember Gold)
    final gradient = RadialGradient(
      colors: [
        const Color(0xFFD4A373), // Ember Gold (center)
        const Color(0xFFC89563), // Darker gold (edge)
        const Color(0xFFB8845D), // Even darker (outer edge)
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final waxPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, waxPaint);

    // Inner shadow for depth
    final innerShadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withOpacity(0.0),
          Colors.black.withOpacity(0.15),
        ],
        stops: const [0.6, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, innerShadowPaint);

    // Outer glow for premium feel
    final glowPaint = Paint()
      ..color = const Color(0xFFD4A373).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius + 5, glowPaint);

    // Embossed edge
    final edgePaint = Paint()
      ..color = const Color(0xFFE8D4B8).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius - 2, edgePaint);
  }

  void _drawSealEmblem(Canvas canvas, Offset center, double radius) {
    // Draw icon in center (simplified - in production use actual icon rendering)
    final iconPaint = Paint()
      ..color = const Color(0xFF1F4E5F).withOpacity(0.8) // Deep Teal
      ..style = PaintingStyle.fill;

    // Draw a simple verified/check emblem
    final iconRadius = radius * 0.4;
    
    // Outer circle
    final outerCirclePaint = Paint()
      ..color = const Color(0xFF1F4E5F).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, iconRadius, outerCirclePaint);

    // Inner verified icon (simplified checkmark)
    final checkPath = Path();
    final checkSize = iconRadius * 0.6;
    
    checkPath.moveTo(
      center.dx - checkSize * 0.3,
      center.dy,
    );
    checkPath.lineTo(
      center.dx - checkSize * 0.1,
      center.dy + checkSize * 0.3,
    );
    checkPath.lineTo(
      center.dx + checkSize * 0.4,
      center.dy - checkSize * 0.4,
    );

    final checkPaint = Paint()
      ..color = const Color(0xFF1F4E5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(checkPath, checkPaint);

    // Text: "VERIFIED" (simplified - in production use TextPainter)
    // This is a placeholder for the actual text rendering
  }

  @override
  bool shouldRepaint(covariant _WaxSealPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// WaxSealStampController - For manual control
class WaxSealStampController {
  final GlobalKey<_WaxSealStampAnimationState> _key = GlobalKey();

  GlobalKey<_WaxSealStampAnimationState> get key => _key;

  void start() {
    _key.currentState?.start();
  }
}

/// Example usage:
/// 
/// ```dart
/// // Auto-start animation
/// WaxSealStampAnimation(
///   size: 120,
///   onComplete: () {
///     print('PDF generated and sealed!');
///   },
/// )
/// 
/// // Manual control
/// final controller = WaxSealStampController();
/// 
/// WaxSealStampAnimation(
///   key: controller.key,
///   autoStart: false,
/// )
/// 
/// // Later, after PDF generation...
/// controller.start();
/// ```
