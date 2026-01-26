import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/features/dashboard/presentation/screens/dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Auto-trigger sheet after small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInvisibleAuth();
    });
  }

  void _showInvisibleAuth() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.05),
      builder: (context) => _buildGlassSheet(context),
    );
  }

  Widget _buildGlassSheet(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RemediTheme.deepTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Enter the Sanctuary',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Experience the Wisdom Engine without friction.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: RemediTheme.darkForest.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            // Primary Auth
            _authButton(
              context, 
              'Continue with Google', 
              Icons.g_mobiledata_rounded,
              onPressed: () => _handleLogin(context, 'Google'),
            ),
            
            const SizedBox(height: 16),
            
            // Guest Access (Master Command Requirement)
            _authButton(
              context, 
              'Guest Exploration', 
              Icons.spa_rounded,
              isSecondary: true,
              onPressed: () => _handleLogin(context, 'Guest'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authButton(BuildContext context, String label, IconData icon, {bool isSecondary = false, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white.withOpacity(0.5) : RemediTheme.deepTeal,
          foregroundColor: isSecondary ? RemediTheme.deepTeal : Colors.white,
          side: isSecondary ? const BorderSide(color: RemediTheme.deepTeal, width: 0.5) : null,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, String method) {
    HapticFeedback.lightImpact();
    Navigator.pop(context); // Close sheet
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, sec) => const DashboardScreen(),
        transitionsBuilder: (context, anim, sec, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediTheme.warmLimestone,
      body: Stack(
        children: [
          // Subtle motif background
          Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/background_motif.png',
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
            ),
          ),
          const Center(
            child: Icon(Icons.spa_rounded, color: RemediTheme.deepTeal, size: 64),
          ),
        ],
      ),
    );
  }
}
