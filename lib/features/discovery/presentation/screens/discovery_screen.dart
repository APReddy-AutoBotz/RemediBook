import 'package:flutter/material.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/features/discovery/presentation/widgets/triad_card.dart';
import 'package:remedibook/features/discovery/presentation/widgets/refiner_chips.dart';
import 'package:remedibook/features/discovery/domain/safety_interceptor.dart';
import 'package:remedibook/core/utils/millet_rotator.dart';
import 'package:remedibook/core/utils/water_protocol.dart';
import 'package:remedibook/services/pdf_service.dart';
import 'package:remedibook/features/triage/domain/services/triage_service.dart';
import 'package:remedibook/core/models/user_profile.dart';
import 'package:remedibook/features/onboarding/presentation/screens/heritage_onboarding.dart';
import 'package:remedibook/core/widgets/remedi_widgets.dart';
import '../../domain/models/remedy.dart';
import '../../domain/models/evidence_ledger.dart';

class DiscoveryScreen extends StatefulWidget {
  final String query;
  const DiscoveryScreen({super.key, required this.query});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  SovereignProfile? _profile;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    
    // Phase 4: Safety Triage Logic & Profile Check
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('DISCOVERY: Checking Sovereign Profile...');
      // 1. Check Profile existence
      final profile = await SecureProfileStorage.getProfile();
      debugPrint('DISCOVERY: Profile found: ${profile != null}');
      
      if (profile == null) {
        debugPrint('DISCOVERY: No profile found, redirecting to Onboarding...');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HeritageOnboardingScreen()),
          );
        }
        return;
      }
      
      if (mounted) setState(() => _profile = profile);

      // 2. Check Emergency Triage
      if (SafetyInterceptor.isEmergency(widget.query)) {
        debugPrint('DISCOVERY: Emergency detected, triggering red alert.');
        SafetyInterceptor.triggerRedAlert(context);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryCards = _buildDiscoveryCards();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: RemediTheme.warmLimestone)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: RemediTheme.deepTeal),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Discovery',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Insights for "${widget.query}"',
                    style: TextStyle(
                      color: RemediTheme.darkForest.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                RefinerChips(onSelected: (refiner) {}),
                const SizedBox(height: 24),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: discoveryCards,
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(discoveryCards.length, (index) => _buildIndicator(index == _currentPage)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiscoveryCards() {
    final gingerRemedy = Remedy(
      id: 'ginger_001',
      name: 'Ginger-Tulsi Tea',
      description: 'A soothing traditional infusion.',
      ingredients: ['Fresh Ginger', 'Tulsi Leaves', 'Raw Honey'],
      instructions: ['Boil water', 'Add herbs', 'Simmer'],
      fibreToCarbRatio: 0.0,
      evidenceLedger: EvidenceLedger(
        remedyId: 'ginger_001',
        label: EvidenceLabel.evidenceSupported,
        reviewDate: DateTime.now(),
        sourceCount: 12,
        primarySources: [],
      ),
      symptoms: ['cough', 'cold'],
      category: 'Respiratory',
    );

    String? conflict;
    if (_profile != null) {
      conflict = TriageInterceptor.checkProfileConflicts(gingerRemedy, _profile!);
    }

    return [
      TriadCard(
        title: 'Ginger-Tulsi Tea',
        subtitle: 'The Remedy',
        icon: Icons.local_cafe_rounded,
        imagePath: 'assets/images/ginger_tulsi_macro.png',
        content: 'A soothing traditional infusion known to clear respiratory pathways and boost cellular resilience.',
        safetyTag: conflict != null ? SafetyTag(message: conflict) : null,
      ),
      TriadCard(
        title: 'Millet Artifact',
        subtitle: 'Rotation',
        icon: Icons.grass_rounded,
        content: MilletRotator.getInstruction(),
      ),
      TriadCard(
        title: 'Water Dharma',
        subtitle: 'Protocol',
        icon: Icons.water_drop_rounded,
        content: MNLSWaterProtocol.getDailySchedule().join('\n'),
      ),
      _buildArtifactCard(context, conflict),
    ];
  }

  Widget _buildArtifactCard(BuildContext context, String? conflict) {
    return TriadCard(
      title: 'Digital Artifact',
      subtitle: 'Export',
      icon: Icons.picture_as_pdf_rounded,
      content: 'Generate a verified Wellness Guide with a digital wax seal to keep in your sanctuary.',
      onAction: conflict != null ? null : () => PdfService().generateWellnessGuide(
        'Ginger-Tulsi Remedy', 
        '1. Boil 2 cups of water.\n2. Add crushed ginger and 5 tulsi leaves.\n3. Simmer for 5 minutes.\n4. Strain and sip slowly.'
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: RemediTheme.deepTeal.withOpacity(isActive ? 1.0 : 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
