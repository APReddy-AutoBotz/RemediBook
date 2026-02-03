import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/remedi_theme.dart';

/// SanctuaryToggleChip - Premium Toggle Control
/// Custom toggle chip with glass effect and inner glow
class SanctuaryToggleChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDisabled;
  final IconData? icon;

  const SanctuaryToggleChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.isDisabled = false,
    this.icon,
  });

  @override
  State<SanctuaryToggleChip> createState() => _SanctuaryToggleChipState();
}

class _SanctuaryToggleChipState extends State<SanctuaryToggleChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
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

  void _handleTap() {
    if (widget.isDisabled || widget.onTap == null) return;

    _scaleController.forward().then((_) => _scaleController.reverse());

    try {
      HapticFeedback.selectionClick();
    } catch (e) {
      // Platform doesn't support haptics
    }

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Colors.white.withOpacity(0.18)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(RemediTheme.radiusButton),
                border: Border.all(
                  color: widget.isSelected
                      ? RemediTheme.emberGold.withOpacity(0.6)
                      : Colors.white.withOpacity(0.25),
                  width: widget.isSelected ? 1.5 : 1.0,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: RemediTheme.emberGold.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isSelected
                          ? RemediTheme.emberGold
                          : RemediTheme.charcoal.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: widget.isSelected
                          ? RemediTheme.darkForest
                          : RemediTheme.charcoal.withOpacity(0.7),
                    ),
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
