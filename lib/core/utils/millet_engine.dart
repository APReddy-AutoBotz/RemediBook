import 'package:flutter/material.dart';

class MilletProtocol {
  final String name;
  final String description;
  final String benefits;

  MilletProtocol({required this.name, required this.description, required this.benefits});
}

class MilletRotationEngine {
  static final List<MilletProtocol> positiveMillets = [
    MilletProtocol(
      name: 'Kodo Millet', 
      description: 'Arikelu', 
      benefits: 'Blood purification and bone marrow health.'
    ),
    MilletProtocol(
      name: 'Barnyard Millet', 
      description: 'Oodalu', 
      benefits: 'Liver, kidney, and endocrine system detoxification.'
    ),
    MilletProtocol(
      name: 'Little Millet', 
      description: 'Samalu', 
      benefits: 'Reproductive system and lymphatic system health.'
    ),
    MilletProtocol(
      name: 'Foxtail Millet', 
      description: 'Korra', 
      benefits: 'Nervous system and respiratory health.'
    ),
    MilletProtocol(
      name: 'Browntop Millet', 
      description: 'Andu Korra', 
      benefits: 'Digestive system and clear skin.'
    ),
  ];

  static MilletProtocol getCurrentMillet() {
    // Current 2-day cycle logic based on days since epoch
    final daysSinceEpoch = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    final index = (daysSinceEpoch ~/ 2) % positiveMillets.length;
    return positiveMillets[index];
  }

  static String getRotationCycle() {
    final current = getCurrentMillet();
    return "Current Cycle: ${current.name} (2 Days). Benefits: ${current.benefits}";
  }
}
