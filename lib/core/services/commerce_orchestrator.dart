import 'package:remedibook/core/services/deep_link_builder.dart';

class CommerceOrchestrator {
  /// Parse raw ingredient strings into structured CartItems
  /// e.g. "Fresh Ginger Root (2 inch)" -> CartItem(name: "Fresh Ginger Root", searchTerm: "fresh ginger root")
  static List<CartItem> parseIngredients(List<String> rawIngredients) {
    return rawIngredients.map((raw) {
      // Basic cleaning logic
      // 1. Remove parentheses content e.g. "(2 inch)", "(Optional)"
      String cleaned = raw.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
      
      // 2. Remove common prefixes if any (e.g. "Organic", "Raw" might change search results, keep them for now but maybe optional?)
      // Let's keep them as they imply quality.
      
      return CartItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(), // ephemeral ID
        name: raw, // Display full name
        searchTerm: cleaned, // Cleaned for search
      );
    }).toList();
  }

  /// Get deep links for a list of raw ingredients for a specific retailer
  static String getLinkForRetailer(String retailer, List<String> rawIngredients) {
    final items = parseIngredients(rawIngredients);
    return DeepLinkBuilder.buildCartLink(platform: retailer, items: items);
  }

  /// Get shareable shopping list text
  static String getShareText(List<String> rawIngredients) {
    final items = parseIngredients(rawIngredients);
    return DeepLinkBuilder.buildShoppingListText(items);
  }
}
