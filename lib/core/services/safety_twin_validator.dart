import 'package:remedibook/core/models/user_profile.dart';

/// Safety Twin Validator - PILLAR 1 Integration
/// Filters timeline recommendations based on user health profile
/// Ensures no unsafe recommendations reach the user
class SafetyTwinValidator {
  /// Validate a timeline recommendation against user profile
  /// Returns true if the recommendation is safe, false otherwise
  static bool validateRecommendation({
    required String title,
    required String description,
    required SovereignProfile profile,
  }) {
    final titleLower = title.toLowerCase();
    final descLower = description.toLowerCase();

    // High Blood Pressure - No caffeine
    if (profile.onBPMeds) {
      if (_containsCaffeine(titleLower, descLower)) {
        return false;
      }
    }

    // Pregnancy - Restricted herbs
    if (profile.isPregnant) {
      if (_containsPregnancyRestrictedHerbs(titleLower, descLower)) {
        return false;
      }
    }

    // Diabetes - Validate glycemic recommendations
    if (profile.isDiabetic) {
      if (_containsHighGlycemicContent(titleLower, descLower)) {
        return false;
      }
    }

    // Allergies check
    for (final allergen in profile.allergies) {
      if (titleLower.contains(allergen.toLowerCase()) ||
          descLower.contains(allergen.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  /// Check if content contains caffeine
  static bool _containsCaffeine(String title, String description) {
    final caffeineKeywords = [
      'coffee',
      'black tea',
      'green tea',
      'caffeine',
      'espresso',
    ];

    return caffeineKeywords.any((keyword) =>
        title.contains(keyword) || description.contains(keyword));
  }

  /// Check if content contains pregnancy-restricted herbs
  static bool _containsPregnancyRestrictedHerbs(String title, String description) {
    final restrictedHerbs = [
      'fenugreek',
      'aloe vera',
      'papaya',
      'pineapple',
      'licorice',
      'sage',
      'rosemary',
    ];

    return restrictedHerbs.any((herb) =>
        title.contains(herb) || description.contains(herb));
  }

  /// Check if content contains high glycemic ingredients
  static bool _containsHighGlycemicContent(String title, String description) {
    final highGlycemic = [
      'white rice',
      'refined flour',
      'maida',
      'sugar',
      'jaggery',
      'honey',
    ];

    // Note: We're being conservative here - some of these may be okay in moderation
    // This is a safety-first approach
    return highGlycemic.any((item) =>
        title.contains(item) || description.contains(item));
  }

  /// Get reason why a recommendation was rejected
  static String? getRejectionReason({
    required String title,
    required String description,
    required SovereignProfile profile,
  }) {
    final titleLower = title.toLowerCase();
    final descLower = description.toLowerCase();

    if (profile.onBPMeds && _containsCaffeine(titleLower, descLower)) {
      return 'Contains caffeine - not recommended for high blood pressure';
    }

    if (profile.isPregnant && _containsPregnancyRestrictedHerbs(titleLower, descLower)) {
      return 'Contains herbs not recommended during pregnancy';
    }

    if (profile.isDiabetic && _containsHighGlycemicContent(titleLower, descLower)) {
      return 'Contains high glycemic ingredients - not recommended for diabetes';
    }

    for (final allergen in profile.allergies) {
      if (titleLower.contains(allergen.toLowerCase()) ||
          descLower.contains(allergen.toLowerCase())) {
        return 'Contains allergen: $allergen';
      }
    }

    return null;
  }
}
