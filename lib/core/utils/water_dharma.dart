class WaterDharma {
  static List<String> getDailySchedule() {
    return [
      'Waking (05:00 - 06:00): 1.5L Lukewarm Water',
      'Pre-Meal (30 mins before): No Water',
      'Post-Meal (2 hours after): Start Water (1 Glass)',
    ];
  }

  static String getInstruction(DateTime time) {
    // Logic to provide real-time water dharma based on current time
    return 'Dharma: Practice "Vajrasana" for 10 minutes post-meal.';
  }
}
