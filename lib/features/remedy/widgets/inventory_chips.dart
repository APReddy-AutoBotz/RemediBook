// Design Bible Reference: docs/DESIGN_BIBLE.md - Phase 4 (Sovereign Triad 2.0)
// Implements interactive ingredient availability chips

import 'package:flutter/material.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';

/// InventoryChip - Interactive chip for ingredient availability tracking
/// 
/// Specification from Design Bible:
/// - Three states: Available (Deep Teal), Missing (Muted Sage), Selected (Ember Gold)
/// - Tap to toggle availability
/// - Gentle ease transition (800ms)
/// - Reduce motion support
class InventoryChip extends StatelessWidget {
  final String label;
  final InventoryStatus status;
  final VoidCallback? onTap;
  final bool reduceMotion;

  const InventoryChip({
    super.key,
    required this.label,
    required this.status,
    this.onTap,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: reduceMotion 
            ? Duration.zero 
            : const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic, // Gentle ease
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: colors.border,
            width: 1.5,
          ),
          boxShadow: status == InventoryStatus.selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4A373).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status icon
            Icon(
              _getIcon(),
              size: 16,
              color: colors.text,
            ),
            const SizedBox(width: 8),
            
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.text,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ChipColors _getColors() {
    switch (status) {
      case InventoryStatus.available:
        return _ChipColors(
          background: RemediTheme.deepTeal.withOpacity(0.1),
          border: RemediTheme.deepTeal.withOpacity(0.3),
          text: RemediTheme.deepTeal,
        );
      case InventoryStatus.missing:
        return _ChipColors(
          background: RemediTheme.mutedSage.withOpacity(0.08),
          border: RemediTheme.mutedSage.withOpacity(0.2),
          text: RemediTheme.mutedSage,
        );
      case InventoryStatus.selected:
        return _ChipColors(
          background: const Color(0xFFD4A373).withOpacity(0.15),
          border: const Color(0xFFD4A373),
          text: const Color(0xFFD4A373),
        );
    }
  }

  IconData _getIcon() {
    switch (status) {
      case InventoryStatus.available:
        return Icons.check_circle_outline;
      case InventoryStatus.missing:
        return Icons.remove_circle_outline;
      case InventoryStatus.selected:
        return Icons.shopping_cart_outlined;
    }
  }
}

/// Inventory status enum
enum InventoryStatus {
  available,  // User has this ingredient
  missing,    // User needs to purchase
  selected,   // Selected for cart
}

/// InventoryChipList - Wrapper for multiple inventory chips
/// 
/// Handles state management and cart building
class InventoryChipList extends StatefulWidget {
  final List<IngredientItem> ingredients;
  final Function(List<IngredientItem>)? onSelectionChanged;
  final bool reduceMotion;

  const InventoryChipList({
    super.key,
    required this.ingredients,
    this.onSelectionChanged,
    this.reduceMotion = false,
  });

  @override
  State<InventoryChipList> createState() => _InventoryChipListState();
}

class _InventoryChipListState extends State<InventoryChipList> {
  late Map<String, InventoryStatus> _statusMap;

  @override
  void initState() {
    super.initState();
    _statusMap = {
      for (var item in widget.ingredients)
        item.id: item.initialStatus,
    };
  }

  void _toggleStatus(IngredientItem item) {
    setState(() {
      final currentStatus = _statusMap[item.id]!;
      
      // Cycle: missing → selected → available → missing
      switch (currentStatus) {
        case InventoryStatus.missing:
          _statusMap[item.id] = InventoryStatus.selected;
          break;
        case InventoryStatus.selected:
          _statusMap[item.id] = InventoryStatus.available;
          break;
        case InventoryStatus.available:
          _statusMap[item.id] = InventoryStatus.missing;
          break;
      }
    });

    // Notify parent of selection changes
    final selectedItems = widget.ingredients
        .where((item) => _statusMap[item.id] == InventoryStatus.selected)
        .toList();
    widget.onSelectionChanged?.call(selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: widget.ingredients.map((item) {
        return InventoryChip(
          label: item.name,
          status: _statusMap[item.id]!,
          onTap: () => _toggleStatus(item),
          reduceMotion: widget.reduceMotion,
        );
      }).toList(),
    );
  }
}

/// Ingredient item model
class IngredientItem {
  final String id;
  final String name;
  final String? vernacularName; // Local language name
  final InventoryStatus initialStatus;
  final String? productUrl; // For deep linking

  const IngredientItem({
    required this.id,
    required this.name,
    this.vernacularName,
    this.initialStatus = InventoryStatus.missing,
    this.productUrl,
  });
}

/// Helper class for chip colors
class _ChipColors {
  final Color background;
  final Color border;
  final Color text;

  _ChipColors({
    required this.background,
    required this.border,
    required this.text,
  });
}
