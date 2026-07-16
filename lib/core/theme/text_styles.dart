import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // Font family names as defined in design system
  static const String primaryFont = 'Outfit';
  static const String fallbackFont = 'Inter';

  // Base TextStyle definitions
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fallbackFont,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fallbackFont,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );
}
