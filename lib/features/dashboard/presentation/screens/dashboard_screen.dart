import 'package:flutter/material.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/features/dashboard/presentation/widgets/heal_streak_ring.dart';
import 'package:remedibook/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:remedibook/features/discovery/presentation/screens/inquiry_overlay.dart';
import 'package:remedibook/core/models/user_profile.dart';
import 'package:remedibook/features/onboarding/presentation/screens/heritage_onboarding.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward(); // 1.2s sweep on load
    
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    );

    // Enforce Sovereign Profile Onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('DASHBOARD: Checking Sovereign Profile...');
      try {
        final profile = await SecureProfileStorage.getProfile();
        debugPrint('DASHBOARD: Profile found: ${profile != null}');
        
        if (profile == null) {
          debugPrint('DASHBOARD: No profile found, redirecting to Onboarding...');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HeritageOnboardingScreen()),
            );
          }
        } else {
          debugPrint('DASHBOARD: Profile exists, staying on Dashboard.');
        }
      } catch (e) {
        debugPrint('DASHBOARD: Error checking profile: $e');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediTheme.warmLimestone,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 80), // Increased spacing to prevent overlap
              
              // Heal Streak Ring with Subtle Sweep Animation
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(180, 180), // Reduced size
                      painter: HealStreakPainter(
                        progress: 0.75,
                        pulse: 1.0, // Static pulse, animation handles the sweep
                        sweepAlpha: _pulseAnimation.value,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '12',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
                            ),
                            const Text(
                              'DAY STREAK',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 9,
                                color: RemediTheme.deepTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
              
              const SizedBox(height: 60),

              // Primary Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openSearch(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text('Start Symptom Check'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Continue Last Guide',
                    style: TextStyle(
                      color: RemediTheme.deepTeal.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 80), // Consistent spacing
              Text(
                'Wellness Impact',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Glassmorphic Metrics
              const Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Guides Generated',
                      value: '18',
                      icon: Icons.menu_book_rounded,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MetricCard(
                      title: 'Actions Completed',
                      value: '142',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Premium Search Box with Blur-Fade Overlay Transition
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false, // Transparent background
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const InquiryOverlay();
                      },
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: RemediTheme.deepTeal.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: RemediTheme.deepTeal),
                      const SizedBox(width: 12),
                      Text(
                        'Search remedies...',
                        style: TextStyle(
                          color: RemediTheme.darkForest.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wellness Pulse',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Your healing journey continues',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: RemediTheme.darkForest.withOpacity(0.4), // Muted copy
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
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const InquiryOverlay();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
