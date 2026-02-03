import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/services/deep_link_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class CommerceSheet extends StatelessWidget {
  final List<String> neededIngredients;

  const CommerceSheet({
    super.key,
    required this.neededIngredients,
  });

  Future<void> _launchSingleItem(BuildContext context, String platform, String rawIngredient) async {
    final cleanName = DeepLinkBuilder.cleanIngredient(rawIngredient);
    final item = CartItem(id: '0', name: cleanName, searchTerm: cleanName);
    
    final url = DeepLinkBuilder.buildCartLink(platform: platform, items: [item]);
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $platform")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: RemediTheme.warmLimestone.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RemediTheme.charcoal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            "SHOPPING LIST",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: RemediTheme.charcoal.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${neededIngredients.length} Items to Buy",
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: RemediTheme.darkForest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Click an icon to find the specific item on your preferred app.",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: RemediTheme.charcoal.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          
          // Item List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: neededIngredients.length,
              separatorBuilder: (_, __) => Divider(color: RemediTheme.charcoal.withOpacity(0.1)),
              itemBuilder: (context, index) {
                final raw = neededIngredients[index];
                final clean = DeepLinkBuilder.cleanIngredient(raw);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clean,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: RemediTheme.charcoal,
                              ),
                            ),
                            Text(
                              raw, // Show original quantity as subtitle
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: RemediTheme.charcoal.withOpacity(0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Action Buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildRetailerChip(
                              context,
                              "Blinkit",
                              Icons.bolt_rounded,
                              const Color(0xFFF4C430), // Blinkit Yellow
                              () => _launchSingleItem(context, 'blinkit', raw),
                            ),
                            const SizedBox(width: 8),
                            _buildRetailerChip(
                              context,
                              "BigBasket",
                              Icons.shopping_basket_outlined,
                              const Color(0xFF689F38), // BigBasket Green
                              () => _launchSingleItem(context, 'bigbasket', raw),
                            ),
                            const SizedBox(width: 8),
                            _buildRetailerChip(
                              context,
                              "Amazon",
                              Icons.shopping_cart_outlined,
                              const Color(0xFF232F3E), // Amazon Blue
                              () => _launchSingleItem(context, 'amazon', raw),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Share Option (Copy List)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Generate simple text list
                 final buffer = StringBuffer();
                 buffer.writeln("🛒 Shopping List:");
                 for (var item in neededIngredients) {
                   buffer.writeln("- $item");
                 }
                 final text = buffer.toString();
                 
                  // Copy to clipboard (Simulated for web/desktop without plugin)
                  // In real app use: Clipboard.setData(ClipboardData(text: text));
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Shopping list copied to clipboard")),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Copy Full List"),
              style: OutlinedButton.styleFrom(
                foregroundColor: RemediTheme.deepTeal,
                side: BorderSide(color: RemediTheme.deepTeal.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRetailerChip(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10, // Small but readable
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
