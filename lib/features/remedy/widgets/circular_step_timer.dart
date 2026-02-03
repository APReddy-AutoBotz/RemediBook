// Design Bible Reference: docs/DESIGN_BIBLE.md - Phase 4 (Sovereign Triad 2.0)
// Implements circular countdown timer for remedy preparation steps

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:remedibook/core/theme/remedi_theme.dart';

/// CircularStepTimer - Interactive countdown timer for preparation steps
/// 
/// Specification from Design Bible:
/// - Tap to start countdown
/// - Gentle ease animation (800ms default)
/// - Haptic pulse on finish (medium impact)
/// - Deep Teal progress ring
/// - Ember Gold on completion
/// - Reduce motion support
class CircularStepTimer extends StatefulWidget {
  /// Duration of the timer in seconds
  final int durationSeconds;
  
  /// Callback when timer completes
  final VoidCallback? onComplete;
  
  /// Optional label for the step
  final String? stepLabel;
  
  /// Size of the timer widget
  final double size;
  
  /// Accessibility: disable animations
  final bool reduceMotion;
  
  /// Enable haptic feedback
  final bool enableHaptics;

  const CircularStepTimer({
    super.key,
    required this.durationSeconds,
    this.onComplete,
    this.stepLabel,
    this.size = 120,
    this.reduceMotion = false,
    this.enableHaptics = true,
  });

  @override
  State<CircularStepTimer> createState() => _CircularStepTimerState();
}

class _CircularStepTimerState extends State<CircularStepTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  
  bool _isRunning = false;
  bool _isComplete = false;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    
    // Timer controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );

    // Progress animation with gentle ease
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear, // Linear for timer countdown
    ));

    _controller.addListener(_updateRemainingTime);
    _controller.addStatusListener(_handleTimerComplete);
  }

  void _updateRemainingTime() {
    final newRemaining = (widget.durationSeconds * (1 - _controller.value)).ceil();
    if (newRemaining != _remainingSeconds) {
      setState(() {
        _remainingSeconds = newRemaining;
      });
    }
  }

  void _handleTimerComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isComplete = true;
        _isRunning = false;
      });
      
      // Haptic feedback on completion
      if (widget.enableHaptics) {
        HapticFeedback.mediumImpact();
      }
      
      // Callback
      widget.onComplete?.call();
    }
  }

  void _toggleTimer() {
    if (_isComplete) {
      // Reset timer
      setState(() {
        _isComplete = false;
        _isRunning = false;
        _remainingSeconds = widget.durationSeconds;
      });
      _controller.reset();
    } else if (_isRunning) {
      // Pause timer
      setState(() {
        _isRunning = false;
      });
      _controller.stop();
    } else {
      // Start timer
      setState(() {
        _isRunning = true;
      });
      
      // Light haptic on start
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTimer,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Timer ring
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CircularTimerPainter(
                progress: _progressAnimation.value,
                isComplete: _isComplete,
                reduceMotion: widget.reduceMotion,
              ),
            ),
            
            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Time display
                Text(
                  _formatTime(_remainingSeconds),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: widget.size * 0.25,
                    fontWeight: FontWeight.w600,
                    color: _isComplete 
                        ? const Color(0xFFD4A373) // Ember Gold
                        : RemediTheme.deepTeal,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Status label
                Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    fontSize: widget.size * 0.08,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: RemediTheme.charcoal.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            
            // Play/Pause icon overlay
            if (!_isRunning && !_isComplete)
              Icon(
                Icons.play_arrow_rounded,
                size: widget.size * 0.15,
                color: RemediTheme.deepTeal.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '$secs';
  }

  String _getStatusLabel() {
    if (_isComplete) return 'COMPLETE';
    if (_isRunning) return 'IN PROGRESS';
    return 'TAP TO START';
  }
}

/// Custom painter for circular timer ring
class _CircularTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final bool isComplete;
  final bool reduceMotion;

  _CircularTimerPainter({
    required this.progress,
    required this.isComplete,
    this.reduceMotion = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;

    // Background ring
    final bgPaint = Paint()
      ..color = RemediTheme.mutedSage.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressColor = isComplete 
        ? const Color(0xFFD4A373) // Ember Gold
        : RemediTheme.deepTeal;
    
    final progressPaint = Paint()
      ..color = progressColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      progressPaint,
    );

    // Completion glow
    if (isComplete && !reduceMotion) {
      final glowPaint = Paint()
        ..color = const Color(0xFFD4A373).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isComplete != isComplete;
}
