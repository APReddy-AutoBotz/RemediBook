import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';

/// VerificationLabelResolver - UI-only helper for region-aware verification pills
/// 
/// Primary source: User profile region.id
/// Fallback 1: Device locale countryCode
/// Fallback 2: Timezone offset (last resort)
class VerificationLabelResolver {
  /// Get verification label based on region
  /// 
  /// Mapping:
  /// - {"asia", "india"} => "Board Verified"
  /// - {"europe", "north-america"} => "Physician Verified"
  /// - else => "Clinically Verified"
  static String getLabel({String? userRegion}) {
    // Primary: User-selected region from profile
    if (userRegion != null && userRegion.isNotEmpty) {
      return _mapRegionToLabel(userRegion.toLowerCase());
    }

    // Fallback 1: Device locale countryCode
    try {
      String? countryCode;
      
      if (kIsWeb) {
        // Platform.localeName behaves differently or throws on web/some envs
        // Use PlatformDispatcher as a safer web fallback
        final locale = PlatformDispatcher.instance.locale;
        countryCode = locale.countryCode;
      } else {
        // Mobile/Desktop: Use Platform.localeName (e.g., "en_US")
        final localeName = Platform.localeName;
        if (localeName.contains('_')) {
          countryCode = localeName.split('_')[1];
        } else if (localeName.length >= 2) {
           // Fallback if no underscore but valid string? Rare for standard locales.
        }
      }

      if (countryCode != null) {
        final region = _mapCountryCodeToRegion(countryCode.toUpperCase());
        if (region != null) {
          return _mapRegionToLabel(region);
        }
      }
    } catch (e) {
      debugPrint('VerificationLabelResolver: Locale fallback failed: $e');
    }

    // Fallback 2: Timezone offset (last resort)
    try {
      final offset = DateTime.now().timeZoneOffset;
      final region = _mapTimezoneToRegion(offset);
      return _mapRegionToLabel(region);
    } catch (e) {
      debugPrint('VerificationLabelResolver: Timezone fallback failed: $e');
    }

    // Ultimate fallback
    return 'Clinically Verified';
  }

  /// Map region ID to verification label
  static String _mapRegionToLabel(String region) {
    if (region == 'asia' || region == 'india') {
      return 'Board Verified';
    } else if (region == 'europe' || region == 'north-america') {
      return 'Physician Verified';
    } else {
      return 'Clinically Verified';
    }
  }

  /// Map country code to region ID
  static String? _mapCountryCodeToRegion(String countryCode) {
    // Asia/India
    if (['IN', 'CN', 'JP', 'KR', 'SG', 'MY', 'TH', 'ID', 'PH', 'VN', 'BD', 'PK', 'LK'].contains(countryCode)) {
      return 'asia';
    }
    // Europe
    else if (['GB', 'FR', 'DE', 'IT', 'ES', 'NL', 'BE', 'CH', 'AT', 'SE', 'NO', 'DK', 'FI', 'PL', 'IE'].contains(countryCode)) {
      return 'europe';
    }
    // North America
    else if (['US', 'CA', 'MX'].contains(countryCode)) {
      return 'north-america';
    }
    return null;
  }

  /// Map timezone offset to region ID (last resort)
  static String _mapTimezoneToRegion(Duration offset) {
    final hours = offset.inHours;
    // Asia/India: UTC+5 to UTC+9
    if (hours >= 5 && hours <= 9) {
      return 'asia';
    }
    // Europe: UTC+0 to UTC+2
    else if (hours >= 0 && hours <= 2) {
      return 'europe';
    }
    // North America: UTC-8 to UTC-5
    else if (hours >= -8 && hours <= -5) {
      return 'north-america';
    }
    return 'other';
  }
}
