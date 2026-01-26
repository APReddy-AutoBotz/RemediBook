import 'dart:convert';
import 'package:flutter/services.dart';

/// Physician Information
class PhysicianInfo {
  final String id;
  final String name;
  final String specialty;

  const PhysicianInfo({
    required this.id,
    required this.name,
    required this.specialty,
  });
}

/// Vault Entry - Expert-verified remedy
class VaultEntry {
  final String ailmentId;
  final String name;
  final String remedy;
  final List<String> ingredients;
  final String dosage;
  final List<String> sources;
  final String physicianId;
  final String evidenceLabel;
  final List<String> contraindications;

  const VaultEntry({
    required this.ailmentId,
    required this.name,
    required this.remedy,
    required this.ingredients,
    required this.dosage,
    required this.sources,
    required this.physicianId,
    required this.evidenceLabel,
    required this.contraindications,
  });
}

/// Vault Service - O(1) lookups for expert-verified remedies
/// Implements Tier 1: Expert Vault (PhysicianVerified)
class VaultService {
  static Map<String, VaultEntry>? _vaultCache;
  static final Map<String, PhysicianInfo> _physicians = {
    'DR_AYUR_001': PhysicianInfo(
      id: 'DR_AYUR_001',
      name: 'Dr. Priya Sharma',
      specialty: 'Ayurvedic Medicine',
    ),
    'DR_AYUR_002': PhysicianInfo(
      id: 'DR_AYUR_002',
      name: 'Dr. Rajesh Kumar',
      specialty: 'Ayurvedic Medicine',
    ),
    'DR_AYUR_003': PhysicianInfo(
      id: 'DR_AYUR_003',
      name: 'Dr. Meera Patel',
      specialty: 'Ayurvedic Medicine',
    ),
    'DR_NUTR_001': PhysicianInfo(
      id: 'DR_NUTR_001',
      name: 'Dr. Anita Desai',
      specialty: 'Clinical Nutrition',
    ),
    'DR_NUTR_002': PhysicianInfo(
      id: 'DR_NUTR_002',
      name: 'Dr. Vikram Singh',
      specialty: 'Integrative Nutrition',
    ),
    'DR_DERM_001': PhysicianInfo(
      id: 'DR_DERM_001',
      name: 'Dr. Sunita Reddy',
      specialty: 'Dermatology',
    ),
  };

  /// Initialize vault - O(n) one-time cost, then O(1) lookups
  static Future<void> initialize() async {
    if (_vaultCache != null) return;

    try {
      final csvString = await rootBundle.loadString('assets/data/expert_vault.csv');
      final lines = const LineSplitter().convert(csvString);
      
      _vaultCache = {};
      
      // Skip header
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final entry = _parseVaultEntry(line);
        if (entry != null) {
          // Index by ailment_id AND name for flexible lookups
          _vaultCache![entry.ailmentId] = entry;
          _vaultCache![entry.name.toLowerCase()] = entry;
          _vaultCache![entry.remedy.toLowerCase()] = entry;
        }
      }
    } catch (e) {
      print('Error initializing vault: $e');
      _vaultCache = {};
    }
  }

  /// Parse CSV line into VaultEntry
  static VaultEntry? _parseVaultEntry(String line) {
    try {
      final fields = _parseCsvLine(line);
      if (fields.length < 9) return null;

      return VaultEntry(
        ailmentId: fields[0].trim(),
        name: fields[1].trim(),
        remedy: fields[2].trim(),
        ingredients: fields[3].split(';').map((s) => s.trim()).toList(),
        dosage: fields[4].trim(),
        sources: fields[5].split('|').map((s) => s.trim()).toList(),
        physicianId: fields[6].trim(),
        evidenceLabel: fields[7].trim(),
        contraindications: fields[8].split(';').map((s) => s.trim()).toList(),
      );
    } catch (e) {
      print('Error parsing vault entry: $e');
      return null;
    }
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
    
    fields.add(buffer.toString());
    return fields;
  }

  /// O(1) Vault lookup by query
  static Future<VaultEntry?> lookup(String query) async {
    await initialize();
    
    final lowerQuery = query.toLowerCase().trim();
    
    // Direct lookup
    if (_vaultCache!.containsKey(lowerQuery)) {
      return _vaultCache![lowerQuery];
    }
    
    // Partial match search
    for (final entry in _vaultCache!.values) {
      if (entry.name.toLowerCase().contains(lowerQuery) ||
          entry.remedy.toLowerCase().contains(lowerQuery)) {
        return entry;
      }
    }
    
    return null;
  }

  /// Get physician info
  static PhysicianInfo? getPhysician(String physicianId) {
    return _physicians[physicianId];
  }

  /// Check if query is in vault
  static Future<bool> isInVault(String query) async {
    final entry = await lookup(query);
    return entry != null;
  }

  /// Get all vault entries
  static Future<List<VaultEntry>> getAllEntries() async {
    await initialize();
    return _vaultCache!.values.toSet().toList();
  }
}
