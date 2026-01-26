import 'evidence_ledger.dart';

/// Remedy Model - Core remedy data structure
/// Aligned with REMEDIBOOK_ARCHITECTURE.md Pillar 4
class Remedy {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final double fibreToCarbRatio;
  final EvidenceLedger evidenceLedger;
  final List<String> symptoms;
  final String category;

  const Remedy({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.fibreToCarbRatio,
    required this.evidenceLedger,
    required this.symptoms,
    required this.category,
  });
}
