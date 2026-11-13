import 'package:flutter/material.dart';

/// Centralized tokens for ACEDRA's Dark Smoked Glass & Silver Reflection Design System.
class GlassTokens {
  GlassTokens._();

  // Controlled blur sigma suitable for ordinary Android devices (low GPU overhead)
  static const double blurSigma = 12.0;
  static const double subtleBlurSigma = 8.0;

  // Smoked Glass Colors
  static const Color smokedGlassBg = Color(0xB80E1118);
  static const Color smokedGlassSurface = Color(0xD9141824);
  static const Color smokedGlassElevated = Color(0xEA1A202E);
  static const Color smokedGlassSheet = Color(0xF210131C);

  // Silver Reflection Highlights & Borders
  static const Color silverGleam = Color(0xFFE2E8F0);
  static const Color silverBorder = Color(0x38E2E8F0);
  static const Color silverBorderSubtle = Color(0x1FE2E8F0);
  static const Color silverBorderBright = Color(0x5AE2E8F0);

  // Gradient definitions
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xD9181D29), // Smoked dark obsidian with slight metallic tint
      Color(0xB80E121A), // Translucent depth
    ],
  );

  static const LinearGradient elevatedSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEA1E2433),
      Color(0xD9121622),
    ],
  );

  static const LinearGradient borderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x5CE2E8F0), // Top-left specular silver reflection
      Color(0x14E2E8F0), // Bottom-right shadow drop
    ],
  );

  // Shadows
  static List<BoxShadow> cardShadows({bool isGlassy = true}) {
    if (!isGlassy) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: const Color(0xFFE2E8F0).withOpacity(0.03),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static BoxDecoration glassBoxDecoration({
    double borderRadius = 20.0,
    bool isElevated = false,
    Color? customBorderColor,
  }) {
    return BoxDecoration(
      gradient: isElevated ? elevatedSurfaceGradient : surfaceGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: customBorderColor ?? silverBorder,
        width: 1.1,
      ),
      boxShadow: cardShadows(isGlassy: true),
    );
  }
}
