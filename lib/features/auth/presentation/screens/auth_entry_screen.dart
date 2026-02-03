import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/widgets/sanctuary_bottom_sheet.dart';
import '../../../../core/widgets/sanctuary_button.dart';
import '../../../onboarding/presentation/screens/safety_heritage_profile_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

/// AuthEntryScreen - Glassmorphic Auth Entry
/// Full sanctuary background with frosted bottom sheet
class AuthEntryScreen extends StatefulWidget {
  const AuthEntryScreen({super.key});

  @override
  State<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends State<AuthEntryScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  
  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google Sign In
    _navigateToDashboard();
  }

  void _handleGuestMode() {
    _navigateToProfile();
  }

  void _navigateToDashboard() {
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

  void _navigateToProfile() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const SafetyHeritageProfileScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Bottom Sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: SanctuaryBottomSheet(
            height: MediaQuery.of(context).size.height * 0.5,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Staggered Text
                    _StaggeredText(
                      controller: _staggerController,
                      delay: 0.0,
                      child: Text(
                        'Enter the Sanctuary',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: RemediTheme.darkForest,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _StaggeredText(
                      controller: _staggerController,
                      delay: 0.15,
                      child: Text(
                        'Experience the Wisdom Engine without friction.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: RemediTheme.charcoal.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Primary Button
                    _StaggeredText(
                      controller: _staggerController,
                      delay: 0.3,
                      child: SanctuaryButton(
                        label: 'Continue with Google',
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: _handleGoogleSignIn,
                        isPrimary: true,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Secondary Button
                    _StaggeredText(
                      controller: _staggerController,
                      delay: 0.45,
                      child: SanctuaryButton(
                        label: 'Guest Exploration',
                        icon: Icons.explore_outlined,
                        onPressed: _handleGuestMode,
                        isPrimary: false,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Footer
                    _StaggeredText(
                      controller: _staggerController,
                      delay: 0.6,
                      child: Text(
                        'By continuing, you agree to our Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RemediTheme.charcoal.withOpacity(0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      );
  }
}

/// _StaggeredText - Line-by-line fade + slide
class _StaggeredText extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _StaggeredText({
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
