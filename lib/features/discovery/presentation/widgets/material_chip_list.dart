import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../domain/models/fulfillment_models.dart';

/// Interactive Material Chip List
/// Pillar 3: The Pantry First Rule
/// 
/// Allows users to toggle materials between "Needed" and "In House"

class MaterialChipList extends StatefulWidget {
  final List<IngredientStatus> materials;
  final void Function(List<String> inHouseItems) onInventoryChanged;

  const MaterialChipList({
    super.key,
    required this.materials,
    required this.onInventoryChanged,
  });

  @override
  State<MaterialChipList> createState() => _MaterialChipListState();
}

class _MaterialChipListState extends State<MaterialChipList> {
  final Set<String> _inHouseItems = {};

  void _toggleItem(String itemName) {
    setState(() {
      if (_inHouseItems.contains(itemName)) {
        _inHouseItems.remove(itemName);
      } else {
        _inHouseItems.add(itemName);
        // Success pulse haptic for "In House"
        HapticFeedback.lightImpact();
      }
    });
    
    // Notify parent of inventory change
    widget.onInventoryChanged(_inHouseItems.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.materials.map<Widget>((item) {
        final isInHouse = _inHouseItems.contains(item.name);
        
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInHouse)
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.green.shade700,
                ),
              if (isInHouse) const SizedBox(width: 4),
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isInHouse 
                      ? Colors.green.shade900 
                      : Colors.red.shade900,
                ),
              ),
            ],
          ),
          selected: isInHouse,
          onSelected: (_) => _toggleItem(item.name),
          backgroundColor: isInHouse
              ? const Color(0xFFF0FDF4) // Soft green
              : const Color(0xFFFEF2F2), // Soft red
          selectedColor: const Color(0xFFF0FDF4),
          checkmarkColor: Colors.green.shade700,
          side: BorderSide(
            color: isInHouse 
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          labelPadding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
