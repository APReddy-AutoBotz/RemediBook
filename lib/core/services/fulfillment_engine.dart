import 'package:flutter/material.dart';
import '../../features/discovery/domain/models/fulfillment_models.dart';

/// Fulfillment Engine - Consistency Handshake Logic
/// Pillar 2 & 4: Agentic Wellness & Governance Layer
/// 
/// Ensures all remedy suggestions are dynamically verified for consistency
/// between Preparation Protocol and Materials sections.

class FulfillmentEngine {
  /// Material keywords that can be extracted from prep steps
  static const List<String> _materialKeywords = [
    // Compression & Support
    'bandage', 'compress', 'wrap', 'brace', 'support',
    // Temperature
    'ice pack', 'ice', 'cold pack', 'hot pack', 'heating pad', 'warm compress',
    // Ingredients - Herbs & Spices
    'ginger', 'tulsi', 'turmeric', 'honey', 'lemon', 'garlic', 'neem',
    'ashwagandha', 'giloy', 'amla', 'brahmi', 'triphala',
    // Ingredients - Oils
    'oil', 'coconut oil', 'sesame oil', 'mustard oil', 'castor oil', 'peppermint oil',
    // Ingredients - Grains & Millets
    'millet', 'foxtail', 'kodo', 'barnyard', 'little millet', 'browntop',
    // Ingredients - Dairy & Liquids
    'milk', 'buttermilk', 'ghee', 'curd', 'water',
    // Supplements
    'magnesium', 'vitamin', 'zinc', 'calcium', 'iron',
    // Equipment
    'neti pot', 'mortar', 'pestle', 'clay pot', 'stone bowl',
    // Leaves & Plants
    'leaves', 'curry leaves', 'mint', 'basil', 'coriander',
  ];

  /// Non-material action keywords (these don't require procurement)
  static const List<String> _actionOnlyKeywords = [
    'rest', 'elevate', 'breathe', 'inhale', 'exhale', 'hold', 'repeat',
    'sit', 'lie', 'stand', 'walk', 'stretch', 'relax', 'focus',
    'massage', 'press', 'rotate', 'tilt', 'bend', 'extend',
  ];

  /// Scan preparation steps and extract physical materials
  /// This is the core "Material Scan" logic
  static List<IngredientStatus> scanMaterials(List<PrepStep> prepSteps) {
    final Set<String> extractedMaterials = {};
    
    for (final step in prepSteps) {
      final lowerInstruction = step.instruction.toLowerCase();
      
      for (final keyword in _materialKeywords) {
        if (lowerInstruction.contains(keyword.toLowerCase())) {
          // Capitalize for display
          final displayName = _toTitleCase(keyword);
          extractedMaterials.add(displayName);
        }
      }
    }
    
    // Convert to IngredientStatus with availability simulation
    return extractedMaterials.map((material) {
      // Simulate availability (in production, this would check inventory APIs)
      final isAvailable = _simulateAvailability(material);
      return IngredientStatus(
        material,
        isAvailable,
        vernacularName: _getVernacularName(material),
      );
    }).toList();
  }

  /// Determine if the remedy requires any physical materials
  /// This is the "Null Inventory Gate"
  static bool hasPhysicalMaterials(List<PrepStep> prepSteps) {
    for (final step in prepSteps) {
      final lowerInstruction = step.instruction.toLowerCase();
      
      // Check if any material keyword is present
      for (final keyword in _materialKeywords) {
        if (lowerInstruction.contains(keyword.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }

  /// Determine if materials section should be shown
  /// Returns false for action-only remedies (breathing, stretching, etc.)
  static bool shouldShowMaterials(List<IngredientStatus> materials) {
    return materials.isNotEmpty;
  }

  /// Get vernacular (local) name for a material
  /// This is the "Vernacular Bridge" logic
  static String? _getVernacularName(String material) {
    const vernacularMap = {
      // Hindi/Sanskrit names
      'Tulsi': 'Holy Basil (तुलसी)',
      'Ginger': 'Adrak (अदरक)',
      'Turmeric': 'Haldi (हल्दी)',
      'Honey': 'Shahad (शहद)',
      'Ghee': 'Clarified Butter (घी)',
      'Buttermilk': 'Chaas (छाछ)',
      'Curd': 'Dahi (दही)',
      'Neem': 'Nimba (नीम)',
      'Ashwagandha': 'Indian Ginseng (अश्वगंधा)',
      'Giloy': 'Guduchi (गिलोय)',
      'Amla': 'Indian Gooseberry (आंवला)',
      'Curry Leaves': 'Kadi Patta (करी पत्ता)',
      'Coconut Oil': 'Nariyal Tel (नारियल तेल)',
      'Mustard Oil': 'Sarson Ka Tel (सरसों का तेल)',
      'Sesame Oil': 'Til Ka Tel (तिल का तेल)',
      // Millets
      'Foxtail': 'Kangni (कांगणी)',
      'Kodo': 'Kodra (कोदरा)',
      'Barnyard': 'Sanwa (सांवा)',
      'Little Millet': 'Kutki (कुटकी)',
      'Browntop': 'Korle (कोरले)',
    };
    
    return vernacularMap[material];
  }

  /// Get commerce-ready search term for a material
  /// Uses vernacular name if available for better local search results
  static String getCommerceSearchTerm(IngredientStatus material) {
    // Prefer vernacular name for local commerce platforms
    if (material.vernacularName != null) {
      // Extract just the local name (before parentheses)
      final vernacular = material.vernacularName!;
      if (vernacular.contains('(')) {
        return vernacular.split('(')[0].trim();
      }
      return vernacular;
    }
    return material.name;
  }

  /// Get all commerce search terms for missing materials
  static String getMissingMaterialsSearchQuery(List<IngredientStatus> materials) {
    final missing = materials.where((m) => !m.inStock).toList();
    if (missing.isEmpty) return '';
    
    return missing
        .map((m) => getCommerceSearchTerm(m))
        .join(', ');
  }

  /// Simulate material availability (placeholder for real inventory check)
  static bool _simulateAvailability(String material) {
    // Common household items likely to be available
    const likelyAvailable = [
      'Water', 'Salt', 'Honey', 'Lemon', 'Ginger', 'Turmeric',
      'Milk', 'Ghee', 'Curd', 'Curry Leaves', 'Ice',
    ];
    
    return likelyAvailable.any(
      (item) => material.toLowerCase().contains(item.toLowerCase())
    );
  }

  /// Convert string to Title Case
  static String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Analyze prep steps and return complete fulfillment context
  /// This is the main "Consistency Handshake" method
  static FulfillmentContext analyze(List<PrepStep> prepSteps) {
    final materials = scanMaterials(prepSteps);
    final hasMaterials = shouldShowMaterials(materials);
    final commerceQuery = getMissingMaterialsSearchQuery(materials);
    
    return FulfillmentContext(
      extractedMaterials: materials,
      hasPhysicalMaterials: hasMaterials,
      commerceSearchQuery: commerceQuery,
    );
  }
}

/// Context returned by FulfillmentEngine analysis
class FulfillmentContext {
  final List<IngredientStatus> extractedMaterials;
  final bool hasPhysicalMaterials;
  final String commerceSearchQuery;

  const FulfillmentContext({
    required this.extractedMaterials,
    required this.hasPhysicalMaterials,
    required this.commerceSearchQuery,
  });
}
