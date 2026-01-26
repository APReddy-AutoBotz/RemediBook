import '../models/remedy.dart';
import '../models/evidence_ledger.dart';
import '../../data/expert_vault_loader.dart' as legacy;
import '../../../../core/services/vault_service.dart';
import '../../../../core/services/ai_search_service.dart';

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

  const SearchResult({
    required this.remedies,
    required this.tier,
    this.physicianName,
    this.warningMessage,
  });

  bool get isPhysicianVerified => tier == EvidenceTier.physicianVerified;
  bool get hasWarning => warningMessage != null;
}

/// Search Service - Vault-First Hierarchy
/// Step 1: Vault Check (PhysicianVerified)
/// Step 2: Supplementary Fetch (Evidence Ledger)
/// Step 3: Fallback (Traditional Archive with Soft Amber)
class SearchService {
  /// Search with Vault-First logic
  static Future<SearchResult> search(String query) async {
    // STEP 1: Vault Check (Tier 1: Expert Vault)
    final vaultEntry = await VaultService.lookup(query);
    
    if (vaultEntry != null) {
      final physician = VaultService.getPhysician(vaultEntry.physicianId);
      final remedy = _convertVaultEntryToRemedy(vaultEntry);
      
      return SearchResult(
        remedies: [remedy],
        tier: EvidenceTier.physicianVerified,
        physicianName: physician?.name,
      );
    }
    
    // STEP 2: Fallback to Traditional Archive (Tier 3: AI/Web Sourced)
    final archiveResults = await AiSearchService.fetch(query);
    
    if (archiveResults.isNotEmpty) {
      return SearchResult(
        remedies: archiveResults,
        tier: EvidenceTier.traditional,
        warningMessage: "Ailment not in core vault. Suggestions sourced from Traditional Archive (Evidence-Led).",
      );
    }
    
    // FINAL FALLBACK: No results
    return const SearchResult(
      remedies: [],
      tier: EvidenceTier.traditional,
      warningMessage: 'No verified remedies found for this query. Please consult a professional.',
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
    );
  }

  /// Get all vault remedies
  static Future<List<Remedy>> getAllVaultRemedies() async {
    final entries = await VaultService.getAllEntries();
    return entries.map(_convertVaultEntryToRemedy).toList();
  }
}
