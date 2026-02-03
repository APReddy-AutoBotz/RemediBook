import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';

class CircularStepTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const CircularStepTimer({
    super.key,
    required this.duration,
    this.onComplete,
  });

  @override
  State<CircularStepTimer> createState() => _CircularStepTimerState();
}

class _CircularStepTimerState extends State<CircularStepTimer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() {
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    HapticFeedback.mediumImpact(); // Haptic Pulse
    widget.onComplete?.call();
  }

  void _toggleTimer() {
    if (_isCompleted) return; // Already done

    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _controller.forward();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _timerString {
    if (_isCompleted) return "Done";
    Duration remaining = widget.duration * (1.0 - _controller.value);
    // If controller hasn't started, show full duration
    if (_controller.value == 0) remaining = widget.duration;
    
    // Round to nearest second for display
    final seconds = remaining.inSeconds + (remaining.inMilliseconds % 1000 > 0 ? 1 : 0);
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTimer,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Track
                CustomPaint(
                  painter: _RingPainter(
                    progress: 1.0,
                    color: RemediTheme.charcoal.withOpacity(0.1),
                    strokeWidth: 3,
                  ),
                  child: const SizedBox.expand(),
                ),
                // Progress Arc
                CustomPaint(
                  painter: _RingPainter(
                    progress: _controller.value,
                    color: _isCompleted ? RemediTheme.deepTeal : const Color(0xFFD4A373),
                    strokeWidth: 3,
                  ),
                  child: const SizedBox.expand(),
                ),
                // Center Icon/Text
                _isCompleted
                    ? const Icon(Icons.check_rounded, size: 20, color: RemediTheme.deepTeal)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isRunning && _controller.value == 0)
                             const Icon(Icons.play_arrow_rounded, size: 16, color: RemediTheme.charcoal)
                          else if (!_isRunning && _controller.value > 0)
                             const Icon(Icons.pause_rounded, size: 16, color: RemediTheme.charcoal)
                          else
                            Text(
                              _timerString,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: RemediTheme.charcoal,
                              ),
                            ),
                          
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
