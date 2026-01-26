import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/remedy.dart';
import '../domain/models/evidence_ledger.dart';

/// Expert Vault Loader
/// Loads remedies from expert_vault.csv (The Golden 10 Ailments)
/// Grounding Rule: Never suggest a remedy NOT found in the expert_vault
class ExpertVaultLoader {
  static List<Remedy>? _cachedRemedies;

  /// Load all remedies from expert_vault.csv
  static Future<List<Remedy>> loadRemedies() async {
    if (_cachedRemedies != null) {
      return _cachedRemedies!;
    }

    try {
      final csvString = await rootBundle.loadString('assets/data/expert_vault.csv');
      final lines = const LineSplitter().convert(csvString);
      
      // Skip header row
      final dataLines = lines.skip(1);
      
      final remedies = <Remedy>[];
      
      for (final line in dataLines) {
        if (line.trim().isEmpty) continue;
        
        final remedy = _parseRemedyFromCsv(line);
        if (remedy != null) {
          remedies.add(remedy);
        }
      }
      
      _cachedRemedies = remedies;
      return remedies;
    } catch (e) {
      print('Error loading expert_vault.csv: $e');
      return [];
    }
  }

  /// Parse a single CSV line into a Remedy object
  static Remedy? _parseRemedyFromCsv(String line) {
    try {
      final fields = _parseCsvLine(line);
      
      // Sync with 9-column format from VaultService
      if (fields.length < 9) return null;

      final id = fields[0].trim();
      final ailmentName = fields[1].trim();
      final remedyName = fields[2].trim();
      final ingredients = fields[3].split(';').map((s) => s.trim()).toList();
      final dosage = fields[4].trim();
      final sourcesList = fields[5].split('|').map((s) => s.trim()).toList();
      final physicianId = fields[6].trim();
      final labelText = fields[7].trim();
      final contraindications = fields[8].split(';').map((s) => s.trim()).toList();
      
      // Parse evidence sources
      final sources = _parseEvidenceSources(fields[5], id);
      
      // Parse evidence label
      final evidenceLabel = labelText.toLowerCase().contains('physician')
          ? EvidenceLabel.evidenceSupported // Still Tier 2 in legacy view
          : EvidenceLabel.traditional;

      // Create Evidence Ledger
      final evidenceLedger = EvidenceLedger(
        remedyId: id,
        label: evidenceLabel,
        reviewDate: DateTime.now().subtract(const Duration(days: 30)),
        sourceCount: sources.length,
        primarySources: sources,
        notes: 'Sourced from expert archive.',
      );

      return Remedy(
        id: id,
        name: remedyName,
        description: 'Traditional remedy for $ailmentName. Dosage: $dosage',
        ingredients: ingredients,
        instructions: [dosage],
        fibreToCarbRatio: 0.0,
        evidenceLedger: evidenceLedger,
        symptoms: [ailmentName.toLowerCase(), ...remedyName.toLowerCase().split(' ')],
        category: 'Traditional Remedy',
      );
    } catch (e) {
      print('Error parsing remedy line: $e');
      return null;
    }
  }

  /// Parse evidence sources from CSV field
  static List<Citation> _parseEvidenceSources(String sourcesText, String remedyId) {
    final sources = <Citation>[];
    final sourceList = sourcesText.split('|');
    
    for (var i = 0; i < sourceList.length; i++) {
      final source = sourceList[i].trim();
      if (source.isEmpty) continue;
      
      // Parse format: "Author et al. Journal Year"
      final parts = source.split('.');
      if (parts.length >= 2) {
        final authors = parts[0].trim();
        final rest = parts.sublist(1).join('.').trim();
        
        sources.add(Citation(
          id: '${remedyId}_cit_${i + 1}',
          title: rest,
          source: rest,
          url: 'https://pubmed.ncbi.nlm.nih.gov/',
          publicationDate: DateTime(2020, 1, 1), // Default date
          authors: authors,
        ));
      }
    }
    
    return sources;
  }

  /// Parse CSV line handling quoted fields
  static List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    // Add last field
    fields.add(buffer.toString());
    
    return fields;
  }

  /// Search remedies by symptom
  static Future<List<Remedy>> searchBySymptom(String query) async {
    final remedies = await loadRemedies();
    final lowerQuery = query.toLowerCase().trim();
    
    return remedies.where((remedy) {
      return remedy.symptoms.any((symptom) => symptom.toLowerCase().contains(lowerQuery)) ||
          remedy.name.toLowerCase().contains(lowerQuery) ||
          remedy.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get remedy by ID
  static Future<Remedy?> getById(String id) async {
    final remedies = await loadRemedies();
    try {
      return remedies.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all remedies
  static Future<List<Remedy>> getAll() async {
    return loadRemedies();
  }
}
