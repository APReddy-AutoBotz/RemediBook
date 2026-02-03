import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/remedi_theme.dart';

/// SanctuaryBottomSheet - Glassmorphism Bottom Sheet
/// Implements frosted glass effect as per Design Bible specs
class SanctuaryBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;

  const SanctuaryBottomSheet({
    super.key,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.2,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 25,
                  spreadRadius: -2,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Inner highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
