// Design Bible Reference: docs/DESIGN_BIBLE.md - Phase 5 (Gemini 3 Reasoning)
// Implements staggered fade-slide text animation for cinematic onboarding

import 'package:flutter/material.dart';

/// StaggeredFadeSlideText - Cinematic text reveal animation
/// 
/// Specification from Design Bible:
/// - Line-by-line reveal with 120ms stagger
/// - Fade + Slide up (20px → 0px)
/// - Gentle ease curve (Curves.easeInOutCubic)
/// - Max 5 lines for optimal timing
/// - Reduce motion support
class StaggeredFadeSlideText extends StatefulWidget {
  /// Lines of text to animate
  final List<String> lines;
  
  /// Text style for all lines
  final TextStyle? style;
  
  /// Alignment of text
  final TextAlign textAlign;
  
  /// Stagger delay between lines (default: 120ms)
  final Duration staggerDelay;
  
  /// Animation duration per line (default: 800ms)
  final Duration animationDuration;
  
  /// Accessibility: disable animations
  final bool reduceMotion;
  
  /// Auto-start animation on mount
  final bool autoStart;

  const StaggeredFadeSlideText({
    super.key,
    required this.lines,
    this.style,
    this.textAlign = TextAlign.center,
    this.staggerDelay = const Duration(milliseconds: 120),
    this.animationDuration = const Duration(milliseconds: 800),
    this.reduceMotion = false,
    this.autoStart = true,
  });

  @override
  State<StaggeredFadeSlideText> createState() => _StaggeredFadeSlideTextState();
}

class _StaggeredFadeSlideTextState extends State<StaggeredFadeSlideText>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.autoStart) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    _controllers = [];
    _fadeAnimations = [];
    _slideAnimations = [];

    for (int i = 0; i < widget.lines.length; i++) {
      // Create controller for each line
      final controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      );
      _controllers.add(controller);

      // Fade animation (0.0 → 1.0)
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic, // Gentle ease
      ));
      _fadeAnimations.add(fadeAnimation);

      // Slide animation (20px down → 0px)
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 20), // 20px down
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic, // Gentle ease
      ));
      _slideAnimations.add(slideAnimation);
    }
  }

  void _startAnimations() {
    if (widget.reduceMotion) {
      // Instant reveal for reduce motion
      for (var controller in _controllers) {
        controller.value = 1.0;
      }
      return;
    }

    // Staggered start
    for (int i = 0; i < _controllers.length; i++) {
      final delay = widget.staggerDelay * i;
      Future.delayed(delay, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  /// Manually trigger animation (if autoStart is false)
  void start() {
    _startAnimations();
  }

  /// Reset all animations
  void reset() {
    for (var controller in _controllers) {
      controller.reset();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.lines.length, (index) {
        return _buildAnimatedLine(index);
      }),
    );
  }

  Widget _buildAnimatedLine(int index) {
    if (widget.reduceMotion) {
      // Static text for reduce motion
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          widget.lines[index],
          style: widget.style,
          textAlign: widget.textAlign,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimations[index].value,
          child: Transform.translate(
            offset: _slideAnimations[index].value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                widget.lines[index],
                style: widget.style,
                textAlign: widget.textAlign,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// StaggeredFadeSlideTextController - For manual control
/// 
/// Use this when you need programmatic control over the animation
class StaggeredFadeSlideTextController {
  final GlobalKey<_StaggeredFadeSlideTextState> _key = GlobalKey();

  GlobalKey<_StaggeredFadeSlideTextState> get key => _key;

  void start() {
    _key.currentState?.start();
  }

  void reset() {
    _key.currentState?.reset();
  }
}

/// Example usage:
/// 
/// ```dart
/// // Auto-start animation
/// StaggeredFadeSlideText(
///   lines: [
///     'Welcome to RemediBook',
///     'Ancient wisdom, modern safety',
///     'Your sovereign health journey begins',
///   ],
///   style: Theme.of(context).textTheme.headlineMedium,
///   textAlign: TextAlign.center,
/// )
/// 
/// // Manual control
/// final controller = StaggeredFadeSlideTextController();
/// 
/// StaggeredFadeSlideText(
///   key: controller.key,
///   lines: ['Line 1', 'Line 2', 'Line 3'],
///   autoStart: false,
/// )
/// 
/// // Later...
/// controller.start();
/// ```
