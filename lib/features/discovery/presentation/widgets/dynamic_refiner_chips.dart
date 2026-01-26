import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/remedi_theme.dart';

/// Refiner Chip Data Model
class RefinerChip {
  final String id;
  final String label;
  final IconData? icon;
  final bool isActive;

  const RefinerChip({
    required this.id,
    required this.label,
    this.icon,
    this.isActive = false,
  });

  RefinerChip copyWith({
    String? id,
    String? label,
    IconData? icon,
    bool? isActive,
  }) {
    return RefinerChip(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// DynamicRefinerChips - Agentic UI Component
/// Horizontal scrollable list of filter chips with haptic feedback
class DynamicRefinerChips extends StatefulWidget {
  final List<RefinerChip> refiners;
  final Function(String refinerId, bool isActive) onRefinerToggle;
  final EdgeInsetsGeometry? padding;

  const DynamicRefinerChips({
    super.key,
    required this.refiners,
    required this.onRefinerToggle,
    this.padding,
  });

  @override
  State<DynamicRefinerChips> createState() => _DynamicRefinerChipsState();
}

class _DynamicRefinerChipsState extends State<DynamicRefinerChips> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleChipTap(RefinerChip refiner) {
    // Haptic feedback for press-depth sensation
    HapticFeedback.mediumImpact();
    
    // Toggle the refiner
    widget.onRefinerToggle(refiner.id, !refiner.isActive);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ??
          const EdgeInsets.symmetric(
            horizontal: RemediTheme.spaceMD,
            vertical: RemediTheme.spaceSM,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: RemediTheme.spaceSM),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 16,
                  color: RemediTheme.deepTeal,
                ),
                const SizedBox(width: RemediTheme.spaceXS),
                Text(
                  'Refine Your Search',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: RemediTheme.deepTeal,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),

          // Scrollable Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.refiners.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: RemediTheme.spaceSM),
              itemBuilder: (context, index) {
                final refiner = widget.refiners[index];
                return _RefinerChipWidget(
                  refiner: refiner,
                  onTap: () => _handleChipTap(refiner),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual Refiner Chip Widget
class _RefinerChipWidget extends StatefulWidget {
  final RefinerChip refiner;
  final VoidCallback onTap;

  const _RefinerChipWidget({
    required this.refiner,
    required this.onTap,
  });

  @override
  State<_RefinerChipWidget> createState() => _RefinerChipWidgetState();
}

class _RefinerChipWidgetState extends State<_RefinerChipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.refiner.isActive;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: RemediTheme.spaceMD,
            vertical: RemediTheme.spaceSM,
          ),
          decoration: BoxDecoration(
            // Active: Deep Teal, Inactive: Warm Limestone
            color: isActive
                ? RemediTheme.deepTeal
                : RemediTheme.warmLimestone,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? RemediTheme.deepTeal
                  : RemediTheme.deepTeal.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: RemediTheme.deepTeal.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.refiner.icon != null) ...[
                Icon(
                  widget.refiner.icon,
                  size: 16,
                  color: isActive
                      ? RemediTheme.warmLimestone
                      : RemediTheme.deepTeal,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.refiner.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isActive
                          ? RemediTheme.warmLimestone
                          : RemediTheme.deepTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Predefined Refiner Sets
class RefinerPresets {
  /// Common dietary refiners
  static List<RefinerChip> dietary = [
    const RefinerChip(
      id: 'kid-safe',
      label: 'Kid-safe',
      icon: Icons.child_care,
    ),
    const RefinerChip(
      id: 'no-honey',
      label: 'No Honey',
      icon: Icons.block,
    ),
    const RefinerChip(
      id: 'vegan',
      label: 'Vegan',
      icon: Icons.eco,
    ),
    const RefinerChip(
      id: 'gluten-free',
      label: 'Gluten-Free',
      icon: Icons.grain,
    ),
  ];

  /// Time-based refiners
  static List<RefinerChip> timeBased = [
    const RefinerChip(
      id: '5-min-prep',
      label: '5-min prep',
      icon: Icons.timer,
    ),
    const RefinerChip(
      id: 'quick-relief',
      label: 'Quick Relief',
      icon: Icons.flash_on,
    ),
    const RefinerChip(
      id: 'overnight',
      label: 'Overnight',
      icon: Icons.nightlight,
    ),
  ];

  /// Ingredient-based refiners
  static List<RefinerChip> ingredients = [
    const RefinerChip(
      id: 'ginger',
      label: 'Ginger',
      icon: Icons.spa,
    ),
    const RefinerChip(
      id: 'tulsi',
      label: 'Tulsi',
      icon: Icons.local_florist,
    ),
    const RefinerChip(
      id: 'turmeric',
      label: 'Turmeric',
      icon: Icons.circle,
    ),
    const RefinerChip(
      id: 'honey',
      label: 'Honey',
      icon: Icons.water_drop,
    ),
  ];

  /// Get all refiners combined
  static List<RefinerChip> get all => [
        ...dietary,
        ...timeBased,
        ...ingredients,
      ];
}
