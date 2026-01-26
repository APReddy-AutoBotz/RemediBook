class MNLSWaterProtocol {
  static List<String> getDailySchedule() {
    return [
      '05:00 - 06:30: 1.5L Lukewarm Water (Waking)',
      '08:00 - 09:30: 1.0L Lukewarm Water',
      'Meal Rule: No water 30 mins before or 2 hours after meals.',
    ];
  }

  static String getNextNotification() {
    // Mock logic for next water alert
    return "Next Water Dharma: 1.5L upon waking tomorrow morning.";
  }
}
