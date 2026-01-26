/// Millet Score Service - Siridhanya Intelligence
/// Implements Pillar 2: Agentic Wellness - Food Score Algorithm
library;

/// Food Model
class Food {
  final String id;
  final String name;
  final double fibre; // grams per 100g
  final double carbohydrates; // grams per 100g
  final double protein; // grams per 100g
  final String category;
  final List<String> curativeClaims; // Compliant terms

  const Food({
    required this.id,
    required this.name,
    required this.fibre,
    required this.carbohydrates,
    required this.protein,
    required this.category,
    this.curativeClaims = const [],
  });

  /// Calculate Food Score using Fibre:Carb Ratio
  /// As per Pillar 2: 1:10 Curative Ratio logic
  double get foodScore {
    if (carbohydrates == 0) return 0;
    final fibreToCarb = fibre / carbohydrates;
    return fibreToCarb * 100; // Normalized to 0-100 scale
  }

  /// Get score band category
  String get scoreBand {
    final score = foodScore;
    if (score > 15) return 'Excellent';
    if (score >= 10) return 'Good';
    if (score >= 5) return 'Moderate';
    return 'Low';
  }

  /// Get score band color (for UI)
  String get scoreBandColor {
    final score = foodScore;
    if (score > 15) return '#1F4E5F'; // Deep Teal
    if (score >= 10) return '#8FA998'; // Muted Sage
    if (score >= 5) return '#F59E0B'; // Amber
    return '#DC2626'; // Red
  }
}

/// Millet Score Service
/// Curated database of Siridhanya millets with compliant curative claims
class MilletScoreService {
  // ═══════════════════════════════════════════════════════════════════════
  // SIRIDHANYA DATABASE (5 Sacred Millets)
  // ═══════════════════════════════════════════════════════════════════════

  /// Kodo Millet (Paspalum scrobiculatum)
  static const Food kodoMillet = Food(
    id: 'kodo',
    name: 'Kodo Millet',
    fibre: 9.0,
    carbohydrates: 65.9,
    protein: 8.3,
    category: 'Siridhanya',
    curativeClaims: [
      'Metabolic Support',
      'Digestive Wellness',
      'Blood Sugar Balance Support',
    ],
  );

  /// Barnyard Millet (Echinochloa frumentacea)
  static const Food barnyardMillet = Food(
    id: 'barnyard',
    name: 'Barnyard Millet',
    fibre: 10.1,
    carbohydrates: 65.5,
    protein: 11.2,
    category: 'Siridhanya',
    curativeClaims: [
      'Weight Management Support',
      'Cardiovascular Wellness',
      'Iron Absorption Support',
    ],
  );

  /// Little Millet (Panicum sumatrense)
  static const Food littleMillet = Food(
    id: 'little',
    name: 'Little Millet',
    fibre: 7.6,
    carbohydrates: 67.0,
    protein: 7.7,
    category: 'Siridhanya',
    curativeClaims: [
      'Antioxidant Support',
      'Bone Health Support',
      'Energy Metabolism',
    ],
  );

  /// Foxtail Millet (Setaria italica)
  static const Food foxtailMillet = Food(
    id: 'foxtail',
    name: 'Foxtail Millet',
    fibre: 8.0,
    carbohydrates: 60.9,
    protein: 12.3,
    category: 'Siridhanya',
    curativeClaims: [
      'Nervous System Support',
      'Immune Function Support',
      'Inflammation Support',
    ],
  );

  /// Browntop Millet (Brachiaria ramosa)
  static const Food browntopMillet = Food(
    id: 'browntop',
    name: 'Browntop Millet',
    fibre: 12.5,
    carbohydrates: 68.8,
    protein: 11.5,
    category: 'Siridhanya',
    curativeClaims: [
      'Digestive Health Support',
      'Detoxification Support',
      'Metabolic Balance',
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════
  // MILLET DATABASE COLLECTION
  // ═══════════════════════════════════════════════════════════════════════

  /// All Siridhanya millets
  static const List<Food> allSiridhanya = [
    kodoMillet,
    barnyardMillet,
    littleMillet,
    foxtailMillet,
    browntopMillet,
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // FOOD SCORE CALCULATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Calculate Food Score using Fibre:Carb Ratio
  /// Formula: (Fibre / Carbohydrates) * 100
  /// 
  /// Score Bands:
  /// - Excellent: > 15 (e.g., Browntop Millet: 18.2)
  /// - Good: 10-15 (e.g., Barnyard Millet: 15.4)
  /// - Moderate: 5-10 (e.g., Kodo Millet: 13.7)
  /// - Low: < 5
  static double calculateFoodScore(Food food) {
    if (food.carbohydrates == 0) return 0;
    final fibreToCarb = food.fibre / food.carbohydrates;
    return fibreToCarb * 100;
  }

  /// Get score band for a given score
  static String getScoreBand(double score) {
    if (score > 15) return 'Excellent';
    if (score >= 10) return 'Good';
    if (score >= 5) return 'Moderate';
    return 'Low';
  }

  /// Get all millets sorted by food score (highest first)
  static List<Food> getMilletsByScore() {
    final millets = List<Food>.from(allSiridhanya);
    millets.sort((a, b) => b.foodScore.compareTo(a.foodScore));
    return millets;
  }

  /// Get millets by score band
  static List<Food> getMilletsByBand(String band) {
    return allSiridhanya.where((m) => m.scoreBand == band).toList();
  }

  /// Get millet by ID
  static Food? getMilletById(String id) {
    try {
      return allSiridhanya.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get millets with specific curative claim
  static List<Food> getMilletsByClaim(String claim) {
    return allSiridhanya
        .where((m) => m.curativeClaims.any(
              (c) => c.toLowerCase().contains(claim.toLowerCase()),
            ))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // COMPARISON & ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════

  /// Compare two foods by their food score
  static Map<String, dynamic> compareFoods(Food food1, Food food2) {
    final score1 = calculateFoodScore(food1);
    final score2 = calculateFoodScore(food2);
    
    return {
      'food1': {
        'name': food1.name,
        'score': score1,
        'band': getScoreBand(score1),
      },
      'food2': {
        'name': food2.name,
        'score': score2,
        'band': getScoreBand(score2),
      },
      'difference': (score1 - score2).abs(),
      'better': score1 > score2 ? food1.name : food2.name,
    };
  }

  /// Get nutritional profile summary
  static Map<String, dynamic> getNutritionalProfile(Food food) {
    return {
      'name': food.name,
      'fibre': food.fibre,
      'carbohydrates': food.carbohydrates,
      'protein': food.protein,
      'foodScore': food.foodScore,
      'scoreBand': food.scoreBand,
      'fibreToCarb': food.fibre / food.carbohydrates,
      'curativeClaims': food.curativeClaims,
    };
  }

  /// Get recommendation based on health goal
  static List<Food> getRecommendationsByGoal(String goal) {
    final goalLower = goal.toLowerCase();
    
    // Map goals to curative claims
    if (goalLower.contains('metabolic') || goalLower.contains('diabetes')) {
      return getMilletsByClaim('Metabolic');
    } else if (goalLower.contains('weight')) {
      return getMilletsByClaim('Weight Management');
    } else if (goalLower.contains('digestive')) {
      return getMilletsByClaim('Digestive');
    } else if (goalLower.contains('inflammation')) {
      return getMilletsByClaim('Inflammation');
    } else if (goalLower.contains('immune')) {
      return getMilletsByClaim('Immune');
    }
    
    // Default: return highest scoring millets
    return getMilletsByScore().take(3).toList();
  }
}
