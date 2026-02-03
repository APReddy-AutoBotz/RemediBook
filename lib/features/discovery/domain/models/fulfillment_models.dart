import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Fulfillment Model - Data needed for the 3-card stack
class FulfillmentData {
  final String remedyName;
  final String? vernacularName;
  final String? vernacularWisdom;
  final List<PrepStep> prepSteps;
  final List<IngredientStatus> materials;
  final CommerceComparison priceComparison;
  final PracticeTechnique practice;
  final EscalationCriteria escalation;
  final bool safetyWarning;
  final String? safetyMessage;
  
  // Consistency Handshake: Null Inventory Gate
  final bool hasPhysicalMaterials;

  const FulfillmentData({
    required this.remedyName,
    this.vernacularName,
    this.vernacularWisdom,
    required this.prepSteps,
    required this.materials,
    required this.priceComparison,
    required this.practice,
    required this.escalation,
    this.safetyWarning = false,
    this.safetyMessage,
    this.hasPhysicalMaterials = true,
  });
}

class PrepStep {
  final String instruction;
  final int? durationSeconds;
  
  const PrepStep(this.instruction, {this.durationSeconds});
}

class IngredientStatus {
  final String name;
  final bool inStock;
  
  // Vernacular Bridge: Local name for geo-adaptive commerce
  final String? vernacularName;
  
  const IngredientStatus(this.name, this.inStock, {this.vernacularName});
}

class CommerceComparison {
  final double zeptoPrice;
  final String zeptoTime;
  final double blinkitPrice;
  final String blinkitTime;

  const CommerceComparison({
    required this.zeptoPrice,
    required this.zeptoTime,
    required this.blinkitPrice,
    required this.blinkitTime,
  });
}

class PracticeTechnique {
  final String title;
  final IconData icon;
  final List<String> howTo;

  const PracticeTechnique({
    required this.title,
    required this.icon,
    required this.howTo,
  });
}

class EscalationCriteria {
  final int hourThreshold;
  final String guidance;
  final List<String> redFlags;
  final bool isBookingAvailable;
  final String? clinicName;

  const EscalationCriteria({
    required this.hourThreshold,
    required this.guidance,
    required this.redFlags,
    this.isBookingAvailable = false,
    this.clinicName,
  });
}
