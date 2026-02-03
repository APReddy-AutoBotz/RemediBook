import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/motion/motion_prefs.dart';
import '../../../../core/widgets/sanctuary_glass_card.dart';
import '../../../../core/widgets/sanctuary_toggle_chip.dart';
import '../../../../core/widgets/sanctuary_text_field.dart';
import '../../../../core/widgets/sanctuary_button.dart';
import '../../../../core/widgets/safety_banner.dart';
import '../../../../core/models/user_profile.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

/// SafetyHeritageProfileScreen - Premium Clinic Intake
/// Elite onboarding with custom controls and region-aware verification
class SafetyHeritageProfileScreen extends StatefulWidget {
  const SafetyHeritageProfileScreen({super.key});

  @override
  State<SafetyHeritageProfileScreen> createState() =>
      _SafetyHeritageProfileScreenState();
}

class _SafetyHeritageProfileScreenState
    extends State<SafetyHeritageProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  // Safety flags
  bool _isPregnant = false;
  bool _onBPMeds = false;
  bool _isDiabetic = false;

  // Allergies
  final TextEditingController _allergyController = TextEditingController();
  final List<String> _allergies = [];

  // Heritage preferences (UI-only for now - TODO: add to model)
  final Set<String> _heritagePrefs = {};

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Load existing profile if available
    _loadProfile();

    // Start stagger if motion enabled
    if (MotionPrefs.isMotionEnabled.value) {
      _staggerController.forward();
    } else {
      // Skip animation, set to complete
      _staggerController.value = 1.0;
    }
  }

  Future<void> _loadProfile() async {
    final profile = await SecureProfileStorage.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _isPregnant = profile.isPregnant;
        _onBPMeds = profile.onBPMeds;
        _isDiabetic = profile.isDiabetic;
        _allergies.addAll(profile.allergies);
      });
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _addAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() {
        _allergies.add(text);
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() => _allergies.remove(allergy));
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
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  bool get _showsSafetyBanner =>
      _isPregnant || _onBPMeds || _isDiabetic;

  bool get _showsAllergyBanner => _allergies.isNotEmpty;

  String _getVerificationLabel() {
    // TODO: Implement region detection
    // For now, default to "Verified Guidance"
    return "Verified Guidance";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _StaggeredSection(
                controller: _staggerController,
                delay: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety & Heritage Profile',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'So your guidance stays safe, region-aware, and clinically responsible.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: RemediTheme.charcoal.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Verification Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: RemediTheme.mutedSage.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: RemediTheme.mutedSage.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: RemediTheme.mutedSage,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getVerificationLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: RemediTheme.darkForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section 1: Critical Safety
              _StaggeredSection(
                controller: _staggerController,
                delay: 0.15,
                child: SanctuaryGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Critical Safety',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SanctuaryToggleChip(
                            label: 'Pregnancy',
                            icon: Icons.pregnant_woman_rounded,
                            isSelected: _isPregnant,
                            onTap: () => setState(() => _isPregnant = !_isPregnant),
                          ),
                          SanctuaryToggleChip(
                            label: 'BP Medication',
                            icon: Icons.medication_rounded,
                            isSelected: _onBPMeds,
                            onTap: () => setState(() => _onBPMeds = !_onBPMeds),
                          ),
                          SanctuaryToggleChip(
                            label: 'Diabetes',
                            icon: Icons.bloodtype_rounded,
                            isSelected: _isDiabetic,
                            onTap: () => setState(() => _isDiabetic = !_isDiabetic),
                          ),
                        ],
                      ),
                      
                      // Safety Banner
                      if (_showsSafetyBanner) ...[
                        const SizedBox(height: 16),
                        const SafetyBanner(
                          type: SafetyBannerType.amber,
                          message:
                              'Your profile will apply stricter safety filters and highlight contraindications.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section 2: Allergies
              _StaggeredSection(
                controller: _staggerController,
                delay: 0.3,
                child: SanctuaryGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allergies',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Input field
                      SanctuaryTextField(
                        controller: _allergyController,
                        hint: 'List allergies (e.g., peanuts, dairy)',
                        leadingIcon: Icons.add_circle_outline,
                        onSubmitted: _addAllergy,
                        trailingAction: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: RemediTheme.emberGold,
                            size: 24,
                          ),
                          onPressed: _addAllergy,
                        ),
                      ),
                      
                      // Allergy chips
                      if (_allergies.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allergies
                              .map((allergy) => _AllergyChip(
                                    label: allergy,
                                    onRemove: () => _removeAllergy(allergy),
                                  ))
                              .toList(),
                        ),
                      ],
                      
                      // Allergy Banner
                      if (_showsAllergyBanner) ...[
                        const SizedBox(height: 16),
                        const SafetyBanner(
                          type: SafetyBannerType.info,
                          message:
                              "We'll flag ingredients that may conflict with your allergies.",
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section 3: Heritage Preferences
              _StaggeredSection(
                controller: _staggerController,
                delay: 0.45,
                child: SanctuaryGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heritage Preferences',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Light personalization for remedy recommendations',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: RemediTheme.charcoal.withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SanctuaryToggleChip(
                            label: 'Ayurveda',
                            icon: Icons.self_improvement_rounded,
                            isSelected: _heritagePrefs.contains('ayurveda'),
                            onTap: () {
                              setState(() {
                                if (_heritagePrefs.contains('ayurveda')) {
                                  _heritagePrefs.remove('ayurveda');
                                } else {
                                  _heritagePrefs.add('ayurveda');
                                }
                              });
                            },
                          ),
                          SanctuaryToggleChip(
                            label: 'Home Remedies',
                            icon: Icons.house_rounded,
                            isSelected: _heritagePrefs.contains('home'),
                            onTap: () {
                              setState(() {
                                if (_heritagePrefs.contains('home')) {
                                  _heritagePrefs.remove('home');
                                } else {
                                  _heritagePrefs.add('home');
                                }
                              });
                            },
                          ),
                          SanctuaryToggleChip(
                            label: 'Lifestyle Practices',
                            icon: Icons.spa_rounded,
                            isSelected: _heritagePrefs.contains('lifestyle'),
                            onTap: () {
                              setState(() {
                                if (_heritagePrefs.contains('lifestyle')) {
                                  _heritagePrefs.remove('lifestyle');
                                } else {
                                  _heritagePrefs.add('lifestyle');
                                }
                              });
                            },
                          ),
                          SanctuaryToggleChip(
                            label: 'Science-first only',
                            icon: Icons.science_rounded,
                            isSelected: _heritagePrefs.contains('science'),
                            onTap: () {
                              setState(() {
                                if (_heritagePrefs.contains('science')) {
                                  _heritagePrefs.remove('science');
                                } else {
                                  _heritagePrefs.add('science');
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              _StaggeredSection(
                controller: _staggerController,
                delay: 0.6,
                child: SanctuaryButton(
                  label: 'Continue to Sanctuary',
                  onPressed: _saveAndContinue,
                  isPrimary: true,
                  icon: Icons.arrow_forward_rounded,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// _StaggeredSection - Entrance Animation for Sections
class _StaggeredSection extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _StaggeredSection({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          (delay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          (delay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: slideAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// _AllergyChip - Removable Allergy Tag
class _AllergyChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _AllergyChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RemediTheme.mutedSage.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RemediTheme.mutedSage.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: RemediTheme.darkForest,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: RemediTheme.charcoal.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
