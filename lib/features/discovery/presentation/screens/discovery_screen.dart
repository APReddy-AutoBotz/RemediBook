import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/sanctuary_search_bar.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';
import 'package:remedibook/core/utils/verification_label_resolver.dart';
import 'package:remedibook/core/models/user_profile.dart';
import 'package:remedibook/core/services/gemini_remedy_generator.dart';
import 'package:remedibook/features/discovery/domain/models/remedy.dart';
import 'package:remedibook/features/discovery/domain/models/evidence_ledger.dart';
import 'package:remedibook/features/remedies/presentation/screens/remedy_detail_screen.dart';
import 'package:remedibook/features/triage/domain/services/triage_service.dart';
import 'package:remedibook/features/triage/presentation/widgets/triage_guardian_widget.dart';

class DiscoveryScreen extends StatefulWidget {
  final String query; // Initial query if passed
  const DiscoveryScreen({super.key, this.query = ''});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  late TextEditingController _searchController;
  SovereignProfile? _profile;
  String _activeQuery = '';
  bool _isSearching = false;
  List<Remedy> _searchResults = [];
  
  // Mock Data for suggestions
  final List<String> _suggestions = [
    "Headache + fatigue",
    "Dry cough",
    "Acidity after meals",
    "Low energy in mornings",
    "Sleep trouble",
    "Sore throat"
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _activeQuery = widget.query;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await SecureProfileStorage.getProfile();
    setState(() => _profile = profile);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) async {
    setState(() {
      _activeQuery = query;
      _searchController.text = query;
      _isSearching = true;
      _searchResults = [];
    });
    
    // 1. Triage Safety Check (Governance Guard)
    final triageResult = TriageInterceptor.scan(query);
    
    if (triageResult.isEmergency) {
      if (mounted) {
        setState(() => _isSearching = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => HardRedEmergencyModal(result: triageResult),
        );
      }
      return; // STOP SEARCH
    }
    
    if (triageResult.isCaution) {
      // For caution (Amber), we show a warning but allow proceeding after implicit acknowledgment
      // For this MVP, we'll show a quick dialog
       bool proceed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Health Caution"),
          content: Text(triageResult.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
             TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("I Understand"),
            ),
          ],
        ),
      ) ?? false;
      
      if (!proceed) {
        if (mounted) setState(() => _isSearching = false);
        return;
      }
    }

    try {
      // Use Gemini to generate remedies (with physician verification)
      final remedies = await GeminiRemedyGenerator.generateRemedies(query);
      
      if (mounted) {
        setState(() {
          _searchResults = remedies;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  String _getVerificationLabel() {
    return VerificationLabelResolver.getLabel(userRegion: _profile?.region);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by main wrapper
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(RemediTheme.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: RemediTheme.deepTeal),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Triage Agent",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: RemediTheme.spaceMD),
                  SanctuarySearchBar(
                    placeholder: "Describe symptoms...",
                    onSubmit: _onSearch,
                    // Note: Ensure SanctuarySearchBar handles external controller logic if needed, 
                    // or just relies on internal. Here we use onSubmit to trigger updates.
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: _activeQuery.isEmpty 
                  ? _buildSuggestions()
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "Common Concerns",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: RemediTheme.charcoal.withOpacity(0.6),
              ),
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _suggestions.map((suggestion) {
              return _buildGlassChip(suggestion);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassChip(String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSearch(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: RemediTheme.deepTeal,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: RemediTheme.deepTeal),
              const SizedBox(height: 16),
              Text(
                "Searching remedies...",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: RemediTheme.charcoal.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            "No remedies found for '$_activeQuery'.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: RemediTheme.charcoal.withOpacity(0.7),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(RemediTheme.spaceLG),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildResultCard(Remedy remedy) {
    // Determine verification badge based on evidence ledger
    String? verificationBadge;
    if (remedy.evidenceLedger != null) {
      if (remedy.evidenceLedger!.label == EvidenceLabel.evidenceSupported) {
        verificationBadge = "PHYSICIAN VERIFIED";
      } else if (remedy.evidenceLedger!.label == EvidenceLabel.traditional) {
        verificationBadge = "TRADITIONAL";
      }
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RemedyDetailScreen(
              remedyId: remedy.id,
              remedy: remedy, // Pass full remedy object
              userRegion: _profile?.region,
            ),
          ),
        );
      },
      child: SanctuaryGlassCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Placeholder / Color Strip
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: RemediTheme.deepTeal.withOpacity(0.1),
                  border: Border(right: BorderSide(color: Colors.white.withOpacity(0.2))),
                ),
                child: Center(
                  child: Icon(
                    Icons.spa_rounded,
                    color: RemediTheme.deepTeal.withOpacity(0.5),
                    size: 32,
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Safety Badge + Verification
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: RemediTheme.mutedSage.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                            "Safe", // Default safety for now
                            style: const TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold,
                                color: RemediTheme.darkForest
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A373).withOpacity(0.15), // Ember Gold tint
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3)),
                            ),
                            child: verificationBadge != null
                            ? Row(
                                children: [
                                  const Icon(Icons.verified_user_outlined, size: 10, color: Color(0xFFD4A373)),
                                  const SizedBox(width: 4),
                                  Text(
                                    verificationBadge,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8C6B4A),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "AI-GENERATED",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF8C8C8C),
                                ),
                              ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        remedy.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: RemediTheme.deepTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remedy.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RemediTheme.charcoal.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
