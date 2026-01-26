import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../domain/services/search_service.dart';
import '../../domain/models/remedy.dart';
import '../widgets/remedy_card.dart';
import '../../../../core/widgets/remedi_widgets.dart';
import '../../domain/services/fulfillment_logic.dart';
import '../widgets/fulfillment_stack.dart';

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
    });

    // Vault-First Search Logic
    final result = await SearchService.search(query);

    setState(() {
      _searchResult = result;
      _hasSearched = true;
      _isLoading = false;
      _activeFulfillment = null;
      _fulfillingRemedyId = null;
    });
  }

  Future<void> _showFulfillment(Remedy remedy) async {
    setState(() {
      _isLoading = true;
      _fulfillingRemedyId = remedy.id;
    });

    final data = await FulfillmentService.getFulfillmentData(remedy.id, remedy.name);

    setState(() {
      _activeFulfillment = data;
      _isLoading = false;
    });
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
                          message: "Traditional Archive active. Suggestions sourced from AI/Web evidence.",
                          icon: Icons.auto_awesome_outlined,
                        ),
                      ),

                    const SizedBox(height: RemediTheme.spaceSM),

                    // Results or Guidance
                    Expanded(
                      child: _activeFulfillment != null
                          ? FulfillmentStack(data: _activeFulfillment!)
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
          // Curated Mode Info Card
          Container(
            padding: const EdgeInsets.all(RemediTheme.spaceMD),
            decoration: RemediDecorations.glass(
              borderRadius: RemediTheme.radiusGlass,
            ),
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
            onTap: () => _showFulfillment(remedy),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade600,
                      Colors.amber.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Physician Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
}
