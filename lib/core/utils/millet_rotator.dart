class MilletRotator {
  static final List<String> millets = [
    'Kodo Millet (Arikelu)',
    'Barnyard Millet (Oodalu)',
    'Little Millet (Samalu)',
    'Foxtail Millet (Korra)',
    'Browntop Millet (Andu Korra)',
  ];

  static String getCurrentMillet() {
    // 2-day cycle logic based on a fixed reference point
    final referenceDate = DateTime(2024, 1, 1);
    final daysSinceStart = DateTime.now().difference(referenceDate).inDays;
    final currentCycleIndex = (daysSinceStart ~/ 2) % millets.length;
    return millets[currentCycleIndex];
  }

  static String getInstruction() {
    return "Consume ${getCurrentMillet()} for 2 consecutive days. Benefits include deep cellular cleansing and glycemic balance.";
  }
}
