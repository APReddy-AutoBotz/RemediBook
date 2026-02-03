import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';

class DynamicRefiners extends StatefulWidget {
  final Function(String) onRefinerSelected;
  final bool isLoading;

  const DynamicRefiners({
    super.key,
    required this.onRefinerSelected,
    this.isLoading = false,
  });

  @override
  State<DynamicRefiners> createState() => _DynamicRefinersState();
}

class _DynamicRefinersState extends State<DynamicRefiners> {
  // Mock Refiners
  final List<String> _refiners = [
    "Kid-friendly",
    "No Honey",
    "Vegan",
    "5-min prep",
    "Low Sugar",
    "Extra Potent"
  ];

  String? _selectedRefiner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                "PERSONALIZE",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: RemediTheme.charcoal.withOpacity(0.5),
                ),
              ),
              if (widget.isLoading) ...[
                const Spacer(),
                const SizedBox(
                  width: 12, 
                  height: 12, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: RemediTheme.deepTeal),
                ),
                const SizedBox(width: 4),
                Text(
                  "Re-thinking...",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: RemediTheme.deepTeal,
                  ),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: _refiners.map((refiner) {
              final isSelected = _selectedRefiner == refiner;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(refiner),
                  selected: isSelected,
                  onSelected: widget.isLoading ? null : (selected) {
                    setState(() {
                      _selectedRefiner = selected ? refiner : null;
                    });
                    widget.onRefinerSelected(refiner);
                  },
                  backgroundColor: Colors.white.withOpacity(0.3),
                  selectedColor: RemediTheme.deepTeal.withOpacity(0.15),
                  checkmarkColor: RemediTheme.deepTeal,
                  showCheckmark: false,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? RemediTheme.deepTeal : RemediTheme.charcoal.withOpacity(0.8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected 
                          ? RemediTheme.deepTeal.withOpacity(0.3) 
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
