import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RemediTheme - Quiet Luxury Design System
/// Implements the "Quiet Luxury" aesthetic with clinical calm and premium feel
class RemediTheme {
  // ═══════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - Quiet Luxury
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Primary Color: Deep Teal - Represents trust and wellness
  static const Color deepTeal = Color(0xFF1F4E5F);
  
  /// Background: Cashmere - Main Lux Background
  static const Color cashmere = Color(0xFFF4EDE3);

  /// Surface: Warm Limestone - Secondary/Card Background
  static const Color warmLimestone = Color(0xFFF2F0E6);
  
  /// Accent: Muted Sage - Calming secondary color
  static const Color mutedSage = Color(0xFF8FA998);
  
  /// Action: Ember Gold - Primary highlight for "Quiet Luxury"
  static const Color emberGold = Color(0xFFD4A373);
  
  /// Safety: Critical Red - For warnings and alerts
  static const Color safetyCritical = Color(0xFF90353D);
  static const Color garnet = safetyCritical;
  
  /// Text: Charcoal - Body text color
  static const Color charcoal = Color(0xFF2C2C2C);
  
  /// Text: Dark Forest - Heading text color
  static const Color darkForest = Color(0xFF1A3A3A);

  // ═══════════════════════════════════════════════════════════════════════
  // SPACING TOKENS
  // ═══════════════════════════════════════════════════════════════════════
  
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ═══════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════════════
  
  static const double radiusStone = 22.0;
  static const double radiusGlass = 20.0;
  static const double radiusButton = 16.0;

  // ═══════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════════════
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Transparent to allow SanctuaryBackground to show through
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: deepTeal,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepTeal,
        primary: deepTeal,
        secondary: mutedSage,
        error: safetyCritical,
        surface: warmLimestone.withOpacity(0.5),
        brightness: Brightness.light,
      ),
      
      // Typography - Serif for headings, Sans for body
      textTheme: TextTheme(
        // Headings - Lora (Serif)
        displayLarge: GoogleFonts.lora(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: darkForest,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkForest,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.lora(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: darkForest,
          letterSpacing: -0.2,
        ),
        headlineMedium: GoogleFonts.lora(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkForest,
        ),
        headlineSmall: GoogleFonts.lora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkForest,
        ),
        
        // Body - Inter (Geometric Sans)
        bodyLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: charcoal,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: charcoal,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: charcoal,
          height: 1.3,
        ),
        
        // Labels - Inter
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: charcoal,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: charcoal,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: charcoal,
          letterSpacing: 0.2,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4A373), // Ember Gold
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.6),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusStone),
          side: BorderSide(
            color: Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lora(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: darkForest,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: darkForest,
          size: 24,
        ),
      ),
    );
  }
}

/// RemediDecorations - Surface Styles for Quiet Luxury
/// Provides Stone and Glass decoration styles
class RemediDecorations {
  // ═══════════════════════════════════════════════════════════════════════
  // STONE SURFACE - Solid, Grounded, Trustworthy
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Stone decoration with soft shadow
  /// Use for: Cards, Containers, Primary surfaces
  static BoxDecoration stone({
    Color? color,
    double borderRadius = RemediTheme.radiusStone,
    double shadowOpacity = 0.05,
    double shadowBlur = 12.0,
    double shadowSpread = 0.0,
    Offset shadowOffset = const Offset(0, 4),
  }) {
    return BoxDecoration(
      color: color ?? RemediTheme.warmLimestone,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(shadowOpacity),
          blurRadius: shadowBlur,
          spreadRadius: shadowSpread,
          offset: shadowOffset,
        ),
      ],
    );
  }
  
  /// Stone decoration with border
  /// Use for: Interactive elements, Outlined containers
  static BoxDecoration stoneBordered({
    Color? color,
    Color? borderColor,
    double borderWidth = 1.5,
    double borderRadius = RemediTheme.radiusStone,
    double shadowOpacity = 0.03,
  }) {
    return BoxDecoration(
      color: color ?? RemediTheme.warmLimestone,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.8),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(shadowOpacity),
          blurRadius: 8.0,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GLASS SURFACE - Translucent, Modern, Layered
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Glass decoration with backdrop blur
  /// Use for: Overlays, Modals, Floating elements
  /// Note: Must be wrapped in BackdropFilter for blur effect
  static BoxDecoration glass({
    double opacity = 0.1,
    double borderRadius = RemediTheme.radiusGlass,
    Color? tintColor,
    double borderOpacity = 0.2,
  }) {
    return BoxDecoration(
      color: (tintColor ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20.0,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  /// Complete glass widget with BackdropFilter
  /// Use this for ready-to-use glass containers
  static Widget glassContainer({
    required Widget child,
    double blur = 15.0,
    double opacity = 0.1,
    double borderRadius = RemediTheme.radiusGlass,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      decoration: glass(
        opacity: opacity,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(RemediTheme.spaceMD),
            child: child,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SPECIALTY DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════
  
  /// Elevated stone - for buttons and interactive elements
  static BoxDecoration stoneElevated({
    Color? color,
    double borderRadius = RemediTheme.radiusButton,
  }) {
    return BoxDecoration(
      color: color ?? RemediTheme.deepTeal,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: (color ?? RemediTheme.deepTeal).withOpacity(0.2),
          blurRadius: 16.0,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
  
  /// Soft glow - for focus states and highlights
  static BoxDecoration softGlow({
    required Color glowColor,
    double borderRadius = RemediTheme.radiusStone,
    double glowOpacity = 0.15,
    double glowBlur = 24.0,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(glowOpacity),
          blurRadius: glowBlur,
          spreadRadius: 4.0,
        ),
      ],
    );
  }
}
