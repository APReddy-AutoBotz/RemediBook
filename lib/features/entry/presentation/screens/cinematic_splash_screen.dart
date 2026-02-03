import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/motion/motion_prefs.dart';
import '../../../auth/presentation/screens/auth_entry_screen.dart';

/// CinematicSplashScreen - Premium First Impression
/// Implements god rays, floating logo, film grain, and gentle transition
class CinematicSplashScreen extends StatefulWidget {
  const CinematicSplashScreen({super.key});

  @override
  State<CinematicSplashScreen> createState() => _CinematicSplashScreenState();
}

class _CinematicSplashScreenState extends State<CinematicSplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _godRayController;
  late AnimationController _logoController;
  late AnimationController _grainController;

  @override
  void initState() {
    super.initState();
    
    // God Rays: 15s loop (Design Bible)
    _godRayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    
    // Logo Float: 3s gentle bob
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // Film Grain: Fast flicker for texture
    _grainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Start animations if motion enabled
    if (MotionPrefs.isMotionEnabled.value) {
      _godRayController.repeat();
      _logoController.repeat(reverse: true);
      _grainController.repeat();
    }

    // Transition to Auth after 2.2s
    Timer(const Duration(milliseconds: 2200), _navigateToAuth);
  }

  void _navigateToAuth() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const AuthEntryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Gentle ease curve (800ms - Design Bible)
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _godRayController.dispose();
    _logoController.dispose();
    _grainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediTheme.cashmere,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. God Rays Overlay
          ValueListenableBuilder<bool>(
            valueListenable: MotionPrefs.isMotionEnabled,
            builder: (context, isEnabled, _) {
              if (!isEnabled) return const SizedBox.shrink();
              
              return AnimatedBuilder(
                animation: _godRayController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _GodRaysPainter(
                      progress: _godRayController.value,
                    ),
                  );
                },
              );
            },
          ),

          // 2. Floating Logo
          Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: MotionPrefs.isMotionEnabled,
              builder: (context, isEnabled, _) {
                if (!isEnabled) {
                  return _buildLogo(0.0);
                }
                
                return AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    final float = math.sin(_logoController.value * math.pi) * 12;
                    return _buildLogo(float);
                  },
                );
              },
            ),
          ),

          // 3. Film Grain (Optional Premium Touch)
          ValueListenableBuilder<bool>(
            valueListenable: MotionPrefs.isMotionEnabled,
            builder: (context, isEnabled, _) {
              if (!isEnabled) return const SizedBox.shrink();
              
              return AnimatedBuilder(
                animation: _grainController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FilmGrainPainter(
                      seed: _grainController.value,
                    ),
                  );
                },
              );
            },
          ),

          // 4. App Name
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'REMEDIBOOK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: RemediTheme.deepTeal.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ancient Wisdom. Modern Elegance.',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildLogo(double offsetY) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: RemediTheme.deepTeal.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.spa_rounded,
          size: 60,
          color: RemediTheme.deepTeal,
        ),
      ),
    );
  }
}

/// _GodRaysPainter - Cinematic light beams
class _GodRaysPainter extends CustomPainter {
  final double progress;

  _GodRaysPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RemediTheme.emberGold.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // Draw 5 rotating beams
    for (int i = 0; i < 5; i++) {
      final angle = (progress * 2 * math.pi) + (i * (2 * math.pi / 5));
      final path = Path();
      
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      final length = size.height * 0.8;
      
      path.moveTo(centerX, centerY);
      path.lineTo(
        centerX + math.cos(angle) * length,
        centerY + math.sin(angle) * length,
      );
      path.lineTo(
        centerX + math.cos(angle + 0.1) * length,
        centerY + math.sin(angle + 0.1) * length,
      );
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_GodRaysPainter oldDelegate) => 
      oldDelegate.progress != progress;
}

/// _FilmGrainPainter - Subtle texture overlay
class _FilmGrainPainter extends CustomPainter {
  final double seed;

  _FilmGrainPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.02);

    final random = math.Random((seed * 1000).toInt());
    
    // Draw ~200 random dots
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_FilmGrainPainter oldDelegate) => 
      oldDelegate.seed != seed;
}
