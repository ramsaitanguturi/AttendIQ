import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme Colors (Primary Aesthetic)
  static const Color darkBackground = Color(0xFF111113); // hsl(240, 10%, 8%)
  static const Color darkSurface = Color(0xFF1B1B1F);    // hsl(240, 8%, 14%)
  static const Color darkSurfaceGlass = Color(0xB31B1B1F); // hsla(240, 8%, 14%, 0.7)
  static const Color darkBorder = Color(0xFF373740);     // hsl(240, 6%, 22%)
  
  static const Color darkTextPrimary = Color(0xFFF2F2F2);   // hsl(0, 0%, 95%)
  static const Color darkTextSecondary = Color(0xFFA0A0A5); // hsl(240, 4%, 65%)

  // Light Theme Colors (Counterpart)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceGlass = Color(0xB3FFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  
  static const Color lightTextPrimary = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF718096);

  // Common/Semantic Core Colors
  static const Color primary = Color(0xFF00E599);        // hsl(160, 100%, 45%) - Emerald
  static const Color primaryGlow = Color(0x2600E599);    // hsla(160, 100%, 45%, 0.15)
  static const Color secondary = Color(0xFF00BFFF);      // hsl(195, 100%, 50%) - Cyan

  // Semantic Status Colors
  static const Color attendanceHigh = Color(0xFF14A35B); // hsl(150, 80%, 40%) - Safe
  static const Color attendanceMid = Color(0xFFF59E0B);  // hsl(38, 90%, 50%) - Warning
  static const Color attendanceLow = Color(0xFFEF4444);  // hsl(0, 85%, 55%) - Danger
}
