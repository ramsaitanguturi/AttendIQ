import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Smoked Glass Theme Colors (Primary Aesthetic)
  static const Color darkBackground = Color(0xFF0D0D11); // Deep obsidian background
  static const Color darkSurface = Color(0xFF16161C); // Smoked glass surface
  static const Color darkSurfaceGlass = Color(0xDE16161C); // 87% opacity smoked glass
  static const Color darkBorder = Color(0xFF282832); // Subtle charcoal border
  static const Color darkCard = Color(0xFF191922);

  static const Color darkTextPrimary = Color(0xFFF5F5F7); // High contrast silver white
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Cool metallic silver grey

  // Silver Reflection Highlights & Borders
  static const Color silverReflect = Color(0xFFE2E8F0); // Polished silver highlight
  static const Color silverBorder = Color(0x33E2E8F0); // Translucent silver edge (20%)
  static const Color silverBorderSubtle = Color(0x1AE2E8F0); // Subtle silver stroke (10%)
  static const Color silverBorderGlow = Color(0x4DE2E8F0); // Elevated silver reflection

  // Light Theme Colors (Counterpart)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceGlass = Color(0xB3FFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color lightTextPrimary = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF718096);

  // Common/Semantic Core Colors
  static const Color primary = Color(0xFF00E599); // Emerald
  static const Color primaryGlow = Color(0x2600E599);
  static const Color secondary = Color(0xFF00BFFF); // Cyan

  // Semantic Status Colors
  static const Color attendanceHigh = Color(0xFF14A35B); // Safe (>= 75%)
  static const Color attendanceMid = Color(0xFFF59E0B); // Warning (near 75%)
  static const Color attendanceLow = Color(0xFFEF4444); // Danger (< 75%)
  static const Color statusCancelled = Color(0xFF6B7280); // Neutral grey

  /// Factory helper to build uniform Dark Smoked Glass container decorations
  /// with subtle silver border reflection and soft depth shadows.
  static BoxDecoration smokedGlassDecoration({
    bool isDark = true,
    double borderRadius = 16.0,
    Color? borderColor,
    double borderWidth = 1.0,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ??
          (isDark ? const Color(0xDE16161E) : const Color(0xFFFFFFFF)),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ??
            (isDark ? const Color(0x2EE2E8F0) : const Color(0x1F000000)),
        width: borderWidth,
      ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFFE2E8F0).withOpacity(0.04),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
    );
  }
}
