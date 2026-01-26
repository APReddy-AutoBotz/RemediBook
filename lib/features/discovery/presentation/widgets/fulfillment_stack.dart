import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/widgets/remedi_widgets.dart';
import '../../domain/services/fulfillment_logic.dart';
import '../../../../core/models/user_profile.dart';
import '../../../triage/domain/services/triage_service.dart';
import '../../domain/models/remedy.dart';
import '../../domain/models/evidence_ledger.dart';

/// Fulfillment Stack Widget
/// Pillars 3 & 4: UI Stack & Sovereign Fulfillment
class FulfillmentStack extends StatelessWidget {
  final FulfillmentData data;

  const FulfillmentStack({super.key, required this.data});

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
            name: data.remedyName,
            description: '',
            ingredients: data.materials.map((m) => m.name).toList(),
            instructions: data.prepSteps.map((s) => s.instruction).toList(),
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
                  else if (data.safetyWarning)
                    PremiumAlertBanner(message: "Caution: Boiling water. Avoid scalds."),
                  
                  const SizedBox(height: RemediTheme.spaceMD),
                  
                  // CARD 1: THE REMEDY (PREPARE & PROCURE)
                  _buildStoneCard(
                    context: context,
                    title: "Active Healing: ${data.remedyName}",
                    children: [
                      const TrustStripBadges(),
                      const SizedBox(height: 24),
                      
                      _buildSubsectionTitle(context, "Preparation Protocol"),
                      const SizedBox(height: 12),
                      NumberedProtocolList(
                        steps: data.prepSteps.map((s) => s.instruction).toList(),
                        durations: data.prepSteps.map((s) => s.durationSeconds).toList(),
                      ),
                      
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
                              "✅ Available • ⛔ Missing • 🔁 Substitute",
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 8,
                                color: RemediTheme.charcoal.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMaterialsGrid(data.materials),
                      
                      const SizedBox(height: RemediTheme.spaceSM),
                      _buildPriceComparisonTile(context, data.priceComparison, data.materials, isDisabled),
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
                            child: const Icon(Icons.self_improvement, color: RemediTheme.deepTeal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.practice.title,
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
                      ...data.practice.howTo.map((step) => Padding(
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
                      _buildEscalationBlock(data.escalation),
                      const SizedBox(height: 24),
                      RemediButton(
                        label: "Find Care Nearby",
                        icon: Icons.map_outlined,
                        isFullWidth: true,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
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
                  onPressed: isDisabled ? null : () {
                    HapticFeedback.heavyImpact();
                  },
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
    final missingIngredients = materials.where((m) => !m.inStock).map((m) => m.name).join(", ");

    return Container(
      decoration: RemediDecorations.glass(
        borderRadius: 16.0,
        opacity: 0.03,
      ),
      child: Column(
        children: [
          _buildVendorRow(context, "Zepto", price.zeptoTime, price.zeptoPrice, missingIngredients, isDisabled),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Colors.black12),
          _buildVendorRow(context, "Blinkit", price.blinkitTime, price.blinkitPrice, missingIngredients, isDisabled),
        ],
      ),
    );
  }

  Widget _buildVendorRow(BuildContext context, String vendor, String eta, double price, String query, bool isDisabled) {
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
            onTap: isDisabled ? null : () => _launchCommerce(context, vendor, query),
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
