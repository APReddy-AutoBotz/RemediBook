import 'package:flutter/material.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';

class RefinerChips extends StatefulWidget {
  final Function(String) onSelected;
  const RefinerChips({super.key, required this.onSelected});

  @override
  State<RefinerChips> createState() => _RefinerChipsState();
}

class _RefinerChipsState extends State<RefinerChips> {
  String _selectedRefiner = 'All';
  final List<String> _refiners = ['All', 'Kid-safe', 'No Honey', 'Quick Prep', 'Antiviral'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _refiners.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = _selectedRefiner == _refiners[index];
          return ChoiceChip(
            label: Text(_refiners[index]),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedRefiner = _refiners[index]);
              widget.onSelected(_refiners[index]);
            },
            selectedColor: RemediTheme.deepTeal,
            backgroundColor: RemediTheme.warmLimestone,
            labelStyle: TextStyle(
              color: isSelected ? RemediTheme.warmLimestone : RemediTheme.deepTeal,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: RemediTheme.deepTeal.withOpacity(isSelected ? 0 : 0.2),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
