import 'package:flutter/material.dart';

/// Centralized Monochromatic Design System Color Tokens for ACEDRA.
///
/// The design system strictly uses the official 9-color monochromatic palette:
/// #f8f9fa, #e9ecef, #dee2e6, #ced4da, #adb5bd, #6c757d, #495057, #343a40, #212529.
///
/// Opacity variations of these nine colors are permitted for glass effects,
/// overlays, shadows, and reflections.
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. Official ACEDRA Monochromatic Palette (The 9 Approved Hex Colors)
  // ===========================================================================
  static const Color gray100 =
      Color(0xFFF8F9FA); // #f8f9fa - Near-white / luminous crest
  static const Color gray200 =
      Color(0xFFE9ECEF); // #e9ecef - Light silver highlight
  static const Color gray300 =
      Color(0xFFDEE2E6); // #dee2e6 - Primary icons & specular rim
  static const Color gray400 =
      Color(0xFFCED4DA); // #ced4da - Secondary text & accents
  static const Color gray500 =
      Color(0xFFADB5BD); // #adb5bd - Mid-tone silver & warnings
  static const Color gray600 =
      Color(0xFF6C757D); // #6c757d - Disabled text & slate tone
  static const Color gray700 =
      Color(0xFF495057); // #495057 - Elevated cards & borders
  static const Color gray800 =
      Color(0xFF343A40); // #343a40 - Standard cards & secondary bg
  static const Color gray900 =
      Color(0xFF212529); // #212529 - Main background & pitch base

  // The authoritative 9-shade palette as an immutable list
  static const List<Color> palette = [
    gray100,
    gray200,
    gray300,
    gray400,
    gray500,
    gray600,
    gray700,
    gray800,
    gray900,
  ];

  // Hex string equivalents for dialogs and selectors
  static const List<String> paletteHex = [
    '#F8F9FA',
    '#E9ECEF',
    '#DEE2E6',
    '#CED4DA',
    '#ADB5BD',
    '#6C757D',
    '#495057',
    '#343A40',
    '#212529',
  ];

  // ===========================================================================
  // 2. Default Dark Monochromatic Theme Assignments
  // ===========================================================================
  static const Color darkBackground = gray900; // #212529 - Main background
  static const Color darkSecondaryBackground =
      gray800; // #343a40 - Secondary background
  static const Color darkSurface = gray800; // #343a40 - Standard cards
  static const Color darkSurfaceGlass =
      Color(0xD9343A40); // Translucent smoked glass surface
  static const Color darkCard = gray800; // #343a40 - Standard card surface
  static const Color darkElevated = gray700; // #495057 - Elevated cards
  static const Color darkBorder = gray700; // #495057 - Perimeter borders
  static const Color darkBorderSubtle = Color(0x38495057); // Subtle border

  // Typography tokens (Dark default - strictly WCAG 2.2 AA compliant)
  static const Color darkTextPrimary =
      gray100; // #f8f9fa - Primary headings (10.9:1 on gray800, 7.76:1 on gray700)
  static const Color darkTextSecondary =
      gray400; // #ced4da - Secondary text (7.70:1 on gray800, 5.47:1 on gray700)
  static const Color darkTextMuted =
      gray500; // #adb5bd - Muted descriptions (5.55:1 on gray800)
  static const Color darkTextDisabled =
      gray500; // #adb5bd - Disabled text (5.55:1 on gray800)
  static const Color darkTextHint =
      gray400; // #ced4da - Input hints (7.70:1 on gray800)
  static const Color darkTextOnElevatedSurface =
      gray100; // #f8f9fa - Text on elevated cards (7.76:1 on gray700)
  static const Color darkTextOnGlass =
      gray100; // #f8f9fa - Text on smoked glass (10.9:1 on glass)

  // Icon tokens
  static const Color darkIconPrimary =
      gray100; // #f8f9fa - Primary icons (10.9:1 on gray800)
  static const Color darkIconSecondary =
      gray300; // #dee2e6 - Secondary icons (8.84:1 on gray800, 6.28:1 on gray700)

  // Navigation tokens
  static const Color navIndicator =
      gray100; // #f8f9fa - Selected navigation indicator
  static const Color navSelectedIcon =
      gray900; // #212529 - Selected navigation icon
  static const Color navUnselectedIcon = Color(0x80DEE2E6); // Muted silver

  // Reflections & Specular Highlights
  static const Color silverReflect = gray300; // #dee2e6
  static const Color silverBorder =
      Color(0x38DEE2E6); // Translucent silver edge
  static const Color silverBorderSubtle =
      Color(0x1FDEE2E6); // Subtle silver stroke
  static const Color silverBorderGlow =
      Color(0x4DF8F9FA); // Elevated reflection

  // ===========================================================================
  // 3. Common / Semantic Action Tokens
  // ===========================================================================
  static const Color primary = gray100; // #f8f9fa - Crisp near-white
  static const Color primaryGlow = Color(0x26F8F9FA); // Soft near-white glow
  static const Color onPrimary =
      gray900; // #212529 - High-contrast text on primary
  static const Color secondary = gray300; // #dee2e6 - Light silver
  static const Color accent = gray400; // #ced4da - Muted silver

  // Semantic Status Tones (Static dark defaults)
  static const Color attendanceHigh = gray100; // #f8f9fa - Safe / High (>= 75%)
  static const Color attendanceMid =
      gray300; // #dee2e6 - Warning (~75%, 8.84:1 on dark)
  static const Color attendanceLow =
      gray400; // #ced4da - Danger (< 75%, 7.70:1 on dark)

  // Occurrence states (Static dark defaults)
  static const Color present = gray100; // #f8f9fa
  static const Color late = gray300; // #dee2e6
  static const Color absent = gray400; // #ced4da
  static const Color cancelled = gray400; // #ced4da
  static const Color statusCancelled =
      gray400; // #ced4da - Static cancelled status token
  static const Color extraClass = gray200; // #e9ecef

  // ===========================================================================
  // 4. Light Theme Counterparts (Consistent Monochromatic, WCAG AA Compliant)
  // ===========================================================================
  static const Color lightBackground = gray100; // #f8f9fa - Main background
  static const Color lightSecondaryBackground =
      gray200; // #e9ecef - Secondary background
  static const Color lightSurface = gray100; // #f8f9fa - Standard surfaces
  static const Color lightSurfaceGlass = Color(
      0xF2F8F9FA); // Translucent light glass surface (95% opaque for contrast)
  static const Color lightCard = gray100; // #f8f9fa - Standard cards
  static const Color lightElevated = gray200; // #e9ecef - Elevated surfaces
  static const Color lightBorder = gray400; // #ced4da - Borders
  static const Color lightBorderSubtle = Color(0x38CED4DA); // Subtle border
  static const Color lightTextPrimary =
      gray900; // #212529 - Primary text (14.6:1 on gray100)
  static const Color lightTextSecondary =
      gray700; // #495057 - Secondary text (7.76:1 on gray100, 6.90:1 on gray200)
  static const Color lightTextMuted =
      gray700; // #495057 - Muted text (7.76:1 on gray100, 6.90:1 on gray200)
  static const Color lightTextDisabled =
      gray600; // #6c757d - Disabled text (4.45:1 on gray100)
  static const Color lightTextHint =
      gray700; // #495057 - Input hints (6.90:1 on gray200)
  static const Color lightTextOnElevatedSurface =
      gray900; // #212529 - Text on elevated cards (13.0:1 on gray200)
  static const Color lightTextOnGlass =
      gray900; // #212529 - Text on light glass (14.6:1 on glass)
  static const Color lightIconPrimary =
      gray900; // #212529 - Primary icons (14.6:1 on gray100)
  static const Color lightIconSecondary =
      gray700; // #495057 - Secondary icons (7.76:1 on gray100)

  // Light Navigation tokens
  static const Color lightNavIndicator = gray900; // #212529 - Selected pill
  static const Color lightNavSelectedIcon = gray100; // #f8f9fa - Selected icon
  static const Color lightNavUnselectedIcon =
      gray700; // #495057 - Unselected icon (7.76:1)

  // Dynamic Semantic Accessors
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color secondaryBackground(bool isDark) =>
      isDark ? darkSecondaryBackground : lightSecondaryBackground;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceGlass(bool isDark) =>
      isDark ? darkSurfaceGlass : lightSurfaceGlass;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color elevated(bool isDark) => isDark ? darkElevated : lightElevated;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMuted(bool isDark) =>
      isDark ? darkTextMuted : lightTextMuted;
  static Color textDisabled(bool isDark) =>
      isDark ? darkTextDisabled : lightTextDisabled;
  static Color textHint(bool isDark) => isDark ? darkTextHint : lightTextHint;
  static Color textOnElevatedSurface(bool isDark) =>
      isDark ? darkTextOnElevatedSurface : lightTextOnElevatedSurface;
  static Color textOnGlass(bool isDark) =>
      isDark ? darkTextOnGlass : lightTextOnGlass;
  static Color iconPrimary(bool isDark) =>
      isDark ? darkIconPrimary : lightIconPrimary;
  static Color iconSecondary(bool isDark) =>
      isDark ? darkIconSecondary : lightIconSecondary;
  static Color primaryColor(bool isDark) => isDark ? primary : gray900;

  // Adaptive Attendance & Occurrence Status Colors (Inverted for guaranteed contrast)
  static Color statusPresent(bool isDark) => isDark ? gray100 : gray900;
  static Color statusLate(bool isDark) => isDark ? gray300 : gray700;
  static Color statusAbsent(bool isDark) => isDark ? gray400 : gray800;
  static Color statusCancelledAdaptive(bool isDark) =>
      isDark ? gray400 : gray700;
  static Color statusExtra(bool isDark) => isDark ? gray200 : gray800;

  /// Resolves an attendance percentage into a WCAG-compliant status color.
  static Color attendanceMetricColor(double percentage, bool isDark) {
    if (percentage >= 75.0) {
      return isDark ? gray100 : gray900;
    } else if (percentage >= 65.0) {
      return isDark ? gray300 : gray700;
    } else {
      return isDark ? gray400 : gray800;
    }
  }

  // ===========================================================================
  // 5. Normalization & Mapping Utilities
  // ===========================================================================

  /// Maps any arbitrary or legacy color into the nearest approved 9-shade monochromatic tone.
  static Color normalizeToMonochrome(Color color) {
    final lum = color.computeLuminance();
    if (lum >= 0.90) return gray100;
    if (lum >= 0.75) return gray200;
    if (lum >= 0.60) return gray300;
    if (lum >= 0.45) return gray400;
    if (lum >= 0.30) return gray500;
    if (lum >= 0.18) return gray600;
    if (lum >= 0.10) return gray700;
    if (lum >= 0.04) return gray800;
    return gray900;
  }

  /// Parses a hex color string and returns an approved monochromatic palette color.
  static Color parseMonochromeHex(String? hex, [Color fallback = gray300]) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      var h = hex.replaceAll('#', '');
      if (h.length == 6) h = 'FF$h';
      final parsed = Color(int.parse(h, radix: 16));
      return normalizeToMonochrome(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// Provides distinct approved monochromatic tones for different subjects or categories.
  static Color subjectShade(int index) {
    const shades = [
      gray300, // #dee2e6
      gray400, // #ced4da
      gray200, // #e9ecef
      gray500, // #adb5bd
      gray100, // #f8f9fa
      gray600, // #6c757d
    ];
    return shades[index.abs() % shades.length];
  }

  /// Uniform dark smoked-glass container decoration using strictly monochromatic tokens.
  static BoxDecoration smokedGlassDecoration({
    bool isDark = true,
    double borderRadius = 16.0,
    Color? borderColor,
    double borderWidth = 1.0,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ??
          (isDark ? const Color(0xD9343A40) : const Color(0xD9F8F9FA)),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ??
            (isDark ? const Color(0x38DEE2E6) : const Color(0x38CED4DA)),
        width: borderWidth,
      ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: gray100.withOpacity(0.04),
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
