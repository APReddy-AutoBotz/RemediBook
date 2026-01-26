import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/screens/auth_screen.dart';

/// Splash Screen - GIF Implementation
/// Displays the RemediBook splash animation with seamless transition
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use AppDurations constant (7 seconds)
    Timer(AppDurations.splashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppDurations.fadeTransition,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warm Limestone background for seamless transition
      backgroundColor: RemediTheme.warmLimestone,
      body: Stack(
        children: [
          // GIF - Direct display on Limestone background
          Center(
            child: Image.asset(
              AssetPaths.splashGif,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.7,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if GIF fails to load
                return Icon(
                  Icons.spa,
                  size: 100,
                  color: RemediTheme.deepTeal,
                );
              },
            ),
          ),
          
          // Branding Text (Bottom)
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  AppStrings.splashTitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 8,
                    color: RemediTheme.deepTeal.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 1.5,
                    color: RemediTheme.charcoal.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
