import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/remedi_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/onboarding/presentation/screens/heritage_onboarding.dart';
import 'features/discovery/presentation/screens/discovery_screen.dart';

void main() {
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
      home: const SplashScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/onboarding': (context) => const HeritageOnboardingScreen(),
        '/discovery': (context) => const DiscoveryScreen(query: 'cough'), // Default fallback
      },
    );
  }
}
