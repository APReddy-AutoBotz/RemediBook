import 'package:flutter/foundation.dart';

/// Fulfillment Model - Data needed for the 3-card stack
class FulfillmentData {
  final String remedyName;
  final List<PrepStep> prepSteps;
  final List<IngredientStatus> materials;
  final CommerceComparison priceComparison;
  final PracticeTechnique practice;
  final EscalationCriteria escalation;
  final bool safetyWarning;
  final String? safetyMessage;

  const FulfillmentData({
    required this.remedyName,
    required this.prepSteps,
    required this.materials,
    required this.priceComparison,
    required this.practice,
    required this.escalation,
    this.safetyWarning = false,
    this.safetyMessage,
  });
}

class PrepStep {
  final String instruction;
  final int? durationSeconds;
  
  const PrepStep(this.instruction, {this.durationSeconds});
}

class IngredientStatus {
  final String name;
  final bool inStock;
  
  const IngredientStatus(this.name, this.inStock);
}

class CommerceComparison {
  final double zeptoPrice;
  final String zeptoTime;
  final double blinkitPrice;
  final String blinkitTime;

  const CommerceComparison({
    required this.zeptoPrice,
    required this.zeptoTime,
    required this.blinkitPrice,
    required this.blinkitTime,
  });
}

class PracticeTechnique {
  final String title;
  final String iconPath;
  final List<String> howTo;

  const PracticeTechnique({
    required this.title,
    required this.iconPath,
    required this.howTo,
  });
}

class EscalationCriteria {
  final int hourThreshold;
  final String guidance;
  final List<String> redFlags;

  const EscalationCriteria({
    required this.hourThreshold,
    required this.guidance,
    required this.redFlags,
  });
}

/// Fulfillment Logic Service
/// Pillar 2 & 4: Discovery & Evidence Ledger
class FulfillmentService {
  /// Fetches fulfillment data for a specific remedy
  static Future<FulfillmentData> getFulfillmentData(String remedyId, String remedyName) async {
    // Mocking the fetch - In a real app, this would come from Firestore/Vault
    // We'll tailor the response based on the remedyId/name
    
    // Safety Twin Check (Simulation)
    final bool hasHighHeat = remedyName.toLowerCase().contains('tea') || 
                            remedyName.toLowerCase().contains('milk') ||
                            remedyName.toLowerCase().contains('porridge');
    
    return FulfillmentData(
      remedyName: remedyName,
      prepSteps: _getPrepSteps(remedyName),
      materials: _getMaterials(remedyName),
      priceComparison: _getMockPrices(),
      practice: _getPractice(remedyName),
      escalation: _getEscalation(remedyName),
      safetyWarning: hasHighHeat,
      safetyMessage: hasHighHeat 
        ? "Soft Amber: Preparation requires boiling water. Exercise caution to avoid scalds." 
        : null,
    );
  }

  static List<PrepStep> _getPrepSteps(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('tea') || lowerName.contains('kashayam')) {
      return [
        const PrepStep("Boil 250ml of filtered water", durationSeconds: 180),
        const PrepStep("Add crushed ginger and tulsi leaves"),
        const PrepStep("Simmer on low heat for 5 minutes", durationSeconds: 300),
        const PrepStep("Strain and add honey when warm, not hot"),
      ];
    } else if (lowerName.contains('porridge') || lowerName.contains('millet')) {
      return [
        const PrepStep("Soak millet for 4-6 hours for enzyme activation"),
        const PrepStep("Cook in a clay pot with 3 parts water", durationSeconds: 600),
        const PrepStep("Let it cool and ferment slightly if desired"),
        const PrepStep("Mix with buttermilk or seasoned water"),
      ];
    }
    return [
      const PrepStep("Gather all fresh ingredients"),
      const PrepStep("Mix thoroughly in a stone bowl"),
      const PrepStep("Consume immediately for maximum potency"),
    ];
  }

  static List<IngredientStatus> _getMaterials(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('millet') || lowerName.contains('porridge')) {
      return [
        const IngredientStatus("Kodo Millet", true),
        const IngredientStatus("Buttermilk", false),
        const IngredientStatus("Curry Leaves", true),
      ];
    }
    return [
      const IngredientStatus("Fresh Ginger", true),
      const IngredientStatus("Tulsi Leaves", false),
      const IngredientStatus("Raw Honey", true),
    ];
  }

  static CommerceComparison _getMockPrices() {
    return const CommerceComparison(
      zeptoPrice: 45.0,
      zeptoTime: "10 mins",
      blinkitPrice: 42.0,
      blinkitTime: "12 mins",
    );
  }

  static PracticeTechnique _getPractice(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('millet') || lowerName.contains('porridge') || lowerName.contains('diabetes')) {
      return const PracticeTechnique(
        title: "Mandukasana (Frog Pose)",
        iconPath: "assets/images/practice_yoga.png",
        howTo: [
          "Sit in Vajrasana (kneeling position)",
          "Place fists near navel, press inward",
          "Bend forward slowly, hold for 30s",
          "Repeat 3 times for pancreatic activation",
        ],
      );
    }
    return const PracticeTechnique(
      title: "Anulom Vilom Pranayama",
      iconPath: "assets/images/practice_breath.png",
      howTo: [
        "Sit comfortably in Sukhasana",
        "Close right nostril with thumb, inhale from left",
        "Close left, exhale from right. Repeat for 5 mins",
      ],
    );
  }

  static EscalationCriteria _getEscalation(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('millet') || lowerName.contains('porridge') || lowerName.contains('diabetes')) {
      return const EscalationCriteria(
        hourThreshold: 24,
        guidance: "Seek immediate care for blurred vision, extreme thirst, or if fasting glucose exceeds 200mg/dL.",
        redFlags: [
          "Fasting Glucose > 250mg/dL",
          "Persistent blurred vision",
          "Sudden fatigue or confusion",
        ],
      );
    }
    return const EscalationCriteria(
      hourThreshold: 48,
      guidance: "Seek professional care if fever exceeds 101°F or if symptoms persist for more than 48 hours.",
      redFlags: [
        "Fever > 101.5°F",
        "Persistent chest pain",
        "Shortness of breath",
      ],
    );
  }
}
