import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SovereignProfile {
  final bool isPregnant;
  final bool onBPMeds;
  final bool isDiabetic;
  final List<String> allergies;

  SovereignProfile({
    this.isPregnant = false,
    this.onBPMeds = false,
    this.isDiabetic = false,
    this.allergies = const [],
  });

  Map<String, dynamic> toJson() => {
        'isPregnant': isPregnant,
        'onBPMeds': onBPMeds,
        'isDiabetic': isDiabetic,
        'allergies': allergies,
      };

  factory SovereignProfile.fromJson(Map<String, dynamic> json) => SovereignProfile(
        isPregnant: json['isPregnant'] ?? false,
        onBPMeds: json['onBPMeds'] ?? false,
        isDiabetic: json['isDiabetic'] ?? false,
        allergies: List<String>.from(json['allergies'] ?? []),
      );

  SovereignProfile copyWith({
    bool? isPregnant,
    bool? onBPMeds,
    bool? isDiabetic,
    List<String>? allergies,
  }) =>
      SovereignProfile(
        isPregnant: isPregnant ?? this.isPregnant,
        onBPMeds: onBPMeds ?? this.onBPMeds,
        isDiabetic: isDiabetic ?? this.isDiabetic,
        allergies: allergies ?? this.allergies,
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
