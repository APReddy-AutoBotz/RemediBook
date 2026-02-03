import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/sanctuary_background.dart';
import 'package:remedibook/core/widgets/remedi_widgets.dart'; // Verified Name
import 'package:remedibook/core/utils/verification_label_resolver.dart';
import 'package:remedibook/features/discovery/domain/models/remedy.dart';
import 'package:remedibook/features/remedies/presentation/widgets/triad_of_trust.dart';
import 'package:remedibook/features/remedies/presentation/widgets/dynamic_refiners.dart';
import 'package:remedibook/features/remedies/presentation/widgets/prep_steps.dart';
import 'package:remedibook/features/remedies/presentation/widgets/ingredient_inventory.dart';
import 'package:remedibook/features/remedies/presentation/widgets/safety_escalation_banner.dart';
import 'package:remedibook/features/remedies/presentation/widgets/commerce_sheet.dart';
import 'package:remedibook/features/remedies/presentation/widgets/consultation_sheet.dart';
import 'package:remedibook/features/artifact/presentation/screens/artifact_experience_screen.dart';

class RemedyDetailScreen extends StatefulWidget {
  final String remedyId;
  final Remedy? remedy; // Optional remedy object
  final String? userRegion;
  final bool simulateChildProfile; // For demo verification

  const RemedyDetailScreen({
    super.key,
    required this.remedyId,
    this.remedy,
    this.userRegion,
    this.simulateChildProfile = false,
  });

  @override
  State<RemedyDetailScreen> createState() => _RemedyDetailScreenState();
}

class _RemedyDetailScreenState extends State<RemedyDetailScreen> {
  late Remedy _remedy;
  bool _isReloading = false;
  
  @override
  void initState() {
    super.initState();
    _remedy = widget.remedy ?? _getFallbackRemedy();
  }
  
  /// Create fallback remedy if none provided
  Remedy _getFallbackRemedy() {
    return Remedy(
      id: widget.remedyId,
      name: 'Ginger-Tulsi Tea',
      description: 'A soothing traditional infusion known to clear respiratory pathways and boost cellular resilience.',
      symptoms: ['cold', 'cough'],
      ingredients: [
        'Fresh Ginger Root (2 inch)',
        'Organic Holy Basil (Tulsi) Leaves',
        'Raw Forest Honey',
        'Black Peppercorns (Optional)',
      ],
      instructions: [
        'Bring water to boil',
        'Add ginger and tulsi',
        'Simmer for 10 minutes',
        'Add honey when warm',
      ],
      fibreToCarbRatio: 0.0,
      category: 'Respiratory Health',
    );
  }

