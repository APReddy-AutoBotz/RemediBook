import 'evidence_ledger.dart';
import 'fulfillment_models.dart';

/// Remedy Model - Core remedy data structure
/// Aligned with REMEDIBOOK_ARCHITECTURE.md Pillar 4
class Remedy {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final double fibreToCarbRatio;
  final EvidenceLedger? evidenceLedger; // Nullable for AI-generated remedies

  final List<String> symptoms;
  final String category;
  
  // Gemini 3 Synthesized Fulfillment Tier
  final PracticeTechnique? practice;
  final EscalationCriteria? escalation;
  final List<PrepStep>? prepSteps; // Structured preparation steps with timing

  const Remedy({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.fibreToCarbRatio,
    this.evidenceLedger, // Nullable for AI-generated remedies
    required this.symptoms,
    required this.category,
    this.practice,
    this.escalation,
    this.prepSteps,
    this.traditionalWisdom,
    this.scientificContext,
    this.safetyContext,
  });

  // Dynamic Context for Triad (AI Generated)
  final String? traditionalWisdom;
  final String? scientificContext;
  final String? safetyContext;

}
