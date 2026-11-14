import 'package:flutter/material.dart';
import '../colors.dart';

/// Centralized tokens for ACEDRA's Smoked Glass & Silver Reflection Design System.
///
/// Built strictly from the official 9-color monochromatic palette:
/// #f8f9fa, #e9ecef, #dee2e6, #ced4da, #adb5bd, #6c757d, #495057, #343a40, #212529.
class GlassTokens {
  GlassTokens._();

  // Controlled blur sigma suitable for ordinary Android devices (low GPU overhead)
  static const double blurSigma = 12.0;
  static const double subtleBlurSigma = 8.0;

  // Smoked Glass Surfaces (Dark mode: Strictly #212529, #343a40, #495057 with reinforced opacity for text contrast)
  static const Color smokedGlassBg = Color(0xF2212529); // #212529 @ 95%
  static const Color smokedGlassSurface = Color(0xF0343A40); // #343a40 @ 94%
  static const Color smokedGlassElevated = Color(0xF5495057); // #495057 @ 96%
  static const Color smokedGlassSheet = Color(0xF8212529); // #212529 @ 97%

  // Light Glass Surfaces (Light mode: Strictly #f8f9fa, #e9ecef with reinforced opacity for text contrast)
  static const Color lightGlassBg = Color(0xF2F8F9FA); // #f8f9fa @ 95%
  static const Color lightGlassSurface = Color(0xF2F8F9FA); // #f8f9fa @ 95%
  static const Color lightGlassElevated = Color(0xF5E9ECEF); // #e9ecef @ 96%
  static const Color lightGlassSheet = Color(0xF8F8F9FA); // #f8f9fa @ 97%

  // Silver Reflection Highlights & Borders (Strictly #f8f9fa, #dee2e6, #ced4da opacities)
  static const Color silverGleam = AppColors.gray100; // #f8f9fa
  static const Color silverBorder = Color(0x38DEE2E6); // #dee2e6 @ 22%
  static const Color silverBorderSubtle = Color(0x1FDEE2E6); // #dee2e6 @ 12%
  static const Color silverBorderBright = Color(0x5AF8F9FA); // #f8f9fa @ 35%

  // Light Glass Borders
  static const Color lightGlassBorder = Color(0x50CED4DA); // #ced4da @ 31%
  static const Color lightGlassBorderSubtle =
      Color(0x28CED4DA); // #ced4da @ 16%
  static const Color lightGlassBorderBright =
      Color(0x80CED4DA); // #ced4da @ 50%

  // Grayscale Gradients (Dark - High opacity backing for crisp typography)
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF5343A40), // Smoked gray800 @ 96%
      Color(0xEA212529), // Translucent depth gray900 @ 92%
    ],
  );

  static const LinearGradient elevatedSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF5495057), // Elevated gray700 @ 96%
      Color(0xEA343A40), // Grounded gray800 @ 92%
    ],
  );

  // Grayscale Gradients (Light - High opacity backing for crisp typography)
  static const LinearGradient lightSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF8F8F9FA), // Luminous near-white gray100 @ 97%
      Color(0xEFE9ECEF), // Translucent light silver gray200 @ 94%
    ],
  );

  static const LinearGradient lightElevatedSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF5E9ECEF), // Elevated light silver gray200 @ 96%
      Color(0xEADEE2E6), // Grounded silver gray300 @ 92%
    ],
  );

  static const LinearGradient borderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x5CF8F9FA), // Top-left specular near-white reflection
      Color(0x14F8F9FA), // Bottom-right shadow drop
    ],
  );

  // Shadows
  static List<BoxShadow> cardShadows({
    bool isGlassy = true,
    bool isDark = true,
  }) {
    if (!isGlassy) {
      return isDark
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ];
    }
    return isDark
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.gray100.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.gray400.withOpacity(0.12),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ];
  }

  static BoxDecoration glassBoxDecoration({
    dynamic borderRadius = 20.0,
    bool isDark = true,
    bool isElevated = false,
    Color? customBorderColor,
    Color? borderColor,
    Color? fillColor,
  }) {
    final BorderRadiusGeometry radius = borderRadius is BorderRadiusGeometry
        ? borderRadius
        : BorderRadius.circular((borderRadius as num).toDouble());

    final defaultBorder = isDark ? silverBorder : lightGlassBorder;
    final gradient = isDark
        ? (isElevated ? elevatedSurfaceGradient : surfaceGradient)
        : (isElevated ? lightElevatedSurfaceGradient : lightSurfaceGradient);

    return BoxDecoration(
      color: fillColor,
      gradient: fillColor != null ? null : gradient,
      borderRadius: radius,
      border: Border.all(
        color: customBorderColor ?? borderColor ?? defaultBorder,
        width: 1.1,
      ),
      boxShadow: cardShadows(isGlassy: true, isDark: isDark),
    );
  }
}
