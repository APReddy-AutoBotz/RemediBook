import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/widgets/remedi_widgets.dart';
import '../../domain/services/fulfillment_logic.dart';
import '../../domain/models/fulfillment_models.dart';
import '../../../../core/services/fulfillment_engine.dart';
import '../../../../core/services/commerce_service.dart';
import '../../../../core/models/user_profile.dart';
import '../../../triage/domain/services/triage_service.dart';
import '../../domain/models/remedy.dart';
import '../../domain/models/evidence_ledger.dart';
import 'package:google_fonts/google_fonts.dart';
import './material_chip_list.dart';

/// Fulfillment Stack Widget
/// Pillars 3 & 4: UI Stack & Sovereign Fulfillment
/// Now with Interactive Pantry Check (The Pantry First Rule)
class FulfillmentStack extends StatefulWidget {
  final FulfillmentData data;

  const FulfillmentStack({super.key, required this.data});

  @override
  State<FulfillmentStack> createState() => _FulfillmentStackState();
}

class _FulfillmentStackState extends State<FulfillmentStack> {
  List<String> _inHouseItems = [];

  void _onInventoryChanged(List<String> inHouseItems) {
    setState(() {
      _inHouseItems = inHouseItems;
    });
  }

  void _launchTimer(BuildContext context, int seconds) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) => _StoneTimerDialog(seconds: seconds),
    );
  }

  Future<void> _launchCommerce(BuildContext context, String provider, String query) async {
    HapticFeedback.mediumImpact();
    final encodedQuery = Uri.encodeComponent(query);
    final url = provider.toLowerCase() == 'zepto'
        ? 'https://www.zeptonow.com/search?query=$encodedQuery'
        : 'https://blinkit.com/s/?q=$encodedQuery';
    
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $provider')),
        );
      }
    }
  }

  void _handleBookConsultation(BuildContext context, EscalationCriteria escalation) {
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

  void _handleGenerateGuide(BuildContext context, FulfillmentData data) {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description_outlined, color: RemediTheme.deepTeal),
            const SizedBox(width: 12),
            const Text('Generate Wellness Guide'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your personalized wellness guide will include:',
              style: TextStyle(
                color: RemediTheme.charcoal.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildGuideFeature('Complete preparation protocol'),
            _buildGuideFeature('Materials & procurement list'),
            _buildGuideFeature('Traditional practice guidance'),
            _buildGuideFeature('Escalation criteria & red flags'),
            _buildGuideFeature('Evidence sources & citations'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, 
                    color: const Color(0xFFF59E0B), 
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Guide ID: RB-PREMIER-${DateTime.now().millisecondsSinceEpoch}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
                  content: Text('Generating wellness guide for ${widget.data.remedyName}...'),
                  backgroundColor: RemediTheme.deepTeal,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RemediTheme.deepTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: RemediTheme.deepTeal,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SovereignProfile?>(
      future: SecureProfileStorage.getProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        String? conflict;
        
        if (profile != null) {
          // Mocking the Remedy object for conflict check as FulfillmentData doesn't have it directly
          final mockRemedy = Remedy(
            id: 'mock',
            name: widget.data.remedyName,
            description: '',
            ingredients: widget.data.materials.map((m) => m.name).toList(),
            instructions: widget.data.prepSteps.map((s) => s.instruction).toList(),
            fibreToCarbRatio: 0.0,
            evidenceLedger: EvidenceLedger(
              remedyId: 'mock',
              label: EvidenceLabel.traditional,
              reviewDate: DateTime.now(),
              sourceCount: 0,
              primarySources: [],
            ),
            symptoms: [],
            category: '',
          );
          conflict = TriageInterceptor.checkProfileConflicts(mockRemedy, profile);
        }

        final bool isDisabled = conflict != null;

        return Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceMD),
                shrinkWrap: false,
                physics: const ClampingScrollPhysics(),
                children: [
                  if (isDisabled)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SafetyTag(message: conflict!),
                    )
                  else if (widget.data.safetyWarning)
                    PremiumAlertBanner(message: "Caution: Boiling water. Avoid scalds."),
                  
                  const SizedBox(height: RemediTheme.spaceMD),
                  
                  // CARD 1: THE REMEDY (PREPARE & PROCURE)
                  _buildStoneCard(
                    context: context,
                    title: "Active Healing: ${widget.data.remedyName}",
                    children: [
                      const TrustStripBadges(),
                      const SizedBox(height: 24),
                      
                      if (widget.data.vernacularName != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A373).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.data.vernacularName!.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD4A373),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.data.vernacularWisdom ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: RemediTheme.charcoal.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      _buildSubsectionTitle(context, "Preparation Protocol"),
                      const SizedBox(height: 12),
                      NumberedProtocolList(
                        steps: widget.data.prepSteps.map((s) => s.instruction).toList(),
                        durations: widget.data.prepSteps.map((s) => s.durationSeconds).toList(),
                      ),
                      
                      // NULL INVENTORY GATE: Only show materials if remedy requires physical items
                      if (widget.data.hasPhysicalMaterials) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: RemediTheme.spaceSM),
                          child: Divider(height: 1, color: Colors.black12),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSubsectionTitle(context, "Materials & Procurement"),
                            Flexible(
                              child: Text(
                                "🟢 In House • 🔴 Needed",
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 8,
                                  color: RemediTheme.charcoal.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tap items you already have at home",
                          style: TextStyle(
                            fontSize: 11,
                            color: RemediTheme.charcoal.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MaterialChipList(
                          materials: widget.data.materials,
                          onInventoryChanged: _onInventoryChanged,
                        ),
                        
                        const SizedBox(height: RemediTheme.spaceSM),
                        _buildPriceComparisonTile(context, widget.data.priceComparison, widget.data.materials, isDisabled),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: RemediTheme.spaceMD),
                  
                  // CARD 2: THE PRACTICE (BREATHING PRACTICE)
                  _buildStoneCard(
                    context: context,
                    title: "Breathing Practice",
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: RemediTheme.deepTeal.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(widget.data.practice.icon, color: RemediTheme.deepTeal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data.practice.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: RemediTheme.darkForest,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Traditional technique (guided)",
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: RemediTheme.charcoal.withOpacity(0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...widget.data.practice.howTo.map((step) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ", style: TextStyle(color: RemediTheme.deepTeal, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(step, style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 16),
                      RemediButton(
                        label: "Start Guided 5-min Audio",
                        icon: Icons.play_circle_outline,
                        isPrimary: false,
                        isFullWidth: true,
                        onPressed: isDisabled ? null : () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: RemediTheme.spaceMD),
                  
                  // CARD 3: THE CONNECT (PHYSICIAN ESCALATION)
                  _buildStoneCard(
                    context: context,
                    title: "When to seek care",
                    children: [
                      _buildEscalationBlock(widget.data.escalation),
                      const SizedBox(height: 24),
                      if (widget.data.escalation.isBookingAvailable) ...[
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
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: RemediTheme.deepTeal,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Instant slots available at ${widget.data.escalation.clinicName ?? 'Partner Hospital'}.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: RemediTheme.charcoal.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      RemediButton(
                        label: widget.data.escalation.isBookingAvailable ? "Book Urgent Consultation" : "Find Care Nearby",
                        icon: widget.data.escalation.isBookingAvailable ? Icons.calendar_today_rounded : Icons.map_outlined,
                        isFullWidth: true,
                        onPressed: () => _handleBookConsultation(context, widget.data.escalation),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // Spacing for sticky button
                ],
              ),
            ),
            
            // Premium Glass Action Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: Border(
                    top: BorderSide(
                      color: RemediTheme.deepTeal.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                child: RemediButton(
                  label: "Generate Wellness Guide",
                  isFullWidth: true,
                  onPressed: isDisabled ? null : () => _handleGenerateGuide(context, widget.data),
                ),
              ),
            ),
          ),
        ),
          ],
        );
      }
    );
  }

  Widget _buildStoneCard({
    required BuildContext context,
    required String title,
    bool isPhysicianVerified = false,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(RemediTheme.spaceMD),
      decoration: RemediDecorations.stone(
        borderRadius: RemediTheme.radiusStone,
        shadowOpacity: 0.05, // Subtle shadow for depth
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: RemediTheme.charcoal.withOpacity(0.7),
                  ),
                ),
              ),
              if (isPhysicianVerified)
                const Icon(Icons.verified, color: Colors.amber, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSafetyBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 10,
        letterSpacing: 1.0,
        fontWeight: FontWeight.bold,
        color: RemediTheme.charcoal.withOpacity(0.4),
      ),
    );
  }

  Widget _buildEscalationBlock(EscalationCriteria escalation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...escalation.redFlags.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Text(b, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        )),
        const SizedBox(height: 12),
        Text(
          escalation.guidance,
          style: TextStyle(
            color: RemediTheme.charcoal.withOpacity(0.6),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPrepStep(BuildContext context, PrepStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "• ${step.instruction}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (step.durationSeconds != null)
            TextButton.icon(
              onPressed: () => _launchTimer(context, step.durationSeconds!),
              icon: const Icon(Icons.timer_outlined, size: 14),
              label: Text("${step.durationSeconds! ~/ 60}m", style: const TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: RemediTheme.deepTeal,
                backgroundColor: RemediTheme.deepTeal.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialsGrid(List<IngredientStatus> materials) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: materials.map<Widget>((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: item.inStock
            ? const Color(0xFFF0FDF4) // Soft green
            : const Color(0xFFFEF2F2), // Soft red
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (item.inStock ? Colors.green : Colors.red).withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.inStock ? Icons.check_circle_outline : Icons.remove_circle_outline,
              size: 12,
              color: item.inStock ? Colors.green.shade700 : Colors.red.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: item.inStock ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPriceComparisonTile(BuildContext context, CommerceComparison price, List<IngredientStatus> materials, bool isDisabled) {
    // PANTRY FIRST RULE: Calculate needed items and pricing
    final neededItems = CommerceService.getNeededItems(
      allMaterials: materials,
      inHouseItems: _inHouseItems,
    );
    
    final hasAllItems = CommerceService.hasAllItemsInHouse(
      allMaterials: materials,
      inHouseItems: _inHouseItems,
    );
    
    // Dynamic pricing based on needed items only
    final zeptoNeededPrice = CommerceService.calculateNeededPrice(
      allMaterials: materials,
      inHouseItems: _inHouseItems,
      basePrice: price.zeptoPrice,
    );
    
    final blinkitNeededPrice = CommerceService.calculateNeededPrice(
      allMaterials: materials,
      inHouseItems: _inHouseItems,
      basePrice: price.blinkitPrice,
    );

    // EMPTY STATE: All items in house
    if (hasAllItems) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You have everything!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Start Preparation →",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: RemediDecorations.glass(
        borderRadius: 16.0,
        opacity: 0.03,
      ),
      child: Column(
        children: [
          _buildVendorRow(context, "Zepto", price.zeptoTime, zeptoNeededPrice, neededItems, isDisabled),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Colors.black12),
          _buildVendorRow(context, "Blinkit", price.blinkitTime, blinkitNeededPrice, neededItems, isDisabled),
        ],
      ),
    );
  }

  Widget _buildVendorRow(BuildContext context, String vendor, String eta, double price, List<IngredientStatus> neededItems, bool isDisabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(vendor, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          Text(eta, style: TextStyle(color: RemediTheme.charcoal.withOpacity(0.5), fontSize: 11)),
          const SizedBox(width: 16),
          Text("₹${price.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 16),
          InkWell(
            onTap: isDisabled ? null : () async {
              final success = await CommerceService.launchCommerceApp(
                provider: vendor,
                neededItems: neededItems,
              );
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch $vendor')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey : RemediTheme.deepTeal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text("Order", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRowButton extends StatelessWidget {
  final String provider;
  final String price;
  final String time;
  final bool isCheapest;
  final VoidCallback onPressed;

  const _PriceRowButton({
    required this.provider,
    required this.price,
    required this.time,
    required this.isCheapest,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Text(provider, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(time, style: TextStyle(color: RemediTheme.charcoal.withOpacity(0.5), fontSize: 12)),
            const SizedBox(width: 12),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCheapest ? Colors.green.shade700 : null,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RemediTheme.deepTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Order", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoneTimerDialog extends StatefulWidget {
  final int seconds;
  const _StoneTimerDialog({required this.seconds});

  @override
  State<_StoneTimerDialog> createState() => _StoneTimerDialogState();
}

class _StoneTimerDialogState extends State<_StoneTimerDialog> {
  late int _remaining;
  bool _isRunning = false;
  
  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
  }

  void _toggleTimer() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _tick();
    }
  }

  void _tick() {
    if (!_isRunning || _remaining <= 0) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining == 0) {
          _isRunning = false;
          HapticFeedback.heavyImpact();
        }
      });
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining ~/ 60;
    final seconds = _remaining % 60;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 240,
        decoration: RemediDecorations.stone(
          borderRadius: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: RemediTheme.deepTeal,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  style: IconButton.styleFrom(
                    backgroundColor: RemediTheme.deepTeal.withOpacity(0.1),
                    foregroundColor: RemediTheme.deepTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
