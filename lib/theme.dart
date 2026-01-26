import 'package:flutter/material.dart';

class AppTheme {
  // Biophilic Wellness Color Palette
  static const Color warmLimestone = Color(0xFFF2F0E6); // Background
  static const Color deepTeal = Color(0xFF1F4E5F);     // Primary
  static const Color mutedSage = Color(0xFF8FA998);    // Secondary
  static const Color charcoalBody = Color(0xFF2C2C2C); // Body Text
  static const Color darkForest = Color(0xFF1A3A3A);   // Heading Text

  static ThemeData get earthyTheme {
    return ThemeData(
      primaryColor: deepTeal,
      scaffoldBackgroundColor: warmLimestone,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false, // Align left for high-end feel
        titleTextStyle: TextStyle(
          color: darkForest,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Serif',
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: darkForest, size: 24),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepTeal,
        primary: deepTeal,
        secondary: mutedSage,
        surface: Colors.white.withOpacity(0.5),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Serif',
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: darkForest,
          letterSpacing: -1.0,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Serif',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: darkForest,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Sans-Serif',
          fontSize: 17,
          color: charcoalBody,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Sans-Serif',
          fontSize: 15,
          color: charcoalBody,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepTeal,
          foregroundColor: warmLimestone,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Sans-Serif',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
        ),
      ),
    );
  }

  // Glassmorphism Utility
  static BoxDecoration glassDecoration({double opacity = 0.4, double blur = 20.0, double radius = 28.0}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(opacity + 0.2), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: blur,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
