import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/remedi_theme.dart';

/// SanctuaryButton - Premium Custom Button
/// Implements scale animation, shimmer effect, and haptic feedback
class SanctuaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;

  const SanctuaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
  });

  @override
  State<SanctuaryButton> createState() => _SanctuaryButtonState();
}

class _SanctuaryButtonState extends State<SanctuaryButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
    
    // Haptic feedback (safe fallback)
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Platform doesn't support haptics
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                gradient: widget.isPrimary
                    ? LinearGradient(
                        colors: [
                          RemediTheme.emberGold,
                          RemediTheme.emberGold.withOpacity(0.9),
                        ],
                      )
                    : null,
                color: widget.isPrimary 
                    ? null 
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(RemediTheme.radiusButton),
                border: Border.all(
                  color: widget.isPrimary
                      ? RemediTheme.emberGold
                      : Colors.white.withOpacity(0.3),
                  width: widget.isPrimary ? 0 : 1.5,
                ),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: RemediTheme.emberGold.withOpacity(0.3),
                          blurRadius: _isPressed ? 12 : 20,
                          offset: Offset(0, _isPressed ? 4 : 8),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect on press
                  if (_isPressed && widget.isPrimary)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(RemediTheme.radiusButton),
                        child: _ShimmerOverlay(),
                      ),
                    ),
                  
                  // Button content
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: widget.isPrimary
                              ? Colors.white
                              : RemediTheme.deepTeal,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: widget.isPrimary
                              ? Colors.white
                              : RemediTheme.deepTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// _ShimmerOverlay - Gold edge sweep effect
class _ShimmerOverlay extends StatefulWidget {
  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.0),
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: Container(
            color: Colors.white,
          ),
        );
      },
    );
  }
}
