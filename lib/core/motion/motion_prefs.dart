import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MotionPrefs - Global Motion Toggle
/// Manages user preference for reduced motion / high-fidelity animations.
class MotionPrefs {
  static const String _key = 'enable_motion';
  
  /// Global notifier for motion state
  static final ValueNotifier<bool> isMotionEnabled = ValueNotifier<bool>(true);

  /// Initialize preference asynchronously
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isMotionEnabled.value = prefs.getBool(_key) ?? true;
  }

  /// Toggle motion on/off
  static Future<void> setMotion(bool enabled) async {
    isMotionEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
