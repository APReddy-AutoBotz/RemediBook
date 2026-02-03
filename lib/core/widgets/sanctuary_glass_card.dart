// Design Bible Reference: docs/DESIGN_BIBLE.md - Section D (Surfaces)
// Implements premium glassmorphism with BackdropFilter for depth and luxury

import 'dart:ui';
import 'package:flutter/material.dart';

/// SanctuaryGlassCard - Premium glassmorphism surface
/// 
/// Specification from Design Bible:
/// - BackdropFilter sigma 18 (soft, premium blur)
/// - Fill: White 12% opacity
/// - Border: White 25% opacity, 1.2px
/// - Corner radius: 24px (premium roundness)
/// - Shadow: Black 12%, blur 25, spread -2, offset (0, 8)
/// - Inner highlight: Top edge gradient stroke for realism
/// 
/// IMPORTANT: Only use on textured backgrounds (never solid color)
/// Performance: Limited to hero cards (not full-screen lists)
class SanctuaryGlassCard extends StatelessWidget {
  /// Child widget to display inside the glass card
  final Widget child;
  
  /// Optional padding inside the card
  final EdgeInsets? padding;
  
  /// Optional fixed width
  final double? width;
  
  /// Optional fixed height
  final double? height;
  
  /// Accessibility: disable blur for reduce motion
  final bool reduceMotion;
  
  /// Optional custom border radius (default: 24)
  final double borderRadius;

  const SanctuaryGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.reduceMotion = false,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Reduce motion variant: solid surface instead of glass
    if (reduceMotion) {
      return _buildSolidVariant();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // Design Bible: sigma 18
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // Glass fill: White 12% opacity
            color: Colors.white.withOpacity(0.12),
            
            // Border: White 25% opacity, 1.2px
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.2,
            ),
            
            borderRadius: BorderRadius.circular(borderRadius),
            
            // Shadow: Black 12%, blur 25, spread -2, offset (0, 8)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 25,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner highlight: Top edge gradient stroke for realism
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Content with optional padding
              if (padding != null)
                Padding(
                  padding: padding!,
                  child: child,
                )
              else
                child,
            ],
          ),
        ),
      ),
    );
  }

  /// Solid variant for reduce motion accessibility
  Widget _buildSolidVariant() {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        // Solid warm white instead of glass
        color: const Color(0xFFFFFDF8),
        
        // Same border and shadow for consistency
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// PaperSurface - Warm white surface for static content
/// 
/// Specification from Design Bible:
/// - Warm white (#FFFDF8)
/// - Border radius: 16px
/// - Shadow: Black 8%, blur 12, offset (0, 4)
/// 
/// Usage: Remedy cards, ingredient lists, static content
class PaperSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final double borderRadius;

  const PaperSurface({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8), // Warm white
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// InkSurface - Deep Teal surface for primary actions
/// 
/// Specification from Design Bible:
/// - Deep Teal (#1F4E5F)
/// - Border radius: 20px
/// - Shadow: Deep Teal 30%, blur 20, offset (0, 6)
/// 
/// Usage: Primary action buttons, active states, emphasis
class InkSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final double borderRadius;

  const InkSurface({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1F4E5F), // Deep Teal
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F4E5F).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
