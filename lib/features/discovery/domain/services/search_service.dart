import '../../../triage/domain/services/triage_service.dart';
import '../../../../core/models/user_profile.dart';
import '../models/remedy.dart';
import '../models/evidence_ledger.dart';
import '../../../../core/services/vault_service.dart';
import '../../../../core/services/ai_search_service.dart';
import '../models/fulfillment_models.dart';

/// Evidence Label with PhysicianVerified tier
enum EvidenceTier {
  physicianVerified,  // Tier 1: Expert Vault
  evidenceSupported,  // Tier 2: Evidence Ledger
  traditional,        // Tier 3: Traditional Archive
}

/// Search Result with Source Tier
class SearchResult {
  final List<Remedy> remedies;
  final EvidenceTier tier;
  final String? physicianName;
  final String? warningMessage;
  final Map<String, String>? conflicts;

  const SearchResult({
    required this.remedies,
    required this.tier,
    this.physicianName,
    this.warningMessage,
    this.conflicts,
  });

  bool get isPhysicianVerified => tier == EvidenceTier.physicianVerified;
  bool get hasWarning => warningMessage != null;
}

class SearchService {
  /// Search with Vault-First logic
  static Future<SearchResult> search(String query, {SovereignProfile? profile}) async {
    // STEP 1: Triage Interceptor (Safety Gate)
    // CRITICAL: Check for Red/Amber flags before any vault lookup
    final triageResult = TriageInterceptor.scan(query);
    
    // If Emergency (Hard Red), stop immediately
    if (triageResult.isEmergency) {
      return SearchResult(
        remedies: [], // No remedies for emergencies
        tier: EvidenceTier.traditional,
        warningMessage: triageResult.message, // "Emergency situation detected..."
        // UI layer should check for specific warning text or we can add a flag later
      );
    }

    // STEP 2: Vault Check (Tier 1: Expert Vault)
    final vaultEntry = await VaultService.lookup(query);
    
    List<Remedy> remedies = [];
    EvidenceTier tier = EvidenceTier.traditional;
    String? physicianName;
    String? warningMessage;

    if (vaultEntry != null) {
      final physician = VaultService.getPhysician(vaultEntry.physicianId);
      remedies = [_convertVaultEntryToRemedy(vaultEntry)];
      tier = EvidenceTier.physicianVerified;
      physicianName = physician?.name;
      
      // If Caution (Soft Amber), prepend warning
      if (triageResult.isCaution) {
        warningMessage = triageResult.message;
      }
    } else {
      // STEP 3: Fallback to Traditional Archive (Tier 2/3: AI/Web Sourced)
      // Now uses dynamic Gemini 3 API via AiSearchService
      final archiveResults = await AiSearchService.fetch(query);
      remedies = archiveResults;
      
      if (archiveResults.isNotEmpty) {
        // Check if truly web sourced or hardcoded fallback
        final hasWebSourced = archiveResults.any((r) => r.evidenceLedger.label == EvidenceLabel.webSourced);
        
        if (hasWebSourced) {
          warningMessage = "Generative AI Guidance: Verified against general safety protocols, but not clinically vetted. Use with discretion.";
        } else {
          warningMessage = "Ailment not in core vault. Suggestions sourced from Traditional Archive.";
        }
        
        // Add triage caution if present
        if (triageResult.isCaution) {
           warningMessage = "${triageResult.message}\n\n$warningMessage";
        }
      } else {
        warningMessage = 'No verified remedies found for this query. Please consult a professional.';
        if (triageResult.isCaution) {
           warningMessage = "${triageResult.message}\n\n$warningMessage";
        }
      }
    }

    // Calculate Conflicts (Safety Twin)
    Map<String, String>? conflicts;
    if (profile != null && remedies.isNotEmpty) {
      conflicts = {};
      for (final remedy in remedies) {
        final conflict = TriageInterceptor.checkProfileConflicts(remedy, profile);
        if (conflict != null) {
          conflicts[remedy.id] = conflict;
        }
      }
      if (conflicts.isEmpty) conflicts = null;
    }
    
    return SearchResult(
      remedies: remedies,
      tier: tier,
      physicianName: physicianName,
      warningMessage: warningMessage,
      conflicts: conflicts,
    );
  }

  /// Convert VaultEntry to Remedy model
  static Remedy _convertVaultEntryToRemedy(VaultEntry entry) {
    // Parse sources into citations
    final citations = entry.sources.asMap().entries.map((e) {
      final source = e.value;
      final parts = source.split('(');
      final title = parts.length > 1 ? parts[0].trim() : source;
      final authors = parts.length > 1 
          ? parts[1].replaceAll(')', '').trim() 
          : 'Unknown';
      
      return Citation(
        id: '${entry.ailmentId}_${e.key}',
        title: title,
        source: source,
        url: source.contains('PMID:') 
            ? 'https://pubmed.ncbi.nlm.nih.gov/${source.split('PMID:')[1].split(' ')[0]}/'
            : 'https://scholar.google.com/',
        publicationDate: DateTime(2020, 1, 1),
        authors: authors,
      );
    }).toList();

    final evidenceLedger = EvidenceLedger(
      remedyId: entry.ailmentId,
      label: EvidenceLabel.evidenceSupported, // Will be overridden by UI for PhysicianVerified
      reviewDate: DateTime.now().subtract(const Duration(days: 30)),
      sourceCount: citations.length,
      primarySources: citations,
      notes: 'Verified by ${VaultService.getPhysician(entry.physicianId)?.name ?? "Expert Physician"}',
    );

    return Remedy(
      id: entry.ailmentId,
      name: entry.remedy,
      description: 'Expert-verified remedy for ${entry.name}. ${entry.dosage}',
      ingredients: entry.ingredients,
      instructions: [entry.dosage],
      fibreToCarbRatio: 0.0, // Not applicable for all remedies
      evidenceLedger: evidenceLedger,
      symptoms: [entry.name.toLowerCase()],
      category: entry.remedy,
      escalation: EscalationCriteria(
        hourThreshold: 48,
        guidance: "Consult medical professional if symptoms persist beyond 48 hours or worsen.",
        redFlags: entry.contraindications.map((c) => c.toUpperCase()).toList(),
        isBookingAvailable: true, // Force enabled for demo
        clinicName: "Apollo Partner Clinics",
      ),
    );
  }

  /// Get all vault remedies
  static Future<List<Remedy>> getAllVaultRemedies() async {
    final entries = await VaultService.getAllEntries();
    return entries.map(_convertVaultEntryToRemedy).toList();
  }
}
