import 'package:flutter/material.dart';
import 'package:remedibook/core/models/user_profile.dart';
import 'package:remedibook/core/services/search_history_service.dart';
import 'package:remedibook/core/services/safety_twin_validator.dart';

/// Activity categories for timeline slots
enum ActivityCategory {
  waterDharma,      // Foundation hydration
  milletRotation,   // Metabolic support (Siridhanya)
  herbalTea,        // Acute ailment relief
  mindBodyPractice, // Pranayama, meditation, yoga
}

/// Time blocks for organizing the daily schedule
enum ScheduleBlock {
  morning,   // 5 AM - 11 AM
  midDay,    // 11 AM - 4 PM
  evening,   // 4 PM - 9 PM
  night,     // 9 PM - 5 AM
}

/// Represents a single slot in the daily healing schedule
class ScheduleSlot {
  final String time;
  final String title;
  final String description;
  final IconData icon;
  final ActivityCategory category;
  final ScheduleBlock block;
  final Color accentColor;
  bool isCompleted;
  DateTime? completedAt;

  ScheduleSlot({
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.block,
    required this.accentColor,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Parse time string (e.g., "07:00 AM") to TimeOfDay
  TimeOfDay get timeOfDay {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minuteParts = parts[1].split(' ');
    final minute = int.parse(minuteParts[0]);
    final isPM = minuteParts[1].toUpperCase() == 'PM';
    
    int adjustedHour = hour;
    if (isPM && hour != 12) {
      adjustedHour = hour + 12;
    } else if (!isPM && hour == 12) {
      adjustedHour = 0;
    }
    
    return TimeOfDay(hour: adjustedHour, minute: minute);
  }

  /// Check if this slot is within 30 minutes of current time
  bool isInCurrentWindow() {
    final now = DateTime.now();
    final itemTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final difference = itemTime.difference(now);
    
    return difference.inMinutes.abs() <= 30 && difference.inMinutes >= -30;
  }

  /// Check if this slot's time has passed and it's not completed
  bool isMissed() {
    final now = DateTime.now();
    final itemTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    
    return now.isAfter(itemTime) && !isCompleted;
  }

  /// Check if this slot is in the future
  bool isFuture() {
    final now = DateTime.now();
    final itemTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    
    return now.isBefore(itemTime.subtract(const Duration(minutes: 30)));
  }

  /// Get the schedule block for a given time
  static ScheduleBlock getBlockForTime(String time) {
    final timeOfDay = _parseTime(time);
    final hour = timeOfDay.hour;

    if (hour >= 5 && hour < 11) return ScheduleBlock.morning;
    if (hour >= 11 && hour < 16) return ScheduleBlock.midDay;
    if (hour >= 16 && hour < 21) return ScheduleBlock.evening;
    return ScheduleBlock.night;
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minuteParts = parts[1].split(' ');
    final minute = int.parse(minuteParts[0]);
    final isPM = minuteParts[1].toUpperCase() == 'PM';
    
    int adjustedHour = hour;
    if (isPM && hour != 12) {
      adjustedHour = hour + 12;
    } else if (!isPM && hour == 12) {
      adjustedHour = 0;
    }
    
    return TimeOfDay(hour: adjustedHour, minute: minute);
  }
}

/// Dynamic Healing Schedule Service - PILLAR 3 Synthesis Engine
/// Generates personalized 24-hour wellness timelines
class HealingScheduleService {
  /// Generate a complete daily schedule based on user profile and search history
  static Future<List<ScheduleSlot>> generateDailySchedule({
    required SovereignProfile profile,
  }) async {
    final slots = <ScheduleSlot>[];

    // Step 1: Add baseline Water Dharma slots (Foundation)
    slots.addAll(_addBaselineWaterDharma());

    // Step 2: Check search history for ailment-specific injections
    final recentSearches = await SearchHistoryService.getRecentSearches(
      const Duration(hours: 48),
    );
    final ailments = SearchHistoryService.extractAilments(recentSearches);
    slots.addAll(_injectAilmentSpecificSlots(ailments));

    // Step 3: Add mind-body practice based on profile
    slots.addAll(_addMindBodyPractice(profile));

    // Step 4: Safety Twin validation - filter unsafe recommendations
    final safeSlots = _validateWithSafetyTwin(slots, profile);

    // Sort by time
    safeSlots.sort((a, b) {
      final aHour = a.timeOfDay.hour * 60 + a.timeOfDay.minute;
      final bHour = b.timeOfDay.hour * 60 + b.timeOfDay.minute;
      return aHour.compareTo(bHour);
    });

    return safeSlots;
  }

  /// Step 1: Add baseline Water Dharma slots (3 foundation hydration points)
  static List<ScheduleSlot> _addBaselineWaterDharma() {
    return [
      ScheduleSlot(
        time: "07:00 AM",
        title: "Morning Water Dharma",
        description: "400ml Copper-charged sip",
        icon: Icons.water_drop_rounded,
        category: ActivityCategory.waterDharma,
        block: ScheduleBlock.morning,
        accentColor: Colors.blue.withOpacity(0.4),
      ),
      ScheduleSlot(
        time: "11:30 AM",
        title: "Window 2: Hydration",
        description: "Cellular Refresh Window",
        icon: Icons.water_drop_rounded,
        category: ActivityCategory.waterDharma,
        block: ScheduleBlock.midDay,
        accentColor: Colors.blue.withOpacity(0.4),
      ),
      ScheduleSlot(
        time: "04:00 PM",
        title: "Evening Hydration",
        description: "Warm water ritual",
        icon: Icons.water_drop_rounded,
        category: ActivityCategory.waterDharma,
        block: ScheduleBlock.evening,
        accentColor: Colors.blue.withOpacity(0.4),
      ),
    ];
  }

  /// Step 2: Inject ailment-specific slots based on search history
  static List<ScheduleSlot> _injectAilmentSpecificSlots(Set<String> ailments) {
    final slots = <ScheduleSlot>[];

    // Diabetes / Blood Sugar - Millet Rotation
    if (ailments.contains('diabetes')) {
      slots.addAll([
        ScheduleSlot(
          time: "09:30 AM",
          title: "Foxtail Millet Bowl",
          description: "Metabolic Support (Siridhanya)",
          icon: Icons.grass_rounded,
          category: ActivityCategory.milletRotation,
          block: ScheduleBlock.morning,
          accentColor: const Color(0xFFD4A373).withOpacity(0.4),
        ),
        ScheduleSlot(
          time: "01:00 PM",
          title: "Little Millet Lunch",
          description: "Blood sugar regulation",
          icon: Icons.rice_bowl_rounded,
          category: ActivityCategory.milletRotation,
          block: ScheduleBlock.midDay,
          accentColor: const Color(0xFFD4A373).withOpacity(0.4),
        ),
      ]);
    }

    // Common Cold / Respiratory - Herbal Tea Protocol
    if (ailments.contains('common_cold')) {
      slots.addAll([
        ScheduleSlot(
          time: "10:00 AM",
          title: "Tulsi Tea Ritual",
          description: "Immunity boost & respiratory support",
          icon: Icons.local_cafe_rounded,
          category: ActivityCategory.herbalTea,
          block: ScheduleBlock.morning,
          accentColor: Colors.green.withOpacity(0.4),
        ),
        ScheduleSlot(
          time: "03:00 PM",
          title: "Ginger Tea",
          description: "Anti-inflammatory warmth",
          icon: Icons.local_cafe_rounded,
          category: ActivityCategory.herbalTea,
          block: ScheduleBlock.midDay,
          accentColor: Colors.orange.withOpacity(0.4),
        ),
      ]);
    }

    // Acidity / Indigestion - Cooling herbs
    if (ailments.contains('acidity') || ailments.contains('indigestion')) {
      slots.add(
        ScheduleSlot(
          time: "02:00 PM",
          title: "Fennel Tea",
          description: "Digestive calm & cooling",
          icon: Icons.local_cafe_rounded,
          category: ActivityCategory.herbalTea,
          block: ScheduleBlock.midDay,
          accentColor: Colors.teal.withOpacity(0.4),
        ),
      );
    }

    // Stress / Anxiety - Calming herbs
    if (ailments.contains('stress')) {
      slots.add(
        ScheduleSlot(
          time: "08:00 PM",
          title: "Ashwagandha Tea",
          description: "Stress relief & nervous system support",
          icon: Icons.spa_rounded,
          category: ActivityCategory.herbalTea,
          block: ScheduleBlock.evening,
          accentColor: Colors.purple.withOpacity(0.4),
        ),
      );
    }

    // Sleep Issues - Evening protocol
    if (ailments.contains('sleep_issues')) {
      slots.add(
        ScheduleSlot(
          time: "09:00 PM",
          title: "Chamomile Ritual",
          description: "Sleep preparation & relaxation",
          icon: Icons.bedtime_rounded,
          category: ActivityCategory.herbalTea,
          block: ScheduleBlock.night,
          accentColor: Colors.indigo.withOpacity(0.4),
        ),
      );
    }

    return slots;
  }

  /// Step 3: Add mind-body practice based on Sovereign Profile
  static List<ScheduleSlot> _addMindBodyPractice(SovereignProfile profile) {
    // Default: Add pranayama for everyone
    // In future, this could be customized based on profile preferences
    return [
      ScheduleSlot(
        time: "06:00 AM",
        title: "Pranayama Practice",
        description: "Breath awareness & energy activation",
        icon: Icons.air_rounded,
        category: ActivityCategory.mindBodyPractice,
        block: ScheduleBlock.morning,
        accentColor: Colors.amber.withOpacity(0.4),
      ),
    ];
  }

  /// Step 4: Safety Twin validation - filter unsafe recommendations
  static List<ScheduleSlot> _validateWithSafetyTwin(
    List<ScheduleSlot> slots,
    SovereignProfile profile,
  ) {
    return slots.where((slot) {
      return SafetyTwinValidator.validateRecommendation(
        title: slot.title,
        description: slot.description,
        profile: profile,
      );
    }).toList();
  }

  /// Get block name for display
  static String getBlockName(ScheduleBlock block) {
    switch (block) {
      case ScheduleBlock.morning:
        return 'Morning';
      case ScheduleBlock.midDay:
        return 'Mid-Day';
      case ScheduleBlock.evening:
        return 'Evening';
      case ScheduleBlock.night:
        return 'Night';
    }
  }

  /// Get block time range for display
  static String getBlockTimeRange(ScheduleBlock block) {
    switch (block) {
      case ScheduleBlock.morning:
        return '5 AM - 11 AM';
      case ScheduleBlock.midDay:
        return '11 AM - 4 PM';
      case ScheduleBlock.evening:
        return '4 PM - 9 PM';
      case ScheduleBlock.night:
        return '9 PM - 5 AM';
    }
  }
}
