// Design Bible Reference: docs/DESIGN_BIBLE.md - Phase 4 (Sovereign Triad 2.0)
// Implements deep link builder for multi-item grocery cart

import 'package:flutter/foundation.dart';

/// DeepLinkBuilder - Generates deep links for e-commerce platforms
class DeepLinkBuilder {
  /// Supported e-commerce platforms
  static const Map<String, String> _platformDomains = {
    'amazon': 'amazon.in',
    'bigbasket': 'bigbasket.com',
    'blinkit': 'blinkit.com',
  };

  /// Build deep link for multiple items
  static String buildCartLink({
    required String platform,
    required List<CartItem> items,
  }) {
    if (items.isEmpty) {
      return _buildFallbackUrl(platform);
    }

    switch (platform.toLowerCase()) {
      case 'amazon':
        return _buildAmazonLink(items);
      case 'bigbasket':
        return _buildBigBasketLink(items);
      case 'blinkit':
        return _buildBlinkitLink(items);
      default:
        return _buildGenericSearchLink(platform, items);
    }
  }

  static String _buildAmazonLink(List<CartItem> items) {
    final searchQuery = items.map((item) => item.searchTerm).join(' ');
    final encodedQuery = Uri.encodeComponent(searchQuery);
    return 'https://www.amazon.in/s?k=$encodedQuery';
  }

  static String _buildBigBasketLink(List<CartItem> items) {
    final searchQuery = items.map((item) => item.searchTerm).join(' ');
    final encodedQuery = Uri.encodeComponent(searchQuery);
    return 'https://www.bigbasket.com/ps/?q=$encodedQuery';
  }

  static String _buildBlinkitLink(List<CartItem> items) {
    final searchQuery = items.map((item) => item.searchTerm).join(' ');
    final encodedQuery = Uri.encodeComponent(searchQuery);
    return 'https://blinkit.com/s/?q=$encodedQuery';
  }

  static String _buildGenericSearchLink(String platform, List<CartItem> items) {
    final domain = _platformDomains[platform.toLowerCase()] ?? '$platform.com';
    final searchQuery = items.map((item) => item.searchTerm).join(' ');
    final encodedQuery = Uri.encodeComponent(searchQuery);
    return 'https://www.$domain/search?q=$encodedQuery';
  }

  static String _buildFallbackUrl(String platform) {
    final domain = _platformDomains[platform.toLowerCase()] ?? '$platform.com';
    return 'https://www.$domain';
  }

  static String buildShoppingListText(List<CartItem> items) {
    if (items.isEmpty) return 'No items in shopping list';
    final buffer = StringBuffer();
    buffer.writeln('🛒 RemediBook Shopping List\n');
    for (int i = 0; i < items.length; i++) {
        buffer.writeln('${i + 1}. ${items[i].name}');
    }
    return buffer.toString();
  }
  
  static Map<String, String> buildMultiPlatformLinks(List<CartItem> items) {
    return {
      for (var platform in _platformDomains.keys)
        platform: buildCartLink(platform: platform, items: items),
    };
  }

  /// Clean ingredient string for search
  /// Removes units, quantities, and optional text
  static String cleanIngredient(String input) {
    // 1. Remove units (e.g., "1 teaspoon", "2 cups")
    final unitRegex = RegExp(r'\b(\d+[\/\.]?\d*|-)?\s*(tablespoons?|teaspoons?|tbsp|tsp|cups?|drops?|pinch|gms?|ml|oz|grams?|cloves?|inches?|pieces?)\b', caseSensitive: false);
    var cleaned = input.replaceAll(unitRegex, '');
    
    // 2. Remove parenthetical notes like "(base)" or "(optional)"
    cleaned = cleaned.replaceAll(RegExp(r'\(.*?\)', caseSensitive: false), '');
    
    // 3. Remove leading numbers/symbols if any remain
    cleaned = cleaned.replaceAll(RegExp(r'^[\d\s\W]+'), '');
    
    return cleaned.trim();
  }

  /// Build deep link for physician consultation
  static String buildConsultationLink({
    required String discipline,
    required String ailment,
  }) {
    // Simplified query for stability
    // Practo handles "Specialist" keyword better than complex phrases
    String query;
    if (discipline.toLowerCase() == 'allopathy') {
      query = '$ailment Specialist';
    } else {
      query = '$discipline for $ailment';
    }
    
    final result = Uri.encodeComponent(query);
    // Use generic search endpoint which redirects better
    return 'https://www.practo.com/search?q=$result';
  }
}

/// Cart item model for deep linking
class CartItem {
  final String id;
  final String name;
  final String searchTerm;
  final String? vernacularName;
  final String? quantity;
  final String? productUrl;

  const CartItem({
    required this.id,
    required this.name,
    required this.searchTerm,
    this.vernacularName,
    this.quantity,
    this.productUrl,
  });

  factory CartItem.fromIngredient({
    required String id,
    required String name,
    String? vernacularName,
    String? quantity,
    String? productUrl,
  }) {
    return CartItem(
      id: id,
      name: name,
      searchTerm: DeepLinkBuilder.cleanIngredient(name), // Clean for search
      vernacularName: vernacularName,
      quantity: quantity,
      productUrl: productUrl,
    );
  }
}
