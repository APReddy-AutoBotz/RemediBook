import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/remedi_theme.dart';
import 'core/services/gemini_wellness_advisor.dart';
import 'core/services/ai_search_service.dart';
import 'core/motion/motion_prefs.dart';
import 'core/widgets/sanctuary_background.dart';
import 'core/widgets/debug_motion_overlay.dart';
import 'features/entry/presentation/screens/cinematic_splash_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/onboarding/presentation/screens/heritage_onboarding.dart';
import 'features/discovery/presentation/screens/discovery_screen.dart';

import 'core/services/gemini_remedy_generator.dart';

void main() {
  // Initialize Gemini services with API key
  const apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', // API Key must be supplied via --dart-define
  );
  
  // Initialize all Gemini services
  GeminiWellnessAdvisor.initialize(apiKey);
  GeminiRemedyGenerator.initialize(apiKey);
  AiSearchService.initialize(apiKey);
  
  // Initialize Motion Prefs
  MotionPrefs.init(); 

  runApp(
    const ProviderScope(
      child: RemediBookApp(),
    ),
  );
}

class RemediBookApp extends StatelessWidget {
  const RemediBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RemediBook',
      debugShowCheckedModeBanner: false,
      theme: RemediTheme.lightTheme,
      // Wrap entire app in Living Background + Debug Overlay
      builder: (context, child) {
        return FocusTraversalGroup( // Correct widget name
          policy: WidgetOrderTraversalPolicy(), // Web-safe traversal (avoids layout geometry crashes)
          child: DebugMotionOverlay(
            child: SanctuaryBackground(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const CinematicSplashScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/onboarding': (context) => const HeritageOnboardingScreen(),
        '/discovery': (context) => const DiscoveryScreen(query: 'cough'), // Default fallback
      },
    );
  }
}
