import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'motion_prefs.dart';

/// RiveFileCache - Performance optimization
/// Prevents parsing the same .riv file multiple times.
class RiveFileCache {
  static final Map<String, RiveFile> _cache = {};
  static final Map<String, Future<RiveFile>> _pending = {};

  /// Preload a Rive file into cache
  static Future<void> preload(String assetPath) async {
    if (_cache.containsKey(assetPath)) return;
    if (_pending.containsKey(assetPath)) {
      await _pending[assetPath];
      return;
    }

    final future = _load(assetPath);
    _pending[assetPath] = future;
    
    try {
      final file = await future;
      _cache[assetPath] = file;
    } catch (e) {
      debugPrint('RiveFileCache Error loading $assetPath: $e');
    } finally {
      _pending.remove(assetPath);
    }
  }

  static Future<RiveFile> _load(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return RiveFile.import(data);
  }

  static RiveFile? get(String assetPath) => _cache[assetPath];
}

/// SanctuaryRive - Safe Rive Widget
/// Handles errors, loading states, and reduced motion preferences automatically.
class SanctuaryRive extends StatefulWidget {
  final String assetPath;
  final String? artboard;
  final String? stateMachine;
  final BoxFit fit;
  final Widget? fallback;

  const SanctuaryRive({
    super.key,
    required this.assetPath,
    this.artboard,
    this.stateMachine,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  State<SanctuaryRive> createState() => _SanctuaryRiveState();
}

class _SanctuaryRiveState extends State<SanctuaryRive> {
  RiveFile? _file;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SanctuaryRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _load();
    }
  }

  Future<void> _load() async {
    // Check global motion preference
    if (!MotionPrefs.isMotionEnabled.value) {
      if (mounted) setState(() => _file = null);
      return; 
    }

    try {
      // Check cache first
      final cached = RiveFileCache.get(widget.assetPath);
      if (cached != null) {
        if (mounted) setState(() => _file = cached);
        return;
      }

      // Safe Load: try-catch prevents red screen on missing asset
      try {
        // Attempt load
        await RiveFileCache.preload(widget.assetPath);
        if (mounted) {
           setState(() => _file = RiveFileCache.get(widget.assetPath));
        }
      } catch (assetError) {
        // Log ONCE and fail silently to fallback
        debugPrint('SanctuaryRive: Asset missing or invalid (${widget.assetPath}). Using fallback.');
        if (mounted) setState(() => _hasError = true);
      }

    } catch (e) {
      // Catch-all for other errors
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Motion Disabled OR Error OR File Missing -> Show Fallback
    return ValueListenableBuilder<bool>(
      valueListenable: MotionPrefs.isMotionEnabled,
      builder: (context, isEnabled, child) {
        if (!isEnabled || _hasError || _file == null) {
          return widget.fallback ?? const SizedBox.shrink();
        }

        // 2. Rive Active
        return RiveAnimation.direct(
          _file!,
          artboard: widget.artboard,
          stateMachines: widget.stateMachine != null ? [widget.stateMachine!] : [],
          fit: widget.fit,
        );
      },
    );
  }
}
