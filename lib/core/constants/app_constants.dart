/// RemediBook Constants
/// Centralized constants for the application
library;

// ═══════════════════════════════════════════════════════════════════════
// ASSET PATHS
// ═══════════════════════════════════════════════════════════════════════

class AssetPaths {
  // Images
  static const String splashLogo = 'assets/images/splash_logo.png';
  static const String splashGif = 'assets/images/splash_logo_updated.gif.gif';
  static const String backgroundMotif = 'assets/images/background_motif.png';
  static const String gingerTulsiMacro = 'assets/images/ginger_tulsi_macro.png';
}

// ═══════════════════════════════════════════════════════════════════════
// APP STRINGS
// ═══════════════════════════════════════════════════════════════════════

class AppStrings {
  // App Info
  static const String appName = 'RemediBook';
  static const String appTagline = 'Ancient Wisdom. Modern Elegance.';
  
  // Splash
  static const String splashTitle = 'REMEDIBOOK';
  
  // Triage
  static const String triageEmergencyTitle = 'Emergency Detected';
  static const String triageCautionTitle = 'Caution Required';
  static const String triageEmergencyAction = 'Call Emergency Services';
  static const String triageCautionAction = 'Acknowledge & Continue';
  
  // Evidence Labels
  static const String evidenceTraditional = 'Traditional';
  static const String evidenceSupported = 'Evidence-Supported';
  
  // Artifact
  static const String artifactGuidePrefix = 'RB-';
  static const String artifactMetricsProtocols = 'Protocols Completed';
  static const String artifactMetricsGuides = 'Guides Saved';
  static const String artifactMetricsSources = 'Evidence Sources Reviewed';
}

// ═══════════════════════════════════════════════════════════════════════
// DURATIONS
// ═══════════════════════════════════════════════════════════════════════

class AppDurations {
  static const Duration splashDuration = Duration(seconds: 7); // Extended for complete GIF playback
  static const Duration fadeTransition = Duration(milliseconds: 800);
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
}
