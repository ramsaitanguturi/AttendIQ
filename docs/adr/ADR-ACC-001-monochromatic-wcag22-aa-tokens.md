# ADR-ACC-001: Monochromatic Design System WCAG 2.2 Level AA Tokens & Contrast Architecture

## Status
**Accepted**

## Context
ACEDRA employs a strict 9-shade monochromatic silver-and-black palette (`#F8F9FA` through `#212529`) with optional smoked and frosted optical glass effects. The application supports Dark Mode and Light Mode, with Glass ON and Glass OFF.

An initial accessibility audit revealed critical WCAG 2.2 Level AA contrast failures:
- **Light Mode Complete Invisibility (1.0:1 Contrast)**: `AppColors.primary` was hardcoded to `gray100` (`#F8F9FA`). In Light Mode where the background and card surfaces are `gray100`, Floating Action Buttons, TextButtons, TabBar active indicators, and status metrics rendered white-on-white.
- **Glass Inversion Blunders (1.33:1 Contrast)**: Dialogs and bottom sheets hardcoded dark smoked glass (`#212529` / `#343A40` opacities) when Glass was enabled, even under Light Mode, rendering pitch-black text on dark glass.
- **Border and Non-Text Invisibility**: `lightBorder` (`gray400`) on `gray100` yields 1.42:1; `darkBorder` (`gray700`) on `gray800` yields 1.43:1 (violating SC 1.4.11 which requires $\ge 3.0:1$).
- **`gray600` Contrast Trap**: Used extensively for disabled text, low attendance, and muted text, `gray600` achieves only 2.51:1 on dark cards and 4.43:1 on light surfaces (failing SC 1.4.3 normal text 4.5:1 in both modes).

## Decision

We establish an immutable architecture for semantic tokens and glass rendering:

1. **Dynamic Polarity for Primary Action Tokens**:
   - `AppColors.primaryColor(isDark)`: resolves to `gray100` (`#F8F9FA`) in Dark Mode and `gray900` (`#212529`) in Light Mode.
   - `AppColors.onPrimaryColor(isDark)`: resolves to `gray900` in Dark Mode and `gray100` in Light Mode.
   - Hardcoded static references to `AppColors.primary` in widget styling are prohibited; widgets must use theme-aware color scheme tokens.

2. **Re-anchoring Non-Text Boundaries (SC 1.4.11 $\ge 3.0:1$)**:
   - `lightBorder` is updated from `gray400` to `gray600` (4.43:1 on `gray100`) for structural borders and input outlines.
   - `darkBorder` is updated from `gray700` to `gray500` (5.65:1 on `gray800`) for card and control boundaries.

3. **Elevating Muted Text to Level AA**:
   - `lightTextMuted` is upgraded from `gray600` (4.43:1 fail) to `gray700` (7.75:1 AAA pass).
   - `darkTextMuted` is upgraded from `gray500` (3.94:1 on elevated) to `gray400` (7.81:1 on cards, 5.45:1 on elevated).

4. **Symmetrical Glass Polarity**:
   - All glass components must query `isDark` and select `GlassTokens.smokedGlassSurface` (`#343A40` @ 85%) for Dark Mode or `GlassTokens.lightGlassSurface` (`#F8F9FA` @ 93%) for Light Mode.
   - Minimum glass opacity is enforced at 82% (dark) and 90% (light) with blur $\sigma \ge 14.0$ and a high-contrast specular rim stroke.

5. **Dual-Encoding for Semantic States (SC 1.4.1)**:
   - State (Safe, Warning, Critical, Present, Absent, Cancelled) cannot be represented by grayscale tone alone. Every status badge must pair high-contrast text, explicit icons (`check_circle`, `warning_amber`, `error_outline`, `block`), and distinctive shapes/borders.

## Technical Specifications

### Semantic Token Map

```dart
class AppColors {
  // Official 9-color Monochromatic Palette
  static const Color gray100 = Color(0xFFF8F9FA);
  static const Color gray200 = Color(0xFFE9ECEF);
  static const Color gray300 = Color(0xFFDEE2E6);
  static const Color gray400 = Color(0xFFCED4DA);
  static const Color gray500 = Color(0xFFADB5BD);
  static const Color gray600 = Color(0xFF6C757D);
  static const Color gray700 = Color(0xFF495057);
  static const Color gray800 = Color(0xFF343A40);
  static const Color gray900 = Color(0xFF212529);

  // Dynamic Semantic Accessors
  static Color textPrimary(bool isDark) => isDark ? gray100 : gray900;
  static Color textSecondary(bool isDark) => isDark ? gray300 : gray700;
  static Color textMuted(bool isDark) => isDark ? gray400 : gray700;
  static Color textDisabled(bool isDark) => isDark ? gray600 : gray500;
  static Color textHint(bool isDark) => isDark ? gray400 : gray700;
  static Color textOnElevatedSurface(bool isDark) => isDark ? gray100 : gray900;
  static Color textOnGlass(bool isDark) => isDark ? gray100 : gray900;
  static Color iconPrimary(bool isDark) => isDark ? gray200 : gray900;
  static Color iconSecondary(bool isDark) => isDark ? gray400 : gray700;
  static Color primaryAction(bool isDark) => isDark ? gray100 : gray900;
  static Color onPrimaryAction(bool isDark) => isDark ? gray900 : gray100;
  static Color borderStrong(bool isDark) => isDark ? gray500 : gray600;
}
```

## Consequences

- **Positive**: Eliminates all white-on-white and black-on-black UI bugs; brings the entire app into 100% compliance with WCAG 2.2 Level AA without breaking the strict 9-color monochromatic luxury aesthetic.
- **Positive**: Low-vision users and users in direct daylight can read all text, discern form input boundaries, and distinguish attendance states.
- **Maintenance**: Developers must never hardcode `AppColors.primary` or static grayscale tokens in widget styling; all color lookups must pass through dynamic semantic helpers or `Theme.of(context)`.
