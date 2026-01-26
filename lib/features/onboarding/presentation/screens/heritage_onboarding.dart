import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/widgets/remedi_widgets.dart';
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

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text.trim());
        _allergyController.clear();
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
      // Navigate to Discovery or Dashboard
      Navigator.of(context).pushReplacementNamed('/discovery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: RemediTheme.warmLimestone,
          image: DecorationImage(
            image: const AssetImage('assets/images/background_motif.png'),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RemediTheme.spaceXL),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
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
                      Icons.terrain_rounded,
                      size: 48,
                      color: RemediTheme.deepTeal,
                    ),
                  ),
                ),
                
                const SizedBox(height: RemediTheme.spaceXL),
                
                // Emotional Copy
                Text(
                  "Welcome to RemediBook",
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: RemediTheme.spaceMD),
                Text(
                  "We are grounding your healing in the roots of your heritage.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: RemediTheme.charcoal.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(flex: 1),
                
                // Profile Questions
                RemediCard(
                  padding: const EdgeInsets.all(RemediTheme.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sovereign Profile",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: RemediTheme.spaceMD),
                      _buildSwitchTile("Are you pregnant?", _isPregnant, (val) => setState(() => _isPregnant = val)),
                      _buildSwitchTile("On BP Medication?", _onBPMeds, (val) => setState(() => _onBPMeds = val)),
                      _buildSwitchTile("Are you diabetic?", _isDiabetic, (val) => setState(() => _isDiabetic = val)),
                      
                      const SizedBox(height: RemediTheme.spaceMD),
                      
                      // Allergy Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _allergyController,
                              decoration: InputDecoration(
                                hintText: "Add allergies...",
                                hintStyle: GoogleFonts.inter(fontSize: 14),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: RemediTheme.deepTeal.withOpacity(0.3)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: RemediTheme.deepTeal),
                                ),
                              ),
                              onSubmitted: (_) => _addAllergy(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: RemediTheme.deepTeal),
                            onPressed: _addAllergy,
                          ),
                        ],
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
                
                const Spacer(flex: 2),
                
                // Action Button
                RemediButton(
                  label: "Continue to Healing",
                  onPressed: _saveAndContinue,
                  isFullWidth: true,
                ),
                
                const SizedBox(height: RemediTheme.spaceXL),
              ],
            ),
          ),
        ),
      ),
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
