import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme.dart';
import 'result_screen.dart';
import 'business_insights_screen.dart';
import '../services/progress_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _symptomController = TextEditingController();
  final ProgressService _progressService = ProgressService();
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  int _totalSavings = 0;
  int _healStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    final metrics = await _progressService.getProgressMetrics();
    setState(() {
      _totalSavings = metrics['totalSavings']!;
      _healStreak = metrics['healStreak']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Biophilic Background Motif
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/background_motif.png',
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Elegant Greeting
                  GestureDetector(
                    onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessInsightsScreen())),
                    child: Text(
                      'Welcome \nback, Alex.',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Glowing Heal Streak Widget
                  Center(
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.deepTeal.withOpacity(0.08),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 190,
                              height: 190,
                              child: CircularProgressIndicator(
                                value: _healStreak / 10,
                                strokeWidth: 12,
                                backgroundColor: AppTheme.mutedSage.withOpacity(0.15),
                                color: AppTheme.deepTeal,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.fireplace_rounded, color: AppTheme.deepTeal, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  '$_healStreak Day',
                                  style: const TextStyle(fontFamily: 'Serif', fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  'Heal Streak',
                                  style: TextStyle(fontFamily: 'Serif', fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 64),

                  // Frosted Glass Health Savings Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.glassDecoration(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Health Savings',
                                    style: TextStyle(
                                      color: AppTheme.darkForest.withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '₹$_totalSavings',
                                    style: const TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.darkForest,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 36,
                              child: CustomPaint(painter: SparklinePainter()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Floating Glassmorphic Search Bar
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 64,
                  decoration: AppTheme.glassDecoration(radius: 22, opacity: 0.55),
                  child: TextField(
                    controller: _symptomController,
                    decoration: InputDecoration(
                      hintText: 'Ask about a symptom or herb...',
                      hintStyle: TextStyle(color: AppTheme.deepTeal.withOpacity(0.4), fontSize: 15),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.deepTeal, size: 24),
                      suffixIcon: const Icon(Icons.mic_rounded, color: AppTheme.deepTeal, size: 24),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResultScreen(symptom: value)),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.deepTeal.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.05);

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
