import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';

class IngredientInventory extends StatefulWidget {
  final List<String> ingredients;
  final Function(List<String>)? onOrderNow;

  const IngredientInventory({
    super.key,
    required this.ingredients,
    this.onOrderNow,
  });

  @override
  State<IngredientInventory> createState() => _IngredientInventoryState();
}

class _IngredientInventoryState extends State<IngredientInventory> {
  // Set of indices that are "Needed" (to buy). 
  // Initially contains ALL indices. User unchecks if they have it.
  late final Set<int> _neededIngredients;

  @override
  void initState() {
    super.initState();
    // Default: User needs everything
    _neededIngredients = List.generate(widget.ingredients.length, (i) => i).toSet();
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (_neededIngredients.contains(index)) {
        _neededIngredients.remove(index); // Remove -> "Have"
      } else {
        _neededIngredients.add(index); // Add -> "Need"
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Explainer Banner (Enhanced Visibility)
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1), // Light Amber for visibility
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Color(0xFFF57F17)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Items checked are added to your cart.\nUncheck items you already have at home.", // Clearer Logic
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE65100), // Darker text for contrast
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            "INVENTORY CHECK",
             style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: RemediTheme.charcoal.withOpacity(0.5),
              ),
          ),
        ),
        
        // Ingredient List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: widget.ingredients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildIngredientRow(index, widget.ingredients[index]);
          },
        ),
        
        const SizedBox(height: 24),
        
        // Cart Summary Bar (Only if items needed)
        if (_neededIngredients.isNotEmpty)
          _buildCartSummary(),
      ],
    );
  }

  Widget _buildIngredientRow(int index, String name) {
    final isNeeded = _neededIngredients.contains(index);
    
    return GestureDetector(
      onTap: () => _toggleIngredient(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isNeeded 
              ? Colors.white // Active: White
              : Colors.grey.withOpacity(0.05), // Inactive: Grey
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNeeded 
                ? RemediTheme.deepTeal.withOpacity(0.2)
                : Colors.transparent,
          ),
          boxShadow: isNeeded ? [
            BoxShadow(
              color: RemediTheme.deepTeal.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ) 
          ] : null,
        ),
        child: Row(
          children: [
            // Status Icon (Check = Need/Buy)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNeeded ? RemediTheme.deepTeal : Colors.transparent, // Tick Box filled if needed
                border: Border.all(
                  color: isNeeded ? RemediTheme.deepTeal : Colors.grey.withOpacity(0.5), // Grey border if unchecked
                  width: 2,
                ),
              ),
              child: isNeeded 
                  ? const Icon(Icons.check, size: 14, color: Colors.white) // Checkmark means "YES I NEED IT"
                  : null,
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isNeeded ? RemediTheme.charcoal : RemediTheme.charcoal.withOpacity(0.5), // Valid text if needed
                  decoration: isNeeded ? null : TextDecoration.lineThrough, // Strikethrough if Have
                  decorationColor: RemediTheme.charcoal.withOpacity(0.3),
                ),
              ),
            ),
            
            // Toggle Label
            Text(
              isNeeded ? "Buy" : "Have", // Clearer Labels
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isNeeded ? RemediTheme.deepTeal : RemediTheme.mutedSage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return InkSurface(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_neededIngredients.length} Items in Cart", // Updated Text
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                "Estimated: ₹${_neededIngredients.length * 60}", 
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
               if (widget.onOrderNow != null) {
                 final items = _neededIngredients.map((i) => widget.ingredients[i]).toList();
                 widget.onOrderNow!(items);
               }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A373), 
              foregroundColor: RemediTheme.darkForest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36),
            ),
            child: const Text("Order Now"),
          ),
        ],
      ),
    );
  }
}
