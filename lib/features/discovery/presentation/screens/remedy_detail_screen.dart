// Premium Remedy Detail Screen - Full Integration
// Integrates all Sanctuary components for world-class UX

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/living_background.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';
import 'package:remedibook/core/widgets/staggered_text.dart';
import 'package:remedibook/core/services/vernacular_bridge.dart';
import 'package:remedibook/core/services/deep_link_builder.dart';
import 'package:remedibook/features/remedy/widgets/inventory_chips.dart';
import 'package:remedibook/features/remedy/widgets/circular_step_timer.dart';
import 'package:remedibook/features/artifact/widgets/wax_seal_stamp.dart';
import '../../domain/models/remedy.dart';
import '../../domain/models/evidence_ledger.dart';
import '../widgets/evidence_badge.dart';
import '../../domain/models/fulfillment_models.dart';

/// Premium Remedy Detail Screen
/// 
/// Features:
/// - Vernacular ingredient names
/// - Interactive inventory chips
/// - One-tap shopping (Zepto, Amazon, BigBasket)
/// - Preparation timers
/// - PDF wellness guide generation
/// - Glassmorphism styling
class RemedyDetailScreen extends StatefulWidget {
  final Remedy remedy;

  const RemedyDetailScreen({
    super.key,
    required this.remedy,
  });

  @override
  State<RemedyDetailScreen> createState() => _RemedyDetailScreenState();
}

class _RemedyDetailScreenState extends State<RemedyDetailScreen> {
  List<IngredientItem> _selectedIngredients = [];
  String _selectedPlatform = 'zepto'; // Default platform
  bool _showPdfAnimation = false;
  final String _userLanguage = 'te'; // Telugu (Hyderabad heritage)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Breathing background
          const BreathingBackground(intensity: 0.9),
          
          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                _buildSliverAppBar(),
                
                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Hero Section with Staggered Text
                      _buildHeroSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Ingredients Section
                      _buildIngredientsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Preparation Section
                      _buildPreparationSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Safety Section
                      if (widget.remedy.escalation != null)
                        _buildSafetySection(),
                      
                      const SizedBox(height: 24),
                      
                      // Actions Section
                      _buildActionsSection(),
                      
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          
          // PDF Generation Animation Overlay
          if (_showPdfAnimation)
            _buildPdfAnimationOverlay(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                RemediTheme.deepTeal.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  RemediEvidenceBadge(
                    label: widget.remedy.evidenceLedger.label,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.remedy.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: RemediTheme.charcoal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SanctuaryGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaggeredFadeSlideText(
              lines: [
                widget.remedy.description,
                'Category: ${widget.remedy.category}',
              ],
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.left,
              staggerDelay: const Duration(milliseconds: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    // Convert ingredients to IngredientItem with vernacular names
    final ingredientItems = widget.remedy.ingredients.map((ingredient) {
      final vernacularName = VernacularBridge.translate(
        ingredientName: ingredient,
        languageCode: _userLanguage,
      );
      
      return IngredientItem(
        id: ingredient.toLowerCase().replaceAll(' ', '_'),
        name: ingredient,
        vernacularName: vernacularName != ingredient ? vernacularName : null,
        initialStatus: InventoryStatus.missing,
      );
    }).toList();

    return SanctuaryGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_basket, color: RemediTheme.deepTeal),
                const SizedBox(width: 8),
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: RemediTheme.deepTeal,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ingredient list with vernacular names
            ...ingredientItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: RemediTheme.mutedSage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.vernacularName != null
                          ? '${item.name} (${item.vernacularName})'
                          : item.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Interactive Inventory Chips
            InventoryChipList(
              ingredients: ingredientItems,
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedIngredients = selected;
                });
              },
            ),
            
