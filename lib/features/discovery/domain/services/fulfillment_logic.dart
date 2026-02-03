import 'package:flutter/material.dart';
import '../models/fulfillment_models.dart';
import '../models/remedy.dart';
import '../../../../core/services/fulfillment_engine.dart';



/// Fulfillment Logic Service
/// Pillar 2 & 4: Discovery & Evidence Ledger
/// 
/// Now uses FulfillmentEngine for Consistency Handshake:
/// - Dynamic Material Extraction from Prep Steps
/// - Vernacular Bridge for local commerce
/// - Null Inventory Gate for action-only remedies
class FulfillmentService {
  /// Fetches fulfillment data for a specific remedy
  static Future<FulfillmentData> getFulfillmentData(String remedyId, String remedyName, {Remedy? remedy}) async {
    // Get preparation steps (prioritize Gemini-sourced structured steps)
    List<PrepStep> prepSteps;
    
    if (remedy != null && remedy.prepSteps != null && remedy.prepSteps!.isNotEmpty) {
      // BEST: Use structured prepSteps from Gemini
      prepSteps = remedy.prepSteps!;
    } else if (remedy != null && remedy.instructions.isNotEmpty) {
      // GOOD: Convert instructions to PrepSteps
      prepSteps = remedy.instructions.map((instr) => PrepStep(instr)).toList();
    } else {
      // FALLBACK: Use hardcoded logic (Expert Vault entries only)
      prepSteps = _getPrepSteps(remedyName);
    }
    
    // CONSISTENCY HANDSHAKE: Use FulfillmentEngine for dynamic material extraction
    final fulfillmentContext = FulfillmentEngine.analyze(prepSteps);
    
    // Safety Twin Check (Simulation)
    final bool hasHighHeat = remedyName.toLowerCase().contains('tea') || 
                            remedyName.toLowerCase().contains('milk') ||
                            remedyName.toLowerCase().contains('porridge');
    
    return FulfillmentData(
      remedyName: remedyName,
      vernacularName: _getVernacularName(remedyName),
      vernacularWisdom: _getVernacularWisdom(remedyName),
      prepSteps: prepSteps,
      materials: fulfillmentContext.extractedMaterials,
      hasPhysicalMaterials: fulfillmentContext.hasPhysicalMaterials,
      priceComparison: _getMockPrices(),
      practice: remedy?.practice ?? _getPractice(remedyName),
      escalation: remedy?.escalation ?? _getEscalation(remedyName),
      safetyWarning: hasHighHeat,
      safetyMessage: hasHighHeat 
        ? "Soft Amber: Preparation requires boiling water. Exercise caution to avoid scalds." 
        : null,
    );
  }

  static String? _getVernacularName(String name) {
    if (name.toLowerCase().contains('ginger')) return "Shunti Kashayam";
    if (name.toLowerCase().contains('millet')) return "Siridhanya Ganji";
    return null;
  }

  static String? _getVernacularWisdom(String name) {
    if (name.toLowerCase().contains('ginger')) return "Grandmother's 'Golden Sip' for digestive fire.";
    if (name.toLowerCase().contains('millet')) return "The 'Ancient Strength' protocol for metabolic health.";
    return null;
  }

