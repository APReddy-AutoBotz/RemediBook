import 'package:flutter/material.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/features/dashboard/presentation/widgets/heal_streak_ring.dart';
import 'package:remedibook/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:remedibook/features/dashboard/presentation/widgets/daily_path_timeline.dart';
import 'package:remedibook/features/dashboard/presentation/widgets/quick_action_chip.dart';
import 'package:remedibook/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:remedibook/features/artifact/presentation/screens/artifact_dashboard.dart';
import 'package:remedibook/features/artifact/presentation/screens/artifact_experience_screen.dart';
import 'package:remedibook/features/profile/presentation/screens/family_profile_screen.dart';
import 'package:remedibook/core/models/user_profile.dart';
import 'package:remedibook/features/onboarding/presentation/screens/heritage_onboarding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/services/healing_schedule_service.dart';
import 'package:remedibook/features/artifact/data/repositories/artifact_repository.dart';
import 'package:remedibook/features/artifact/domain/models/artifact_model.dart';
import 'package:remedibook/core/widgets/living_background.dart';
import 'package:remedibook/core/widgets/sanctuary_search_bar.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';
import 'package:remedibook/core/utils/verification_label_resolver.dart';
import '../../../../core/widgets/remedi_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Dynamic Healing Schedule - PILLAR 3
  List<ScheduleSlot> _todaySchedule = [];
  bool _scheduleLoading = true;
  
  // Daily Path completion tracking for Heal Streak
  int _completedPathItems = 0;
  int _totalPathItems = 0;
  double get _healStreakProgress => _totalPathItems > 0 ? _completedPathItems / _totalPathItems : 0.0;
  int get _stepsFollowed => _completedPathItems;
  
  // User profile for region-aware verification
  SovereignProfile? _userProfile;

  // Repository for real metrics
  final ArtifactRepository _artifactRepository = ArtifactRepository();
  ArtifactMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    );

    // Load Real Metrics
    _loadMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final profile = await SecureProfileStorage.getProfile();
        if (profile == null) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HeritageOnboardingScreen()),
            );
          }
        } else {
          setState(() {
            _userProfile = profile;
          });
          await _generateSchedule(profile);
        }
      } catch (e) {
        debugPrint('DASHBOARD: Error checking profile: $e');
        setState(() {
          _scheduleLoading = false;
        });
      }
    });
  }

  Future<void> _loadMetrics() async {
    final metrics = await _artifactRepository.getMetrics();
    if (mounted) {
      setState(() {
        _metrics = metrics;
      });
    }
  }

  /// Generate daily healing schedule based on profile and search history
  Future<void> _generateSchedule(SovereignProfile profile) async {
    try {
      final schedule = await HealingScheduleService.generateDailySchedule(
        profile: profile,
      );
      
      if (mounted) {
        setState(() {
          _todaySchedule = schedule;
          _totalPathItems = schedule.length;
          _scheduleLoading = false;
        });
      }
    } catch (e) {
      debugPrint('DASHBOARD: Error generating schedule: $e');
      setState(() {
        _scheduleLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Design Bible: Phase 1 - Living Background applied to Home screen
    return Scaffold(
      body: Stack(
        children: [
          // Breathing background
          const BreathingBackground(
            intensity: 1.0, // Full intensity for home screen
            enableGrain: true,
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
              
              // Liquid Heal Streak Ring with Wave Animation (Design Bible: Phase 3)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    LiquidHealStreakRing(
                      progress: _healStreakProgress,
                      size: 160,
                      reduceMotion: false, // TODO: Read from MediaQuery.disableAnimations
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '12',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            color: const Color(0xFFD4A373),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "TODAY'S RHYTHM",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 10,
                            color: RemediTheme.deepTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Wellness Pulse Hero (Glass Card under ring)
              Center(
                child: SanctuaryGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Health Impact',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: RemediTheme.charcoal.withOpacity(0.6),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_stepsFollowed * POINTS_PER_ACTIVITY} points',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: RemediTheme.deepTeal,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.trending_up_rounded,
                              color: const Color(0xFFD4A373),
                              size: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: RemediTheme.deepTeal.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 16,
                                color: RemediTheme.deepTeal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getNextHydrationMessage(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: RemediTheme.deepTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // The Daily Path: Dynamic Healing Schedule (PILLAR 3)
              _scheduleLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: RemediTheme.deepTeal,
                        ),
                      ),
                    )
                  : DailyPathTimeline(
                      schedule: _todaySchedule,
                      onCompletionChanged: (completedCount, totalCount) {
                        setState(() {
                          _completedPathItems = completedCount;
                          _totalPathItems = totalCount;
                        });
                      },
                    ),
              
              const SizedBox(height: 48),

              // Premium Search Bar
              SanctuarySearchBar(
                placeholder: 'Describe symptoms or search remedies...',
                readOnly: true,
                onTap: () => _openSearch(context),
              ),
              
              const SizedBox(height: 24),

              // Quick Actions (Wrapped for full visibility)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  QuickActionChip(
                    icon: Icons.search,
                    label: "Find Remedy",
                    onTap: () => _openSearch(context),
                  ),
                  QuickActionChip(
                    icon: Icons.museum_rounded,
                    label: "My Artifacts",
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArtifactDashboard(),
                        ),
                      );
                    },
                  ),
                  QuickActionChip(
                    icon: Icons.family_restroom,
                    label: "Family Circle",
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FamilyProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              Text(
                'Wellness Impact',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Glassmorphic Metrics
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Guides Generated',
                      value: _metrics?.guidesSaved.toString() ?? '0',
                      icon: Icons.auto_stories_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MetricCard(
                      title: 'Practices Done',
                      value: _metrics?.protocolsCompleted.toString() ?? '0',
                      icon: Icons.self_improvement_rounded,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
            ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  // Removed: _buildDailyPath and _buildPathItem methods
  // Now using DailyPathTimeline widget instead

  Widget _buildHeader(BuildContext context) {
    // Time-based greeting
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    
    // Region-aware verification pill
    final verificationLabel = VerificationLabelResolver.getLabel(
      userRegion: _userProfile?.region,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Sanctuary is ready.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RemediTheme.darkForest.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RemediTheme.deepTeal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.spa_rounded, color: RemediTheme.deepTeal, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Verification pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: RemediTheme.deepTeal.withOpacity(0.25),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 14,
                color: RemediTheme.deepTeal,
              ),
              const SizedBox(width: 6),
              Text(
                verificationLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: RemediTheme.deepTeal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DiscoveryScreen(),
      ),
    );
  }

  // Gamification Constant: 12 Points per step.
  // Why 12? It represents the 12 signs of healing in Ayurveda (Dwadasa)
  static const int POINTS_PER_ACTIVITY = 12;

  String _getNextHydrationMessage() {
    if (_todaySchedule.isEmpty) return "Loading schedule...";

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Find next water slot
    ScheduleSlot? nextSlot;
    int minDiff = 9999;

    for (var slot in _todaySchedule) {
      if (slot.category == ActivityCategory.waterDharma) {
        final slotTime = slot.timeOfDay;
        final slotMinutes = slotTime.hour * 60 + slotTime.minute;
        final diff = slotMinutes - currentMinutes;

        // If it's in the future (diff > 0) and closer than previous find
        if (diff > 0 && diff < minDiff) {
          minDiff = diff;
          nextSlot = slot;
        }
        // If we are IN the window (e.g. within 30 mins past)
        if (diff >= -30 && diff <= 0) {
           return "Hydration window active now";
        }
      }
    }

    if (nextSlot != null) {
      final hours = minDiff ~/ 60;
      final mins = minDiff % 60;
      
      if (hours > 0) {
        return "Next hydration in ${hours}h ${mins}m";
      } else {
        return "Hydration window opens in ${mins}m";
      }
    }

    return "Daily hydration goals met";
  }
}
