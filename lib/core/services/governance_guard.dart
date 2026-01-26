/// Governance Guard - Pillar 4: No-Go Zones Enforcement
/// Automatically rejects requests that require professional medical care
library;

/// User Profile for Governance Checks
class UserProfile {
  final int age;
  final bool isPregnant;
  final bool isBreastfeeding;
  final List<String> medications;
  final List<String> chronicConditions;

  const UserProfile({
    required this.age,
    this.isPregnant = false,
    this.isBreastfeeding = false,
    this.medications = const [],
    this.chronicConditions = const [],
  });

  bool get isPediatric => age < 12;
  bool get isPregnancyRelated => isPregnant || isBreastfeeding;
  bool get hasMedications => medications.isNotEmpty;
}

/// Governance Result
class GovernanceResult {
  final bool canProceed;
  final String? refusalReason;
  final String? professionalGuidance;
  final List<String> triggeredNoGoZones;

  const GovernanceResult({
    required this.canProceed,
    this.refusalReason,
    this.professionalGuidance,
    this.triggeredNoGoZones = const [],
  });

  bool get isBlocked => !canProceed;
}

/// Remedy for Interaction Checking
class Remedy {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<String> knownInteractions;

  const Remedy({
    required this.id,
    required this.name,
    required this.ingredients,
    this.knownInteractions = const [],
  });
}

/// Governance Guard - No-Go Zones Enforcement
class GovernanceGuard {
  // ═══════════════════════════════════════════════════════════════════════
  // NO-GO ZONES
  // ═══════════════════════════════════════════════════════════════════════

  /// Check if user can proceed with remedy
  static GovernanceResult canProceed(UserProfile profile, Remedy remedy) {
    final noGoZones = <String>[];
    
    // Check 1: Pediatrics (<12 years)
    if (profile.isPediatric) {
      return GovernanceResult(
        canProceed: false,
        refusalReason: 'Pediatric Safety Restriction',
        professionalGuidance: 
            'RemediBook Premier is designed for adults (12+ years). '
            'Please consult a pediatrician for children\'s health concerns.',
        triggeredNoGoZones: ['pediatrics'],
      );
    }
    
    // Check 2: Pregnancy/Breastfeeding
    if (profile.isPregnancyRelated) {
      return GovernanceResult(
        canProceed: false,
        refusalReason: 'Pregnancy/Breastfeeding Safety Restriction',
        professionalGuidance:
            'Please consult your healthcare provider for pregnancy-safe remedies. '
            'Many traditional remedies may not be suitable during pregnancy or breastfeeding.',
        triggeredNoGoZones: ['pregnancy_breastfeeding'],
      );
    }
    
    // Check 3: Medication Interaction Uncertainty
    if (profile.hasMedications && hasUncertainInteraction(profile.medications, remedy)) {
      return GovernanceResult(
        canProceed: false,
        refusalReason: 'Potential Medication Interaction',
        professionalGuidance:
            'Potential interaction detected between this remedy and your medications. '
            'Please consult your pharmacist or healthcare provider before proceeding.',
        triggeredNoGoZones: ['medication_interaction'],
      );
    }
    
    // All checks passed
    return const GovernanceResult(
      canProceed: true,
    );
  }

  /// Check for uncertain medication interactions
  static bool hasUncertainInteraction(List<String> medications, Remedy remedy) {
    // Check against known interactions
    for (final medication in medications) {
      final medLower = medication.toLowerCase();
      
      // Check remedy's known interactions
      for (final interaction in remedy.knownInteractions) {
        if (interaction.toLowerCase().contains(medLower) ||
            medLower.contains(interaction.toLowerCase())) {
          return true;
        }
      }
      
      // Check common high-risk medications
      if (_isHighRiskMedication(medLower)) {
        // If remedy contains certain ingredients, flag as uncertain
        if (_hasInteractiveIngredients(remedy.ingredients)) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// Check if medication is high-risk for interactions
  static bool _isHighRiskMedication(String medication) {
    const highRiskMeds = [
      'warfarin',
      'blood thinner',
      'anticoagulant',
      'aspirin',
      'insulin',
      'metformin',
      'statins',
      'immunosuppressant',
      'chemotherapy',
      'antidepressant',
      'ssri',
      'maoi',
    ];
    
    for (final riskMed in highRiskMeds) {
      if (medication.contains(riskMed)) {
        return true;
      }
    }
    return false;
  }

  /// Check if remedy has ingredients known to interact
  static bool _hasInteractiveIngredients(List<String> ingredients) {
    const interactiveIngredients = [
      'ginger',
      'turmeric',
      'garlic',
      'ginkgo',
      'st john\'s wort',
      'ginseng',
      'licorice',
      'green tea',
    ];
    
    for (final ingredient in ingredients) {
      final ingLower = ingredient.toLowerCase();
      for (final interactive in interactiveIngredients) {
        if (ingLower.contains(interactive)) {
          return true;
        }
      }
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PROFESSIONAL REFUSAL MESSAGES
  // ═══════════════════════════════════════════════════════════════════════

  /// Get refusal message for pediatrics
  static String get pediatricRefusal =>
      'RemediBook Premier is designed for adults (12+ years). '
      'Children have unique health needs that require specialized pediatric care. '
      'Please consult a pediatrician for your child\'s health concerns.';

  /// Get refusal message for pregnancy/breastfeeding
  static String get pregnancyRefusal =>
      'Please consult your healthcare provider for pregnancy-safe remedies. '
      'Many traditional remedies contain herbs and compounds that may not be '
      'suitable during pregnancy or breastfeeding. Your healthcare provider '
      'can recommend safe alternatives.';

  /// Get refusal message for medication interactions
  static String get medicationRefusal =>
      'Potential interaction detected between this remedy and your medications. '
      'Some natural remedies can interact with prescription medications, '
      'affecting their effectiveness or causing side effects. '
      'Please consult your pharmacist or healthcare provider before proceeding.';

  /// Get general professional consultation message
  static String get generalConsultation =>
      'Based on your profile, we recommend consulting with a healthcare '
      'professional before trying this remedy. They can provide personalized '
      'guidance based on your complete medical history.';

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Quick check if profile has any no-go zones
  static bool hasNoGoZones(UserProfile profile) {
    return profile.isPediatric || 
           profile.isPregnancyRelated || 
           profile.hasMedications;
  }

  /// Get all applicable no-go zones for profile
  static List<String> getNoGoZones(UserProfile profile) {
    final zones = <String>[];
    
    if (profile.isPediatric) zones.add('pediatrics');
    if (profile.isPregnant) zones.add('pregnancy');
    if (profile.isBreastfeeding) zones.add('breastfeeding');
    if (profile.hasMedications) zones.add('medications');
    
    return zones;
  }
}
