import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:remedibook/core/motion/motion_prefs.dart';

class DigitalWaxSeal extends StatefulWidget {
  final bool animate;
  final VoidCallback? onAnimationComplete;

  const DigitalWaxSeal({
    super.key,
    this.animate = true,
    this.onAnimationComplete,
  });

  @override
  State<DigitalWaxSeal> createState() => _DigitalWaxSealState();
}

class _DigitalWaxSealState extends State<DigitalWaxSeal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _setupAnimations();

    if (widget.animate && MotionPrefs.isMotionEnabled.value) {
      _playAnimation();
    } else {
      _controller.value = 1.0; // Skip to end
    }
  }

  void _setupAnimations() {
    // 1. Scale: 0.6 -> 1.0 (Elastic but gentle)
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut), // Gentle elastic
      ),
    );

    // 2. Rotation: -6 degrees -> 0 degrees (Settling)
    _rotationAnimation = Tween<double>(begin: -6 * (math.pi / 180), end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // 3. Translate/Stamp: "Pressing down" effect
    // We simulate a press by slight scale down then up or slight y-axis jolt
    // Let's use a shadow spread animation instead for the "press" feeling
  }

  Future<void> _playAnimation() async {
    // Wait for "Stamp" moment
    // In our sequence, the stamp hits hard at start or near start?
    // Let's make it hit at 0.3
    
    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });

    // Haptic timing - hitting when scale bounces
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: _buildSealVisual(),
          ),
        );
      },
    );
  }

  Widget _buildSealVisual() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Wax Color Gradient
        gradient: const RadialGradient(
          colors: [
            Color(0xFFD32F2F), // Red 700
            Color(0xFFB71C1C), // Red 900
          ],
          center: Alignment(-0.2, -0.2), // Light source top-left
          radius: 1.2,
        ),
        // 3D Shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(4, 6),
          ),
          // Inner highlight for embossed rim
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(-2, -2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Center(
        child: Container(
          // Inner stamped area
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8E0000), // Darker rim
              width: 2,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                 Color(0xFFB71C1C),
                 Color(0xFFD32F2F),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline, 
                size: 32, 
                color: Colors.white.withOpacity(0.9)
              ),
              const SizedBox(height: 4),
              Text(
                "VERIFIED", // Simplified label
                style: GoogleFonts.cinzel( // Serif, engraved look
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
