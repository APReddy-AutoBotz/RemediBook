import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/discovery/domain/models/fulfillment_models.dart';
import './fulfillment_engine.dart';

/// Commerce Service - Multi-Item Deep Linking
/// Pillar 3: Artifact Experience (Trust) & Commerce Bridge
/// 
/// Generates deep links for Zepto/Blinkit with pre-populated cart

class CommerceService {
  /// Generate deep link for Zepto with multiple items
  static String generateZeptoDeepLink(List<IngredientStatus> neededItems) {
    if (neededItems.isEmpty) return '';
    
    // Use vernacular names for better local search
    final searchTerms = neededItems
        .map((item) => FulfillmentEngine.getCommerceSearchTerm(item))
        .join('+');
    
    // Zepto deep link format (may need adjustment based on actual app schema)
    return 'https://www.zeptonow.com/search?query=${Uri.encodeComponent(searchTerms)}';
  }

  /// Generate deep link for Blinkit with multiple items
  static String generateBlinkitDeepLink(List<IngredientStatus> neededItems) {
    if (neededItems.isEmpty) return '';
    
    // Use vernacular names for better local search
    final searchTerms = neededItems
        .map((item) => FulfillmentEngine.getCommerceSearchTerm(item))
        .join('+');
    
    // Blinkit deep link format
    return 'https://blinkit.com/s/?q=${Uri.encodeComponent(searchTerms)}';
  }

  /// Launch commerce app with deep link
  static Future<bool> launchCommerceApp({
    required String provider,
    required List<IngredientStatus> neededItems,
  }) async {
    HapticFeedback.mediumImpact();
    
    final deepLink = provider.toLowerCase() == 'zepto'
        ? generateZeptoDeepLink(neededItems)
        : generateBlinkitDeepLink(neededItems);
    
    if (deepLink.isEmpty) return false;
    
    final uri = Uri.parse(deepLink);
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Calculate total price for needed items only
  static double calculateNeededPrice({
    required List<IngredientStatus> allMaterials,
    required List<String> inHouseItems,
    required double basePrice,
  }) {
    if (allMaterials.isEmpty) return 0.0;
    
    final neededCount = allMaterials.length - inHouseItems.length;
    if (neededCount <= 0) return 0.0;
    
    // Proportional pricing based on needed items
    final pricePerItem = basePrice / allMaterials.length;
    return pricePerItem * neededCount;
  }

  /// Get list of needed items (not in house)
  static List<IngredientStatus> getNeededItems({
    required List<IngredientStatus> allMaterials,
    required List<String> inHouseItems,
  }) {
    return allMaterials
        .where((item) => !inHouseItems.contains(item.name))
        .toList();
  }

  /// Check if all items are in house
  static bool hasAllItemsInHouse({
    required List<IngredientStatus> allMaterials,
    required List<String> inHouseItems,
  }) {
    return allMaterials.every((item) => inHouseItems.contains(item.name));
  }
}
