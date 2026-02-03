import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SovereignProfile {
  final bool isPregnant;
  final bool onBPMeds;
  final bool isDiabetic;
  final List<String> allergies;
  final String? region; // For verification label: "asia", "europe", "north-america"
  
  // Phase 7 Expansion
  final List<HealthRecord> healthRecords;
  final List<FamilyMember> familyMembers;

  SovereignProfile({
    this.isPregnant = false,
    this.onBPMeds = false,
    this.isDiabetic = false,
    this.allergies = const [],
    this.region,
    this.healthRecords = const [],
    this.familyMembers = const [],
  });

  Map<String, dynamic> toJson() => {
        'isPregnant': isPregnant,
        'onBPMeds': onBPMeds,
        'isDiabetic': isDiabetic,
        'allergies': allergies,
        'region': region,
        'healthRecords': healthRecords.map((e) => e.toJson()).toList(),
        'familyMembers': familyMembers.map((e) => e.toJson()).toList(),
      };

  factory SovereignProfile.fromJson(Map<String, dynamic> json) => SovereignProfile(
        isPregnant: json['isPregnant'] ?? false,
        onBPMeds: json['onBPMeds'] ?? false,
        isDiabetic: json['isDiabetic'] ?? false,
        allergies: List<String>.from(json['allergies'] ?? []),
        region: json['region'],
        healthRecords: (json['healthRecords'] as List?)
                ?.map((e) => HealthRecord.fromJson(e))
                .toList() ??
            [],
        familyMembers: (json['familyMembers'] as List?)
                ?.map((e) => FamilyMember.fromJson(e))
                .toList() ??
            [],
      );

  SovereignProfile copyWith({
    bool? isPregnant,
    bool? onBPMeds,
    bool? isDiabetic,
    List<String>? allergies,
    String? region,
    List<HealthRecord>? healthRecords,
    List<FamilyMember>? familyMembers,
  }) =>
      SovereignProfile(
        isPregnant: isPregnant ?? this.isPregnant,
        onBPMeds: onBPMeds ?? this.onBPMeds,
        isDiabetic: isDiabetic ?? this.isDiabetic,
        allergies: allergies ?? this.allergies,
        region: region ?? this.region,
        healthRecords: healthRecords ?? this.healthRecords,
        familyMembers: familyMembers ?? this.familyMembers,
      );
}

class SecureProfileStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'sovereign_profile';

  static Future<void> saveProfile(SovereignProfile profile) async {
    await _storage.write(key: _key, value: jsonEncode(profile.toJson()));
  }

  static Future<SovereignProfile?> getProfile() async {
    final data = await _storage.read(key: _key);
    if (data == null) return null;
    return SovereignProfile.fromJson(jsonDecode(data));
  }

  static Future<void> deleteProfile() async {
    await _storage.delete(key: _key);
  }
}

// --- Extended Models for Phase 7 ---

class HealthRecord {
  final String id;
  final String title;
  final String date;
  final String type; // 'Lab Report', 'Prescription', 'Insurance'
  final String? filePath;

  HealthRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    'type': type,
    'filePath': filePath,
  };

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
    id: json['id'],
    title: json['title'],
    date: json['date'],
    type: json['type'],
    filePath: json['filePath'],
  );
}

class FamilyMember {
  final String id;
  final String name;
  final String relation; // 'Child', 'Parent', 'Spouse', 'Self'
  final int age;
  final List<String> allergies;
  final List<String> conditions;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    this.allergies = const [],
    this.conditions = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relation': relation,
    'age': age,
    'allergies': allergies,
    'conditions': conditions,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'],
    name: json['name'],
    relation: json['relation'],
    age: json['age'],
    allergies: List<String>.from(json['allergies'] ?? []),
    conditions: List<String>.from(json['conditions'] ?? []),
  );
}
