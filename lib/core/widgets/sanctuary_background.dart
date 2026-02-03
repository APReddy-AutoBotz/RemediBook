import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/remedi_theme.dart';
// import '../motion/rive_loader.dart'; // Rive disabled for stability
import 'dart:math' as math;

/// SanctuaryBackground - The living canvas of the app.
/// Renders a Rive atmosphere if available/enabled, or a fallback Mesh Gradient.
class SanctuaryBackground extends StatelessWidget {
  final Widget child;
  final String? riveAssetPath;
  
  const SanctuaryBackground({
    super.key,
    required this.child,
    this.riveAssetPath = AssetPaths.atmosphereRive, // Safe default
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure Scaffold is transparent so the stack behind it shows
      // But here we are Wrapping the content.
      // Usually this widget is used AS the Scaffold body or WRAPS the Scaffold.
      // If wrapping Scaffold, Scaffold needs transparent opacity.
      backgroundColor: RemediTheme.cashmere, // Fallback solid color
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Living Layer (Mesh Gradient ONLY - Rive Removed for Stability)
          const RepaintBoundary(
            child: _SanctuaryMeshGradient(),
          ),

          // 2. Content Layer
          child,
        ],
      ),
    );
  }
}

/// _SanctuaryMeshGradient - Subtle breathing gradient fallback
class _SanctuaryMeshGradient extends StatefulWidget {
  const _SanctuaryMeshGradient();

  @override
  State<_SanctuaryMeshGradient> createState() => _SanctuaryMeshGradientState();
}

class _SanctuaryMeshGradientState extends State<_SanctuaryMeshGradient> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 15s loop for "Clinical Calm" (Design Bible)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                RemediTheme.cashmere,
                RemediTheme.warmLimestone,
                // Subtle Sage influence breathing in/out
                Color.lerp(
                  RemediTheme.warmLimestone, 
                  RemediTheme.mutedSage.withOpacity(0.15), 
                  _controller.value
                )!,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }
}