  static List<PrepStep> _getPrepSteps(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('tea') || lowerName.contains('kashayam') || lowerName.contains('ginger')) {
      return [
        const PrepStep("Boil 250ml of filtered water", durationSeconds: 180),
        const PrepStep("Add crushed ginger and tulsi leaves"),
        const PrepStep("Simmer on low heat for 5 minutes", durationSeconds: 300),
        const PrepStep("Strain and add honey when warm, not hot"),
      ];
    } else if (lowerName.contains('porridge') || lowerName.contains('millet')) {
      return [
        const PrepStep("Soak millet for 4-6 hours for enzyme activation"),
        const PrepStep("Mix with buttermilk or seasoned water"),
      ];
    } else if (lowerName.contains('cold') || lowerName.contains('cough')) {
      return [
        const PrepStep("Steam inhalation for 10 minutes", durationSeconds: 600),
        const PrepStep("Gargle with warm salt water"),
        const PrepStep("Sip Tulsi-Ginger tea throughout the day"),
      ];
    } else if (lowerName.contains('headache')) {
      return [
        const PrepStep("Massage peppermint oil on temples"),
        const PrepStep("Rest in a dark, quiet room", durationSeconds: 1800),
        const PrepStep("Apply a cold compress to the neck"),
      ];
    } else if (lowerName.contains('leg pain') || lowerName.contains('rice')) {
      return [
        const PrepStep("Rest the leg in an elevated position"),
        const PrepStep("Apply ice pack for 15-20 minutes", durationSeconds: 1200),
        const PrepStep("Compress with a light bandage if swelling is present"),
        const PrepStep("Elevate the leg above heart level"),
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
    } else if (lowerName.contains('cold') || lowerName.contains('cough')) {
      return [
        const IngredientStatus("Tulsi Leaves", true),
        const IngredientStatus("Honey", true),
        const IngredientStatus("Ginger", true),
      ];
    } else if (lowerName.contains('headache')) {
      return [
        const IngredientStatus("Peppermint Oil", false),
        const IngredientStatus("Sleep Mask", true),
      ];
    } else if (lowerName.contains('leg pain')) {
      return [
        const IngredientStatus("Compression Bandage", true),
        const IngredientStatus("Ice Pack", true),
        const IngredientStatus("Magnesium Supplements", false),
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
        icon: Icons.self_improvement_outlined,
        howTo: [
          "Sit in Vajrasana (kneeling position)",
          "Place fists near navel, press inward",
          "Bend forward slowly, hold for 30s",
          "Repeat 3 times for pancreatic activation",
        ],
      );
    } else if (lowerName.contains('cold') || lowerName.contains('congestion')) {
      return const PracticeTechnique(
        title: "Jala Neti (Nasal Rinse)",
        icon: Icons.water_drop_outlined,
        howTo: [
          "Use a Neti pot with lukewarm saline water",
          "Tilt head and pour into one nostril",
          "Let it flow out from the other",
          "Gently blow nose to clear",
        ],
      );
    } else if (lowerName.contains('headache')) {
      return const PracticeTechnique(
        title: "Neck Stretches",
        icon: Icons.accessibility_new_rounded,
        howTo: [
          "Slowly tilt head to each shoulder",
          "Hold for 15 seconds each side",
          "Repeat forward and backward tilts",
          "Release tension in the traps",
        ],
      );
    } else if (lowerName.contains('leg pain')) {
      return const PracticeTechnique(
        title: "Legs-Up-The-Wall (Viparita Karani)",
        icon: Icons.self_improvement_rounded,
        howTo: [
          "Lie on your back near a wall",
          "Extend legs straight up against the wall",
          "Relax for 5-10 minutes to improve circulation",
          "Focus on deep abdominal breathing",
        ],
      );
    }
    return const PracticeTechnique(
      title: "Anulom Vilom Pranayama",
      icon: Icons.air_rounded,
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
        isBookingAvailable: true,
        clinicName: "Apollo Sugar Clinics",
      );
    } else if (lowerName.contains('cold') || lowerName.contains('cough')) {
      return const EscalationCriteria(
        hourThreshold: 72,
        guidance: "Consult if you have a persistent cough with colored phlegm or high fever.",
        redFlags: [
          "Difficulty breathing",
          "High fever > 102°F",
          "Coughing up blood",
        ],
        isBookingAvailable: true,
        clinicName: "Medanta (Respiratory Care)",
      );
    } else if (lowerName.contains('headache')) {
      return const EscalationCriteria(
        hourThreshold: 24,
        guidance: "Seek care for 'thunderclap' headaches or if accompanied by vision loss.",
        redFlags: [
          "Sudden, severe 'worst' headache",
          "Confusion or fainting",
          "Numbness or weakness",
        ],
        isBookingAvailable: true,
        clinicName: "NIMHANS (Neurology)",
      );
    } else if (lowerName.contains('leg pain')) {
      return const EscalationCriteria(
        hourThreshold: 72,
        guidance: "Seek care if you cannot bear weight, or if you see significant redness and warmth.",
        redFlags: [
          "Inability to walk or bear weight",
          "Sudden, severe swelling in one leg",
          "Leg is cold or pale compared to other",
        ],
        isBookingAvailable: true,
        clinicName: "MaxCure Hospitals (Orthopedics)",
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
      isBookingAvailable: true,
      clinicName: "Rainbow Hospitals (Emergency)",
    );
  }
}
