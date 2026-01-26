import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _rayController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Main Fade In
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Floating Logo Animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Golden Ray Pulse Animation
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Particle Animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _fadeController.forward();

    // Navigation to Home
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _rayController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cinematic depth
      body: Stack(
        children: [
          // 1. Forest Background (Dark Green/Shadows)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF0F1A0F), // Deep Moss Green
                  Colors.black,
                ],
              ),
            ),
          ),

          // 2. Animated God Rays (Gold Light)
          AnimatedBuilder(
            animation: _rayController,
            builder: (context, child) {
              return CustomPaint(
                painter: GodRayPainter(_rayController.value),
                size: Size.infinite,
              );
            },
          ),

          // 3. Floating Particles (Dust Motes)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleController.value),
                size: Size.infinite,
              );
            },
          ),

          // 4. Floating 3D Logo
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 15 * math.sin(_floatController.value * 2 * math.pi)),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.1),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/splash_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. Subtle Text Branding
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                children: [
                  const Text(
                    'REMEDIBOOK',
                    style: TextStyle(
                      letterSpacing: 10,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF2F0E6), // warmLimestone
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 1,
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ancient Wisdom. Modern Elegance.',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 10,
                      color: const Color(0xFFF2F0E6).withOpacity(0.4),
                      fontFamily: 'Sans-Serif',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter for Ethereal God Rays
class GodRayPainter extends CustomPainter {
  final double progress;
  GodRayPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFD700).withOpacity(0.12 * math.sin(progress * 2 * math.pi).abs()),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.8, 0);
    path.lineTo(size.width * 0.95, size.height);
    path.lineTo(size.width * 0.05, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GodRayPainter oldDelegate) => true;
}

// Painter for Floating Dust Motes
class ParticlePainter extends CustomPainter {
  final double progress;
  final List<math.Point> particles = List.generate(40, (i) {
    final random = math.Random(i);
    return math.Point(random.nextDouble(), random.nextDouble());
  });

  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFE082).withOpacity(0.3);

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final yOffset = (p.y + progress) % 1.0;
      final xOffset = p.x + (0.02 * math.sin(progress * 4 * math.pi + i));
      
      canvas.drawCircle(
        Offset(xOffset * size.width, yOffset * size.height),
        (i % 3 + 1).toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
