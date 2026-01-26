import 'package:flutter/material.dart';
import 'package:remedibook/features/discovery/presentation/widgets/red_alert_modal.dart';

class SafetyInterceptor {
  static final List<String> _emergencyKeywords = [
    'chest pain', 'seizure', 'shortness of breath', 'unconscious', 
    'bleeding', 'stroke', 'head injury', 'facial drooping'
  ];

  static bool isEmergency(String query) {
    return _emergencyKeywords.any((keyword) => query.toLowerCase().contains(keyword));
  }

  static void triggerRedAlert(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RedAlertModal(),
    );
  }
}
