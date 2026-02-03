import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/widgets/remedi_widgets.dart';
import '../../../../core/widgets/living_background.dart'; // Design Bible: Phase 1
import '../../../../core/widgets/sanctuary_glass_card.dart'; // Design Bible: Phase 2
import '../../../../core/widgets/staggered_text.dart'; // Design Bible: Phase 5
import '../../../../core/models/user_profile.dart';

class HeritageOnboardingScreen extends StatefulWidget {
  const HeritageOnboardingScreen({super.key});

  @override
  State<HeritageOnboardingScreen> createState() => _HeritageOnboardingScreenState();
}

class _HeritageOnboardingScreenState extends State<HeritageOnboardingScreen> {
  bool _isPregnant = false;
  bool _onBPMeds = false;
  bool _isDiabetic = false;
  final TextEditingController _allergyController = TextEditingController();
  List<String> _allergies = [];
  String _ancestralHook = "Finding your ancestral roots...";

  @override
  void initState() {
    super.initState();
    _generateAncestralHook();
  }

  Future<void> _generateAncestralHook() async {
    // Gemini 3 Logic: Detect location (Hyderabad) and generate hook
    // Simulation for Global Hackathon Edition
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _ancestralHook = "From the heart of the Deccan, Hyderabad's rich heritage of cooling herbs and Nizami wellness guides your path.";
      });
    }
  }

  Future<void> _saveAndContinue() async {
    final profile = SovereignProfile(
      isPregnant: _isPregnant,
      onBPMeds: _onBPMeds,
      isDiabetic: _isDiabetic,
      allergies: _allergies,
    );
    await SecureProfileStorage.saveProfile(profile);
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text.trim());
        _allergyController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Design Bible: Phase 1 - Living Background applied to Onboarding screen
    return Scaffold(
      body: Stack(
        children: [
          // Breathing background with subtle motif overlay
          const BreathingBackground(
            intensity: 0.8,
            enableGrain: true,
          ),
          
          // Motif overlay for heritage aesthetic
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/background_motif.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceXL),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Heritage Stone Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: RemediDecorations.stone(
                      color: Colors.white.withOpacity(0.8),
                      shadowOpacity: 0.1,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.history_edu_rounded,
                        size: 48,
                        color: RemediTheme.deepTeal,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: RemediTheme.spaceXL),
                  
                  // Cinematic Welcome Text with Staggered Animation
                  StaggeredFadeSlideText(
                    lines: const [
                      'Welcome to RemediBook Sanctuary',
                      'Ancient Ayurvedic wisdom',
                      'Modern safety protocols',
                      'Your sovereign health journey begins',
                    ],
                    style: GoogleFonts.crimsonPro(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: RemediTheme.charcoal,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    staggerDelay: const Duration(milliseconds: 120),
                  ),
                  
                  const SizedBox(height: RemediTheme.spaceMD),
                  Text(
                    _ancestralHook,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: RemediTheme.charcoal.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sovereign Profile Checklist with Glassmorphism
                  SanctuaryGlassCard(
                    padding: const EdgeInsets.all(RemediTheme.spaceLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Safety & Heritage Profile",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: RemediTheme.spaceMD),
                        _buildCheckTile("Are you pregnant?", _isPregnant, (val) => setState(() => _isPregnant = val!)),
                        _buildCheckTile("On BP Medication?", _onBPMeds, (val) => setState(() => _onBPMeds = val!)),
                        _buildCheckTile("Are you diabetic?", _isDiabetic, (val) => setState(() => _isDiabetic = val!)),
                        
                        const SizedBox(height: RemediTheme.spaceMD),
                        
                        // Allergy Input
                        TextField(
                          controller: _allergyController,
                          decoration: InputDecoration(
                            hintText: "List allergies (e.g., Peanuts, Dust)",
                            hintStyle: GoogleFonts.inter(fontSize: 14),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD4A373)),
                              onPressed: _addAllergy,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: RemediTheme.deepTeal.withOpacity(0.3)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFD4A373)),
                            ),
                          ),
                          onSubmitted: (_) => _addAllergy(),
                        ),
                        
                        if (_allergies.isNotEmpty) ...[
                          const SizedBox(height: RemediTheme.spaceSM),
                          Wrap(
                            spacing: 8,
                            children: _allergies.map((a) => RemediChip(
                              label: a,
                              onRemove: () => setState(() => _allergies.remove(a)),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Action Button - Ember Gold
                  RemediButton(
                    label: "ACTIVATE HEALING",
                    onPressed: _saveAndContinue,
                    isFullWidth: true,
                  ),
                  
                  const SizedBox(height: RemediTheme.spaceXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: RemediTheme.charcoal,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFD4A373),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: RemediTheme.charcoal,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: RemediTheme.deepTeal,
            activeTrackColor: RemediTheme.deepTeal.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
