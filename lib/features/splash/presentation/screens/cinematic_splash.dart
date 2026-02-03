import 'package:flutter/material.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/living_background.dart'; // Design Bible: Phase 1
import 'package:remedibook/features/auth/presentation/screens/auth_screen.dart';

class CinematicSplashScreen extends StatefulWidget {
  const CinematicSplashScreen({super.key});

  @override
  State<CinematicSplashScreen> createState() => _CinematicSplashScreenState();
}

class _CinematicSplashScreenState extends State<CinematicSplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // 4 seconds for full rotation
    );
    
    // Rotation animation - full 360 degrees (2 * pi radians)
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0, // Full rotation (will be multiplied by 2*pi in the widget)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));
    
    _controller.forward();

    // Navigate after 4 seconds
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _navigateToOnboarding();
      }
    });
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Design Bible: Phase 1 - Living Background applied to Entry screen
    return Scaffold(
      body: Stack(
        children: [
          // Breathing background (replaces solid dark background)
          const BreathingBackground(
            intensity: 0.6, // Subtle for splash screen
            enableGrain: true,
          ),
          
          // Logo animation
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159, // Full 360° rotation
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      width: MediaQuery.of(context).size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
