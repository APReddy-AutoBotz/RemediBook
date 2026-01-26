import 'dart:async';

class ProgressService {
  // Mocking persistent storage (e.g., SharedPreferences)
  static int _totalSavings = 1250; // Starting with some mock data
  static int _totalMinutesSaved = 360;
  static int _healStreak = 5;

  Future<Map<String, int>> getProgressMetrics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "totalSavings": _totalSavings,
      "totalMinutesSaved": _totalMinutesSaved,
      "healStreak": _healStreak,
    };
  }

  Future<void> recordRemedyUsage(int savings, int minutes) async {
    // Simulating persistence
    _totalSavings += savings;
    _totalMinutesSaved += minutes;
    // Streak logic could be added here
  }
}
