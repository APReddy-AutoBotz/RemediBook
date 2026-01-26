import 'package:flutter/material.dart';
import '../../../discovery/domain/models/remedy.dart';
import '../../../../core/models/user_profile.dart';

/// Triage Level Enum
enum TriageLevel {
  /// No safety concerns detected
  safe,
  
  /// Soft Amber - Caution required with acknowledgment
  caution,
  
  /// Hard Red - Emergency requiring immediate action
  emergency;
}

/// Triage Result
class TriageResult {
  final TriageLevel level;
  final List<String> triggeredKeywords;
  final String message;
  final String? actionRequired;

  const TriageResult({
    required this.level,
    required this.triggeredKeywords,
    required this.message,
    this.actionRequired,
  });

  bool get isEmergency => level == TriageLevel.emergency;
  bool get isCaution => level == TriageLevel.caution;
  bool get isSafe => level == TriageLevel.safe;
}

/// Triage Interceptor - Keyword-based Safety Scanner
/// NO tone/sentiment analysis - YES keyword-based clinical red flags
class TriageInterceptor {
  // ═══════════════════════════════════════════════════════════════════════
  // HARD RED KEYWORDS - Emergency
  // ═══════════════════════════════════════════════════════════════════════
  
  static const List<String> HARD_RED_KEYWORDS = [
    // Cardiovascular emergencies
    'chest pain',
    'heart attack',
    'severe chest pressure',
    
    // Respiratory emergencies
    'difficulty breathing',
    'can\'t breathe',
    'choking',
    'severe shortness of breath',
    
    // Bleeding emergencies
    'severe bleeding',
    'uncontrolled bleeding',
    'heavy bleeding',
    
    // Consciousness issues
    'unconsciousness',
    'unconscious',
    'passed out',
    'fainting repeatedly',
    
    // Allergic reactions
    'severe allergic reaction',
    'anaphylaxis',
    'throat swelling',
    'face swelling rapidly',
    
    // Neurological emergencies
    'stroke',
    'seizure',
    'severe head injury',
    'sudden vision loss',
    
    // Other critical
    'severe burns',
    'poisoning',
    'suicide',
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // SOFT AMBER KEYWORDS - Caution
  // ═══════════════════════════════════════════════════════════════════════
  
  static const List<String> SOFT_AMBER_KEYWORDS = [
    // Persistent symptoms
    'persistent',
    'chronic',
    'ongoing for weeks',
    'not improving',
    
    // Medication concerns
    'medication',
    'taking medicine',
    'on prescription',
    'drug interaction',
    
    // Pregnancy/breastfeeding
    'pregnancy',
    'pregnant',
    'breastfeeding',
    'nursing',
    
    // Chronic conditions
    'diabetes',
    'high blood pressure',
    'heart condition',
    'kidney disease',
    'liver disease',
    
    // Age-related
    'elderly',
    'over 65',
    'senior',
    
    // Severity indicators
    'severe pain',
    'worsening',
    'getting worse',
    'fever over 103',
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // TRIAGE LOGIC
  // ═══════════════════════════════════════════════════════════════════════

  /// Scan input text for safety keywords
  static TriageResult scan(String input) {
    final inputLower = input.toLowerCase();
    
    // Check for Hard Red keywords first
    final hardRedMatches = _findMatches(inputLower, HARD_RED_KEYWORDS);
    if (hardRedMatches.isNotEmpty) {
      return TriageResult(
        level: TriageLevel.emergency,
        triggeredKeywords: hardRedMatches,
        message: 'Emergency situation detected. Immediate medical attention required.',
        actionRequired: 'Call Emergency Services',
      );
    }
    
    // Check for Soft Amber keywords
    final softAmberMatches = _findMatches(inputLower, SOFT_AMBER_KEYWORDS);
    if (softAmberMatches.isNotEmpty) {
      return TriageResult(
        level: TriageLevel.caution,
        triggeredKeywords: softAmberMatches,
        message: 'Caution: Your situation may require professional medical consultation.',
        actionRequired: 'Acknowledge & Continue',
      );
    }
    
    // No safety concerns
    return const TriageResult(
      level: TriageLevel.safe,
      triggeredKeywords: [],
      message: 'No immediate safety concerns detected.',
    );
  }

  /// Check for conflicts between a remedy and the user's sovereign profile
  static String? checkProfileConflicts(Remedy remedy, SovereignProfile profile) {
    final remedyLower = remedy.name.toLowerCase();
    final ingredientsLower = remedy.ingredients.map((i) => i.toLowerCase()).toList();

    // 1. Pregnancy Conflict
    if (profile.isPregnant) {
      // Common pregnancy contraindications in traditional medicine
      const pregnancyNoGo = ['papaya', 'aloe vera', 'fenugreek', 'ginger']; 
      for (final item in pregnancyNoGo) {
        if (remedyLower.contains(item) || ingredientsLower.any((i) => i.contains(item))) {
          return "⚠️ Pregnancy Conflict: $item";
        }
      }
    }

    // 2. Blood Pressure Medication Conflict
    if (profile.onBPMeds) {
      // Ginger can interact with blood thinners/BP meds as per architecture v1.3.0
      const bpConflict = ['ginger', 'garlic', 'licorice'];
      for (final item in bpConflict) {
        if (remedyLower.contains(item) || ingredientsLower.any((i) => i.contains(item))) {
          return "⚠️ BP Medication Conflict: $item";
        }
      }
    }

    // 3. Diabetes Conflict
    if (profile.isDiabetic) {
      const sugarConflict = ['honey', 'jaggery', 'sugar', 'dates'];
      for (final item in sugarConflict) {
        if (remedyLower.contains(item) || ingredientsLower.any((i) => i.contains(item))) {
          return "⚠️ Diabetic Caution: High glycemic index ($item)";
        }
      }
    }

    // 4. Allergy Conflict
    for (final allergy in profile.allergies) {
      final allergyLower = allergy.toLowerCase();
      if (remedyLower.contains(allergyLower) || ingredientsLower.any((i) => i.contains(allergyLower))) {
        return "⚠️ Allergy Conflict: $allergy";
      }
    }

    return null;
  }

  /// Find matching keywords in input
  static List<String> _findMatches(String input, List<String> keywords) {
    final matches = <String>[];
    for (final keyword in keywords) {
      if (input.contains(keyword.toLowerCase())) {
        matches.add(keyword);
      }
    }
    return matches;
  }

  /// Quick check if input contains emergency keywords
  static bool isEmergency(String input) {
    return scan(input).isEmergency;
  }

  /// Quick check if input contains caution keywords
  static bool isCaution(String input) {
    return scan(input).isCaution;
  }

  /// Get user-friendly message for triage level
  static String getMessage(TriageLevel level) {
    switch (level) {
      case TriageLevel.emergency:
        return 'This appears to be a medical emergency. Please seek immediate professional help.';
      case TriageLevel.caution:
        return 'Your situation may benefit from professional medical consultation before trying home remedies.';
      case TriageLevel.safe:
        return 'You can explore wellness remedies safely.';
    }
  }

  /// Get recommended action for triage level
  static String? getAction(TriageLevel level) {
    switch (level) {
      case TriageLevel.emergency:
        return 'Call Emergency Services (911)';
      case TriageLevel.caution:
        return 'Consult Healthcare Provider';
      case TriageLevel.safe:
        return null;
    }
  }
}
