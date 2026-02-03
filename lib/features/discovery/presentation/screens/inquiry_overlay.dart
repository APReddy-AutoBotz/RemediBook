import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../domain/services/search_service.dart';
import '../../domain/models/remedy.dart';
import '../../domain/models/evidence_ledger.dart';
import '../widgets/remedy_card.dart';
import '../../../../core/widgets/remedi_widgets.dart';
import '../../../../core/widgets/sanctuary_glass_card.dart'; // Design Bible: Phase 2
import 'remedy_detail_screen.dart'; // Premium integration - RE-ENABLED
import '../../domain/services/fulfillment_logic.dart';
import '../../domain/models/fulfillment_models.dart';
import '../widgets/fulfillment_stack.dart';
import '../../../../core/models/user_profile.dart';
import '../../domain/safety_interceptor.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inquiry Overlay - Vault-First Search
/// Implements three-tier search hierarchy
class InquiryOverlay extends StatefulWidget {
  const InquiryOverlay({super.key});

  @override
  State<InquiryOverlay> createState() => _InquiryOverlayState();
}

class _InquiryOverlayState extends State<InquiryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  SearchResult? _searchResult;
  bool _hasSearched = false;
  bool _isLoading = false;
  
  // Conversational Triage State
  String? _clarifyingQuestion;
  bool _isAwaitingClarification = false;
  SovereignProfile? _userProfile;

  // Fulfillment State
  FulfillmentData? _activeFulfillment;
  String? _fulfillingRemedyId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _userProfile = await SecureProfileStorage.getProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _clarifyingQuestion = null;
      _isAwaitingClarification = false;
    });

    // Hard Red Interceptor check
    if (SafetyInterceptor.isEmergency(query)) {
      SafetyInterceptor.triggerRedAlert(context);
      setState(() => _isLoading = false);
      return;
    }

    // Gemini 3 Reasoning: Conversational Triage
    // Simulation: Asking clarifying questions based on profile
    await Future.delayed(const Duration(milliseconds: 1000));

    if (query.toLowerCase().contains('cough') && !_isAwaitingClarification) {
      setState(() {
        _clarifyingQuestion = "Is it a dry cough or accompanied by congestion? This helps me align with your Hyderabad heritage remedies.";
        _isAwaitingClarification = true;
        _isLoading = false;
      });
      return;
    }

    // Vault-First Search Logic
    final result = await SearchService.search(query, profile: _userProfile);

    setState(() {
      _searchResult = result;
      _hasSearched = true;
      _isLoading = false;
    });
  }

  void _submitClarification(String answer) {
    _performSearch("${_searchController.text} ($answer)");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _closeOverlay();
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Blurred Background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  color: RemediTheme.warmLimestone.withOpacity(0.85),
                ),
              ),

              // Content
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(RemediTheme.spaceMD),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: RemediTheme.deepTeal,
                              ),
                              onPressed: _closeOverlay,
                            ),
                            const SizedBox(width: RemediTheme.spaceXS),
                            Text(
                              'Symptom Discovery',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: RemediTheme.darkForest,
                                  ),
                            ),
                          ],
                        ),
                      ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RemediTheme.spaceMD,
                      ),
                      child: Container(
                        decoration: RemediDecorations.stone(
                          borderRadius: RemediTheme.radiusStone,
                          shadowOpacity: 0.05,
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            _performSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search symptoms or remedies...',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: RemediTheme.charcoal.withOpacity(0.4),
                                ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: RemediTheme.deepTeal.withOpacity(0.6),
                            ),
                            suffixIcon: _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: RemediTheme.deepTeal,
                                      ),
                                    ),
                                  )
                                : _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.send,
                                          color: RemediTheme.deepTeal,
                                        ),
                                        onPressed: () {
                                          _performSearch(_searchController.text);
                                        },
                                      )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(
                              RemediTheme.spaceMD,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: RemediTheme.spaceMD),

                    // Standardized Banners (PremiumAlertBanner)
                    if (_searchResult?.hasWarning == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceMD),
                        child: PremiumAlertBanner(message: _searchResult!.warningMessage!),
                      ),

                    if (_searchResult?.tier == EvidenceTier.traditional && _searchResult!.remedies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceMD),
                        child: PremiumAlertBanner(
                          message: _searchResult!.remedies.any((r) => r.evidenceLedger.label == EvidenceLabel.webSourced)
                              ? "General Guidance - Web Sourced active."
                              : "Traditional Archive active. Suggestions sourced from AI/Web evidence.",
                          icon: Icons.auto_awesome_outlined,
                        ),
                      ),

                    const SizedBox(height: RemediTheme.spaceSM),

                    // Results, Clarification, or Guidance
                    Expanded(
                      child: _activeFulfillment != null
                          ? FulfillmentStack(data: _activeFulfillment!)
                          : _isAwaitingClarification
                              ? _buildClarificationUI()
                              : _hasSearched
                                  ? _buildSearchResults()
                                  : _buildGuidanceContent(),
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

  Widget _buildGuidanceContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RemediTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Curated Mode Info Card with Glassmorphism
          SanctuaryGlassCard(
            padding: const EdgeInsets.all(RemediTheme.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: RemediTheme.deepTeal.withOpacity(0.6),
                      size: 18,
                    ),
                    const SizedBox(width: RemediTheme.spaceXS + 4),
                    Text(
                      'Curated Mode (Sources + Safety)',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: RemediTheme.deepTeal,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: RemediTheme.spaceMD),
                _buildGuidanceItem('Evidence-tagged guidance'),
                _buildGuidanceItem('Safety-first screening'),
                _buildGuidanceItem('Traditional archive fallback'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Example Searches - Cleaner Alignment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Try These Searches'.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: RemediTheme.charcoal.withOpacity(0.4),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildExampleChip('Common Cold'),
              _buildExampleChip('Headache'),
              _buildExampleChip('Blood Sugar Support'),
              _buildExampleChip('Inflammation'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: RemediTheme.mutedSage),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: RemediTheme.charcoal.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String label) {
    return InkWell(
      onTap: () {
        // Map safety phrasing to internal search terms if needed
        String searchTerm = label;
        if (label == 'Blood Sugar Support') searchTerm = 'Diabetes';
        
        _searchController.text = searchTerm;
        _performSearch(searchTerm);
      },
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: RemediTheme.deepTeal.withOpacity(0.08)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: RemediTheme.deepTeal,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResult == null || _searchResult!.remedies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(RemediTheme.spaceMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: RemediTheme.charcoal.withOpacity(0.3),
              ),
              const SizedBox(height: RemediTheme.spaceMD),
              Text(
                'No Remedies Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: RemediTheme.spaceXS),
              Text(
                'Try different search terms',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RemediTheme.charcoal.withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _searchResult!.remedies.length,
      itemBuilder: (context, index) {
        final remedy = _searchResult!.remedies[index];
        return _buildRemedyCardWithTier(remedy);
      },
    );
  }

  Widget _buildRemedyCardWithTier(Remedy remedy) {
    final isPhysicianVerified = _searchResult?.isPhysicianVerified ?? false;
    
    return Container(
      margin: const EdgeInsets.only(
        left: RemediTheme.spaceMD,
        right: RemediTheme.spaceMD,
        bottom: RemediTheme.spaceMD,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              // Navigate to premium remedy detail screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RemedyDetailScreen(remedy: remedy),
                ),
              );
            },
            borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
            child: RemedyCard(
              title: remedy.name,
              subtitle: remedy.category,
              evidenceLedger: remedy.evidenceLedger,
              description: remedy.description,
              benefits: remedy.symptoms.take(3).toList(),
            ),
          ),
          
          if (_fulfillingRemedyId == remedy.id && _isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: RemediTheme.deepTeal),
                ),
              ),
            ),
          
          // Safety Twin: Conflict Alerts
          if (_userProfile != null && _searchResult?.conflicts?.containsKey(remedy.id) == true)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'SAFETY CONFLICT',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Gold Seal for PhysicianVerified
          if (isPhysicianVerified)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD4A373),
                      Color(0xFFFAEDCD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A373).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      color: RemediTheme.deepTeal,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'PHYSICIAN VERIFIED',
                      style: TextStyle(
                        color: RemediTheme.deepTeal,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClarificationUI() {
    return Padding(
      padding: const EdgeInsets.all(RemediTheme.spaceMD),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SanctuaryGlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFD4A373),
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  'HEALING GUIDE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: const Color(0xFFD4A373),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _clarifyingQuestion ?? "Thinking...",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: RemediButton(
                  label: 'DRY COUGH',
                  onPressed: () => _submitClarification('Dry'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RemediButton(
                  label: 'CONGESTED',
                  onPressed: () => _submitClarification('Congested'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => _performSearch(_searchController.text),
            child: Text(
              'SKIP CLARIFICATION',
              style: TextStyle(
                color: RemediTheme.charcoal.withOpacity(0.4),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFulfillment(Remedy remedy) async {
    setState(() {
      _isLoading = true;
      _fulfillingRemedyId = remedy.id;
    });

    final data = await FulfillmentService.getFulfillmentData(
      remedy.id,
      remedy.name,
      remedy: remedy,
    );

    setState(() {
      _activeFulfillment = data;
      _isLoading = false;
    });
  }
}
