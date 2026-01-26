import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';

class PulseRing extends StatefulWidget {
  final int streak;
  const PulseRing({super.key, required this.streak});

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: RemediTheme.deepTeal.withOpacity(0.05),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: 0.7, // Mock progress
                strokeWidth: 10,
                backgroundColor: RemediTheme.mutedSage.withOpacity(0.2),
                color: RemediTheme.deepTeal,
                strokeCap: StrokeCap.round,
              ),
            ),
            
            // Inner Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fireplace_rounded, color: RemediTheme.deepTeal, size: 40),
                const SizedBox(height: 8),
                Text(
                  '${widget.streak}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
                ),
                Text(
                  'DAY STREAK',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: RemediTheme.deepTeal.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