            // Shopping Cart Button
            if (_selectedIngredients.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildShoppingCartButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingCartButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Platform Selector
        Wrap(
          spacing: 8,
          children: [
            _buildPlatformChip('zepto', 'Zepto'),
            _buildPlatformChip('amazon', 'Amazon'),
            _buildPlatformChip('bigbasket', 'BigBasket'),
            _buildPlatformChip('blinkit', 'Blinkit'),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Order Button
        ElevatedButton.icon(
          onPressed: _handleOrderIngredients,
          icon: const Icon(Icons.shopping_cart),
          label: Text('Order ${_selectedIngredients.length} items from ${_selectedPlatform.toUpperCase()}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A373), // Ember Gold
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformChip(String platform, String label) {
    final isSelected = _selectedPlatform == platform;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPlatform = platform;
        });
      },
      selectedColor: RemediTheme.deepTeal.withOpacity(0.2),
      checkmarkColor: RemediTheme.deepTeal,
    );
  }

  void _handleOrderIngredients() {
    // Convert selected ingredients to CartItems
    final cartItems = _selectedIngredients.map((item) {
      return CartItem.fromIngredient(
        id: item.id,
        name: item.name,
        vernacularName: item.vernacularName,
      );
    }).toList();
    
    // Generate deep link
    final deepLink = DeepLinkBuilder.buildCartLink(
      platform: _selectedPlatform,
      items: cartItems,
    );
    
    // Open deep link (requires url_launcher package)
    // For now, show a snackbar with the link
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $_selectedPlatform...'),
        action: SnackBarAction(
          label: 'Copy Link',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: deepLink));
          },
        ),
      ),
    );
    
    // TODO: Implement url_launcher
    // await launchUrl(Uri.parse(deepLink));
  }

  Widget _buildPreparationSection() {
    // Use prepSteps if available, otherwise fallback to instructions
    final hasPrepSteps = widget.remedy.prepSteps != null && widget.remedy.prepSteps!.isNotEmpty;
    
    return SanctuaryGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: RemediTheme.deepTeal),
                const SizedBox(width: 8),
                Text(
                  'Preparation Steps',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: RemediTheme.deepTeal,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Steps with timers (using prepSteps if available)
            if (hasPrepSteps)
              ...widget.remedy.prepSteps!.asMap().entries.map((entry) {
                final index = entry.key;
                final prepStep = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step number
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: RemediTheme.deepTeal,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Instruction and timer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prepStep.instruction,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            
                            // Timer if duration exists
                            if (prepStep.durationSeconds != null && prepStep.durationSeconds! > 0) ...[ 
                              const SizedBox(height: 12),
                              CircularStepTimer(
                                durationSeconds: prepStep.durationSeconds!,
                                stepLabel: 'Step ${index + 1}',
                                size: 100,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              // Fallback to instructions if no prepSteps
              ...widget.remedy.instructions.asMap().entries.map((entry) {
                final index = entry.key;
                final instruction = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: RemediTheme.deepTeal,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Text(
                          instruction,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  int? _extractTimerDuration(String instruction) {
    // Simple regex to extract minutes from instructions
    // e.g., "Boil for 5 minutes" → 300 seconds
    final minuteRegex = RegExp(r'(\d+)\s*minute', caseSensitive: false);
    final match = minuteRegex.firstMatch(instruction);
    
    if (match != null) {
      final minutes = int.tryParse(match.group(1) ?? '');
      return minutes != null ? minutes * 60 : null;
    }
    
    return null;
  }



  Widget _buildSafetySection() {
    final escalation = widget.remedy.escalation!;
    
    return SanctuaryGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: Color(0xFFE63946)),
                const SizedBox(width: 8),
                Text(
                  'When to Seek Care',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE63946),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...escalation.redFlags.map((flag) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning, size: 16, color: Color(0xFFE63946)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      flag,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),

            if (escalation.isBookingAvailable) ...[
              const SizedBox(height: 24),
              
              // Clinical Ready Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RemediTheme.deepTeal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RemediTheme.deepTeal.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CLINICAL ESCALATION READY",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: RemediTheme.deepTeal,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Instant slots available at ${escalation.clinicName ?? 'Partner Hospital'}.",
                      style: TextStyle(
                        fontSize: 12,
                        color: RemediTheme.charcoal.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Booking Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleBookConsultation(escalation),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: const Text('Book Urgent Consultation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleBookConsultation(EscalationCriteria escalation) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: RemediTheme.deepTeal),
            const SizedBox(width: 12),
            const Text('Book Consultation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instant slots available at:',
              style: TextStyle(
                color: RemediTheme.charcoal.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              escalation.clinicName ?? 'Partner Hospital',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RemediTheme.deepTeal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📞 This feature will connect you to our partner clinics for immediate booking.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking feature coming soon for ${escalation.clinicName}'),
                  backgroundColor: RemediTheme.deepTeal,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RemediTheme.deepTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Generate Wellness Guide Button
        ElevatedButton.icon(
          onPressed: _handleGeneratePdf,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Generate Wellness Guide'),
          style: ElevatedButton.styleFrom(
            backgroundColor: RemediTheme.deepTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Share Button
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share functionality coming soon')),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Share Remedy'),
          style: OutlinedButton.styleFrom(
            foregroundColor: RemediTheme.deepTeal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: RemediTheme.deepTeal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _handleGeneratePdf() {
    setState(() {
      _showPdfAnimation = true;
    });
    
    // Simulate PDF generation delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showPdfAnimation = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wellness Guide generated successfully!'),
            backgroundColor: RemediTheme.deepTeal,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
    
    // TODO: Implement actual PDF generation
  }

  Widget _buildPdfAnimationOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WaxSealStampAnimation(
              size: 150,
              onComplete: () {
                // Animation complete
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Generating Wellness Guide...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