  void _handleRefinerSelection(String refiner) async {
    // TODO: Call Gemini API for refinement in future
    setState(() => _isReloading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isReloading = false);
    }
  }
  
  /// Get traditional root content from remedy or generate default
  String _getTraditionalRoot() {
    // 1. Check for AI-generated specific wisdom
    if (_remedy.traditionalWisdom != null && _remedy.traditionalWisdom!.isNotEmpty) {
      return _remedy.traditionalWisdom!;
    }
    
    // Check if remedy has evidence ledger with traditional wisdom
    if (_remedy.evidenceLedger != null) {
      // For physician-approved remedies, use curated content
      if (_remedy.name.contains("Ginger") && _remedy.name.contains("Tulsi")) {
        return "Ayurveda classifies ginger (Adrak) as 'Vishwabhesaj', the universal medicine. Combined with Tulsi, it balances Kapha and Vata doshas, clearing mucus and stimulating Agni (digestive fire).";
      } else if (_remedy.name.contains("Kodo Millet")) {
        return "Kodo millet (Varagu) is revered in ancient Ayurvedic texts as a sattvic grain that stabilizes blood sugar. It pacifies Kapha dosha and supports Ojas (vital essence) for sustained energy.";
      } else if (_remedy.name.contains("Foxtail Millet")) {
        return "Foxtail millet (Thinai) is cooling in nature and reduces Pitta dosha. Ancient wisdom describes it as ideal for managing inflammation and supporting respiratory wellness.";
      }
    }
    
    // Default for AI-generated remedies
    return "This remedy combines time-tested ingredients from traditional wellness practices. The synergy of natural compounds has been used for centuries across diverse healing traditions.";
  }
  
  /// Get science evidence from remedy citations or generate default
  String _getScienceEvidence() {
    // 1. Check for AI-generated scientific context (even if valid ledger exists, this adds context)
    if (_remedy.scientificContext != null && _remedy.scientificContext!.isNotEmpty) {
       // If we have both context AND specific citations, combine them
       if (_remedy.evidenceLedger != null && _remedy.evidenceLedger!.primarySources.isNotEmpty) {
         final firstSource = _remedy.evidenceLedger!.primarySources.first;
         return "${_remedy.scientificContext} Supported by: ${firstSource.title} (${firstSource.source}).";
       }
       return _remedy.scientificContext!;
    }
    
    if (_remedy.evidenceLedger != null && _remedy.evidenceLedger!.primarySources.isNotEmpty) {
      // Build citation string from actual sources
      final firstSource = _remedy.evidenceLedger!.primarySources.first;
      return "${firstSource.title}. Published in ${firstSource.source}. ${_remedy.evidenceLedger!.sourceCount} peer-reviewed studies support this remedy's efficacy.";
    }
    
    // Default for AI-generated
    return "Modern research continues to explore the bioactive compounds in these ingredients. Preliminary studies suggest potential health benefits, though more clinical research is needed.";
  }
  
  /// Get safety contraindications
  String _getSafetyContraindications() {
    // 1. Check for AI-generated safety context
    if (_remedy.safetyContext != null && _remedy.safetyContext!.isNotEmpty) {
      return _remedy.safetyContext!;
    }

    // Check remedy category for specific warnings
    if (_remedy.category.toLowerCase().contains("diabetes") || _remedy.name.contains("Millet")) {
      return "Generally safe for most adults. Monitor blood sugar levels if diabetic. Consult physician before making major dietary changes. Not recommended for children under 2 years.";
    } else if (_remedy.category.toLowerCase().contains("respiratory")) {
      return "Generally safe. Caution advised for those on blood-thinning medication or with gallstones. Discontinue 2 weeks before scheduled surgery. Avoid if allergic to ingredients.";
    }
    
    // Default safety
    return "Consult a healthcare provider if you have pre-existing conditions, are pregnant, nursing, or taking medications. Discontinue use if adverse reactions occur.";
  }

  @override
  Widget build(BuildContext context) {
    // Resolve verification label
    final verificationLabel = VerificationLabelResolver.getLabel(userRegion: widget.userRegion);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          const SanctuaryBackground(
            child: SizedBox.expand(),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: RemediTheme.deepTeal),
                      ),
                      // Region-Aware Verification Pill (Top Right)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFFD4A373)),
                            const SizedBox(width: 6),
                            Text(
                              verificationLabel.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8C6B4A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HERO SECTION
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: RemediTheme.deepTeal.withOpacity(0.05),
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                              boxShadow: _isReloading ? [
                                BoxShadow(color: RemediTheme.deepTeal.withOpacity(0.2), blurRadius: 20)
                              ] : [],
                            ),
                            // Placeholder Image
                            child: const Icon(Icons.spa_rounded, size: 48, color: RemediTheme.deepTeal),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Bookmark (Subtle)
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.bookmark_border, color: RemediTheme.charcoal),
                            onPressed: () {},
                            tooltip: "Save Remedy",
                          ),
                        ),
                        const SizedBox(height: 16), // Added spacing after buttons
                        
                        // TITLE & SAFETY
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isReloading ? 0.5 : 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                            _remedy.name,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.crimsonPro(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w400, // Regular weight for elegance
                                  color: RemediTheme.deepTeal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Safety Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: RemediTheme.mutedSage.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Safe", // Default safety level
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: RemediTheme.darkForest,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _remedy.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: RemediTheme.charcoal.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // SAFETY ESCALATION BANNER (Dynamic)
                        Builder(
                          builder: (context) {
                            // Mock logic for demo purposes
                            SafetyRiskLevel level = SafetyRiskLevel.safe;
                            String title = "";
                            String desc = "";
                            
                            // 1. Check Age/Profile Context (Phase 7 Integration)
                            if (widget.simulateChildProfile) {
                               level = SafetyRiskLevel.urgent;
                               title = "Age Restriction";
                               desc = "This remedy is not suitable for children under 12. Please consult a pediatrician.";
                            }
                            // 2. Check Remedy Specifics
                            else if (_remedy.category.contains("Adults")) { // Assuming category might contain safety info
                              level = SafetyRiskLevel.caution;
                              title = "Potency Warning";
                              desc = "This remedy is highly concentrated. Not suitable for children, pregnant women, or individuals with gastric sensitivity.";
                            } 
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: SafetyEscalationBanner(
                                level: level,
                                title: title,
                                description: desc,
                                onEscalate: () {},
                              ),
                            );
                          }
                        ),
                        
                        // TRIAD OF TRUST - use dynamic remedy data
                        TriadOfTrust(
                          traditionalRoot: _getTraditionalRoot(),
                          scienceEvidence: _getScienceEvidence(),
                          safetyContraindications: _getSafetyContraindications(),
                          enableMotion: true,
                        ),
                        const SizedBox(height: 24),
                        
                        // Dynamic Refiners
                        DynamicRefiners(
                          onRefinerSelected: _handleRefinerSelection,
                          isLoading: _isReloading,
                        ),
                        const SizedBox(height: 24),
                        
                        // Prep Steps & Timer - use remedy instructions
                        PrepSteps(remedyInstructions: _remedy.instructions),
                        const SizedBox(height: 24),

                        // Ingredient Inventory - use remedy ingredients
                        IngredientInventory(
                          ingredients: _remedy.ingredients,
                          onOrderNow: (items) {
                            showModalBottomSheet(
                              context: context, 
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => CommerceSheet(neededIngredients: items),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        
                        // Artifact Generation Entry Point
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtifactExperienceScreen(
                                    remedyId: widget.remedyId,
                                    title: _remedy.name,
                                    remedy: _remedy,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history_edu_rounded, color: RemediTheme.deepTeal), // Scroll/History icon
                            label: Text(
                              "Generate Wellness Guide",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: RemediTheme.deepTeal,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        // Consultation Fallback (Footer)
                        // "Symptoms Persisting? Consult a Specialist"
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: RemediTheme.charcoal.withOpacity(0.05)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Symptoms Persisting?",
                                style: GoogleFonts.lora(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  color: RemediTheme.charcoal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "If home remedies aren't providing relief, we can connect you with verified specialists.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: RemediTheme.charcoal.withOpacity(0.6),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => ConsultationSheet(ailmentName: _remedy.category),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: RemediTheme.deepTeal,
                                    side: const BorderSide(color: RemediTheme.deepTeal, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.medical_services_outlined, size: 18),
                                  label: Text(
                                    "Consult Specialist",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
