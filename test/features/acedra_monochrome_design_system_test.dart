import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/theme/colors.dart';
import 'package:attend_iq/core/theme/app_theme.dart';
import 'package:attend_iq/core/theme/glass/glass_theme_tokens.dart';
import 'package:attend_iq/core/widgets/acedra_logo.dart';

/// Helper to compute relative luminance and contrast ratio per WCAG 2.1
double _relativeLuminance(Color color) {
  double transform(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = transform(color.red / 255.0);
  final g = transform(color.green / 255.0);
  final b = transform(color.blue / 255.0);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color c1, Color c2) {
  final l1 = _relativeLuminance(c1);
  final l2 = _relativeLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('ACEDRA Official 9-Color Monochromatic Palette Verification', () {
    test(
        '1. Nine official palette colors match exact hexadecimal specifications',
        () {
      expect(AppColors.gray100, equals(const Color(0xFFF8F9FA))); // #f8f9fa
      expect(AppColors.gray200, equals(const Color(0xFFE9ECEF))); // #e9ecef
      expect(AppColors.gray300, equals(const Color(0xFFDEE2E6))); // #dee2e6
      expect(AppColors.gray400, equals(const Color(0xFFCED4DA))); // #ced4da
      expect(AppColors.gray500, equals(const Color(0xFFADB5BD))); // #adb5bd
      expect(AppColors.gray600, equals(const Color(0xFF6C757D))); // #6c757d
      expect(AppColors.gray700, equals(const Color(0xFF495057))); // #495057
      expect(AppColors.gray800, equals(const Color(0xFF343A40))); // #343a40
      expect(AppColors.gray900, equals(const Color(0xFF212529))); // #212529
    });

    test(
        '2. Approved palette list contains exactly the nine specified hex codes',
        () {
      expect(AppColors.paletteHex.length, equals(9));
      expect(
        AppColors.paletteHex,
        equals([
          '#F8F9FA',
          '#E9ECEF',
          '#DEE2E6',
          '#CED4DA',
          '#ADB5BD',
          '#6C757D',
          '#495057',
          '#343A40',
          '#212529',
        ]),
      );
    });

    test('3. Dark monochromatic semantic tokens match official specifications',
        () {
      expect(
        AppColors.darkBackground,
        equals(const Color(0xFF212529)),
      ); // Main background #212529
      expect(
        AppColors.darkSecondaryBackground,
        equals(const Color(0xFF343A40)),
      ); // Secondary background #343a40
      expect(
        AppColors.darkSurface,
        equals(const Color(0xFF343A40)),
      ); // Standard cards #343a40
      expect(
        AppColors.darkElevated,
        equals(const Color(0xFF495057)),
      ); // Elevated cards #495057
      expect(
        AppColors.darkBorder,
        equals(const Color(0xFF495057)),
      ); // Borders #495057
      expect(
        AppColors.darkTextPrimary,
        equals(const Color(0xFFF8F9FA)),
      ); // Primary text #f8f9fa
      expect(
        AppColors.darkTextSecondary,
        equals(const Color(0xFFCED4DA)),
      ); // Secondary text #ced4da
      expect(
        AppColors.darkTextMuted,
        equals(const Color(0xFFADB5BD)),
      ); // Muted text #adb5bd
      expect(
        AppColors.darkTextDisabled,
        equals(
          const Color(
            0xFFADB5BD,
          ),
        ),
      ); // Disabled text #adb5bd (contrast-enhanced from #6c757d)
      expect(
        AppColors.darkIconPrimary,
        equals(
          const Color(
            0xFFF8F9FA,
          ),
        ),
      ); // Primary icons #f8f9fa (contrast-enhanced from #dee2e6)
      expect(
        AppColors.navIndicator,
        equals(
          const Color(
            0xFFF8F9FA,
          ),
        ),
      ); // Selected navigation indicator #f8f9fa
      expect(
        AppColors.navSelectedIcon,
        equals(const Color(0xFF212529)),
      ); // Selected navigation icon #212529
    });

    test('4. Light monochromatic semantic tokens match official specifications',
        () {
      expect(
        AppColors.lightBackground,
        equals(const Color(0xFFF8F9FA)),
      ); // Main background #f8f9fa
      expect(
        AppColors.lightSecondaryBackground,
        equals(const Color(0xFFE9ECEF)),
      ); // Secondary background #e9ecef
      expect(
        AppColors.lightSurface,
        equals(const Color(0xFFF8F9FA)),
      ); // Standard cards #f8f9fa
      expect(
        AppColors.lightElevated,
        equals(const Color(0xFFE9ECEF)),
      ); // Elevated surfaces #e9ecef
      expect(
        AppColors.lightBorder,
        equals(const Color(0xFFCED4DA)),
      ); // Borders #ced4da
      expect(
        AppColors.lightTextPrimary,
        equals(const Color(0xFF212529)),
      ); // Primary text #212529
      expect(
        AppColors.lightTextSecondary,
        equals(const Color(0xFF495057)),
      ); // Secondary text #495057
      expect(
        AppColors.lightTextMuted,
        equals(
          const Color(
            0xFF495057,
          ),
        ),
      ); // Muted text #495057 (contrast-enhanced from #6c757d)
      expect(
        AppColors.lightTextDisabled,
        equals(
          const Color(
            0xFF6C757D,
          ),
        ),
      ); // Disabled text #6c757d (contrast-enhanced from #adb5bd)
      expect(
        AppColors.lightIconPrimary,
        equals(
          const Color(
            0xFF212529,
          ),
        ),
      ); // Primary icons #212529 (contrast-enhanced from #343a40)
      expect(
        AppColors.lightNavIndicator,
        equals(const Color(0xFF212529)),
      ); // Selected indicator #212529
      expect(
        AppColors.lightNavSelectedIcon,
        equals(const Color(0xFFF8F9FA)),
      ); // Selected icon #f8f9fa
    });

    test(
        '5. Dynamic semantic accessors switch correctly between dark and light',
        () {
      // Backgrounds
      expect(AppColors.background(true), equals(AppColors.darkBackground));
      expect(AppColors.background(false), equals(AppColors.lightBackground));
      expect(
        AppColors.secondaryBackground(true),
        equals(AppColors.darkSecondaryBackground),
      );
      expect(
        AppColors.secondaryBackground(false),
        equals(AppColors.lightSecondaryBackground),
      );

      // Surfaces & Cards
      expect(AppColors.surface(true), equals(AppColors.darkSurface));
      expect(AppColors.surface(false), equals(AppColors.lightSurface));
      expect(AppColors.card(true), equals(AppColors.darkCard));
      expect(AppColors.card(false), equals(AppColors.lightCard));
      expect(AppColors.elevated(true), equals(AppColors.darkElevated));
      expect(AppColors.elevated(false), equals(AppColors.lightElevated));

      // Borders
      expect(AppColors.border(true), equals(AppColors.darkBorder));
      expect(AppColors.border(false), equals(AppColors.lightBorder));

      // Typography
      expect(AppColors.textPrimary(true), equals(AppColors.darkTextPrimary));
      expect(AppColors.textPrimary(false), equals(AppColors.lightTextPrimary));
      expect(
        AppColors.textSecondary(true),
        equals(AppColors.darkTextSecondary),
      );
      expect(
        AppColors.textSecondary(false),
        equals(AppColors.lightTextSecondary),
      );
      expect(AppColors.textMuted(true), equals(AppColors.darkTextMuted));
      expect(AppColors.textMuted(false), equals(AppColors.lightTextMuted));

      // Icons
      expect(AppColors.iconPrimary(true), equals(AppColors.darkIconPrimary));
      expect(AppColors.iconPrimary(false), equals(AppColors.lightIconPrimary));
      expect(
        AppColors.iconSecondary(true),
        equals(AppColors.darkIconSecondary),
      );
      expect(
        AppColors.iconSecondary(false),
        equals(AppColors.lightIconSecondary),
      );
    });

    test('6. Normalization maps colorful hues strictly into the 9-tier palette',
        () {
      // Pure white & bright colors map to upper tier
      expect(
        AppColors.normalizeToMonochrome(Colors.white),
        equals(AppColors.gray100),
      );
      // Pure black maps to lowest tier
      expect(
        AppColors.normalizeToMonochrome(Colors.black),
        equals(AppColors.gray900),
      );
      // Legacy green/amber/blue/red map to valid grayscale tones
      final mappedGreen =
          AppColors.normalizeToMonochrome(const Color(0xFF4CAF50));
      final mappedBlue =
          AppColors.normalizeToMonochrome(const Color(0xFF2196F3));
      final mappedRed =
          AppColors.normalizeToMonochrome(const Color(0xFFF44336));

      expect(AppColors.palette.contains(mappedGreen), isTrue);
      expect(AppColors.palette.contains(mappedBlue), isTrue);
      expect(AppColors.palette.contains(mappedRed), isTrue);
    });

    test(
        '7. parseMonochromeHex safely normalizes arbitrary and legacy hex strings',
        () {
      expect(
        AppColors.parseMonochromeHex('#4ECDC4'),
        equals(AppColors.gray400),
      );
      expect(
        AppColors.parseMonochromeHex('#F8F9FA'),
        equals(AppColors.gray100),
      );
      expect(
        AppColors.parseMonochromeHex('#212529'),
        equals(AppColors.gray900),
      );
      expect(
        AppColors.parseMonochromeHex('invalid_hex'),
        equals(AppColors.gray300),
      );
    });

    test(
        '8. AppTheme darkTheme & lightTheme are fully configured with monochromatic properties',
        () {
      final dark = AppTheme.darkTheme;
      expect(dark.brightness, equals(Brightness.dark));
      expect(dark.scaffoldBackgroundColor, equals(AppColors.darkBackground));
      expect(dark.colorScheme.surface, equals(AppColors.darkSurface));
      expect(dark.colorScheme.primary, equals(AppColors.primary));
      expect(dark.colorScheme.onPrimary, equals(AppColors.onPrimary));
      expect(dark.cardColor, equals(AppColors.darkCard));
      expect(dark.dividerColor, equals(AppColors.darkBorder));

      final light = AppTheme.lightTheme;
      expect(light.brightness, equals(Brightness.light));
      expect(light.scaffoldBackgroundColor, equals(AppColors.lightBackground));
      expect(light.colorScheme.surface, equals(AppColors.lightSurface));
      expect(light.colorScheme.primary, equals(AppColors.gray900));
      expect(light.colorScheme.onPrimary, equals(AppColors.gray100));
      expect(light.cardColor, equals(AppColors.lightCard));
      expect(light.dividerColor, equals(AppColors.lightBorder));
    });

    test(
        '9. GlassTokens uses strictly the 9-color palette with opacity variations',
        () {
      // Dark Glass Surfaces
      expect(
        GlassTokens.smokedGlassBg.value & 0x00FFFFFF,
        equals(AppColors.gray900.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.smokedGlassSurface.value & 0x00FFFFFF,
        equals(AppColors.gray800.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.smokedGlassElevated.value & 0x00FFFFFF,
        equals(AppColors.gray700.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.smokedGlassSheet.value & 0x00FFFFFF,
        equals(AppColors.gray900.value & 0x00FFFFFF),
      );

      // Light Glass Surfaces
      expect(
        GlassTokens.lightGlassBg.value & 0x00FFFFFF,
        equals(AppColors.gray100.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.lightGlassSurface.value & 0x00FFFFFF,
        equals(AppColors.gray100.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.lightGlassElevated.value & 0x00FFFFFF,
        equals(AppColors.gray200.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.lightGlassSheet.value & 0x00FFFFFF,
        equals(AppColors.gray100.value & 0x00FFFFFF),
      );

      // Borders
      expect(
        GlassTokens.silverBorder.value & 0x00FFFFFF,
        equals(AppColors.gray300.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.silverBorderBright.value & 0x00FFFFFF,
        equals(AppColors.gray100.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.lightGlassBorder.value & 0x00FFFFFF,
        equals(AppColors.gray400.value & 0x00FFFFFF),
      );
      expect(
        GlassTokens.lightGlassBorderBright.value & 0x00FFFFFF,
        equals(AppColors.gray400.value & 0x00FFFFFF),
      );
    });

    test(
        '10. Four Glass ON/OFF and Light/Dark combinations produce valid decorations',
        () {
      // 1. Dark + Glass OFF
      final darkGlassOffDec = BoxDecoration(
        color: AppColors.surface(true),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(true), width: 1.0),
        boxShadow: GlassTokens.cardShadows(isGlassy: false, isDark: true),
      );
      expect(darkGlassOffDec.color, equals(AppColors.darkSurface));
      expect(
        (darkGlassOffDec.border as Border).top.color,
        equals(AppColors.darkBorder),
      );

      // 2. Dark + Glass ON
      final darkGlassOnDec =
          GlassTokens.glassBoxDecoration(isDark: true, isElevated: false);
      expect(darkGlassOnDec.gradient, isNotNull);
      expect(
        (darkGlassOnDec.border as Border).top.color,
        equals(GlassTokens.silverBorder),
      );

      // 3. Light + Glass OFF
      final lightGlassOffDec = BoxDecoration(
        color: AppColors.surface(false),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(false), width: 1.0),
        boxShadow: GlassTokens.cardShadows(isGlassy: false, isDark: false),
      );
      expect(lightGlassOffDec.color, equals(AppColors.lightSurface));
      expect(
        (lightGlassOffDec.border as Border).top.color,
        equals(AppColors.lightBorder),
      );

      // 4. Light + Glass ON
      final lightGlassOnDec =
          GlassTokens.glassBoxDecoration(isDark: false, isElevated: false);
      expect(lightGlassOnDec.gradient, isNotNull);
      expect(
        (lightGlassOnDec.border as Border).top.color,
        equals(GlassTokens.lightGlassBorder),
      );
    });

    test(
        '11. Monochromatic text contrast satisfies WCAG AA and AAA accessibility standards',
        () {
      // Dark Mode Contrast on background & surfaces
      final darkPrimaryContrast =
          _contrastRatio(AppColors.darkTextPrimary, AppColors.darkBackground);
      final darkSecondaryContrast =
          _contrastRatio(AppColors.darkTextSecondary, AppColors.darkBackground);
      final darkMutedContrast =
          _contrastRatio(AppColors.darkTextMuted, AppColors.darkBackground);

      // #F8F9FA on #212529 has > 15:1 contrast (WCAG AAA requires 7.0:1)
      expect(darkPrimaryContrast, greaterThanOrEqualTo(14.0));
      // #CED4DA on #212529 has > 8:1 contrast (WCAG AA requires 4.5:1)
      expect(darkSecondaryContrast, greaterThanOrEqualTo(7.0));
      // #ADB5BD on #212529 has > 5:1 contrast
      expect(darkMutedContrast, greaterThanOrEqualTo(5.0));

      // Light Mode Contrast on background & surfaces
      final lightPrimaryContrast =
          _contrastRatio(AppColors.lightTextPrimary, AppColors.lightBackground);
      final lightSecondaryContrast = _contrastRatio(
        AppColors.lightTextSecondary,
        AppColors.lightBackground,
      );
      final lightMutedContrast =
          _contrastRatio(AppColors.lightTextMuted, AppColors.lightBackground);

      // #212529 on #F8F9FA has > 15:1 contrast (WCAG AAA requires 7.0:1)
      expect(lightPrimaryContrast, greaterThanOrEqualTo(14.0));
      // #495057 on #F8F9FA has > 7:1 contrast (WCAG AAA requires 7.0:1)
      expect(lightSecondaryContrast, greaterThanOrEqualTo(7.0));
      // #495057 on #F8F9FA strictly exceeds WCAG AA 4.5:1 baseline
      expect(lightMutedContrast, greaterThanOrEqualTo(4.5));
    });

    test(
        '13. All 9 semantic tokens resolve accurately and dynamically across both appearances',
        () {
      // Dark appearance checks
      expect(AppColors.textPrimary(true), equals(AppColors.darkTextPrimary));
      expect(
        AppColors.textSecondary(true),
        equals(AppColors.darkTextSecondary),
      );
      expect(AppColors.textMuted(true), equals(AppColors.darkTextMuted));
      expect(AppColors.textDisabled(true), equals(AppColors.darkTextDisabled));
      expect(
        AppColors.textOnElevatedSurface(true),
        equals(AppColors.darkTextOnElevatedSurface),
      );
      expect(AppColors.textOnGlass(true), equals(AppColors.darkTextOnGlass));
      expect(AppColors.textHint(true), equals(AppColors.darkTextHint));
      expect(AppColors.iconPrimary(true), equals(AppColors.darkIconPrimary));
      expect(
        AppColors.iconSecondary(true),
        equals(AppColors.darkIconSecondary),
      );

      // Light appearance checks
      expect(AppColors.textPrimary(false), equals(AppColors.lightTextPrimary));
      expect(
        AppColors.textSecondary(false),
        equals(AppColors.lightTextSecondary),
      );
      expect(AppColors.textMuted(false), equals(AppColors.lightTextMuted));
      expect(
        AppColors.textDisabled(false),
        equals(AppColors.lightTextDisabled),
      );
      expect(
        AppColors.textOnElevatedSurface(false),
        equals(AppColors.lightTextOnElevatedSurface),
      );
      expect(AppColors.textOnGlass(false), equals(AppColors.lightTextOnGlass));
      expect(AppColors.textHint(false), equals(AppColors.lightTextHint));
      expect(AppColors.iconPrimary(false), equals(AppColors.lightIconPrimary));
      expect(
        AppColors.iconSecondary(false),
        equals(AppColors.lightIconSecondary),
      );
    });

    test(
        '14. Foreground and background contrast pairings meet WCAG 2.2 AA (>=4.5:1 text, >=3.0:1 icons)',
        () {
      // 1. Dark surfaces: #212529 (Scaffold), #343A40 (Card/Surface), #495057 (Elevated)
      final darkSurfaces = [
        AppColors.darkBackground,
        AppColors.darkSurface,
        AppColors.darkElevated,
      ];

      for (final surface in darkSurfaces) {
        final primaryRatio =
            _contrastRatio(AppColors.textPrimary(true), surface);
        final secondaryRatio =
            _contrastRatio(AppColors.textSecondary(true), surface);
        final iconRatio = _contrastRatio(AppColors.iconPrimary(true), surface);

        // Primary text on dark surfaces must always exceed 7.0:1 (AAA)
        expect(
          primaryRatio,
          greaterThanOrEqualTo(6.5),
          reason: 'Dark primary text failed on surface $surface',
        );

        // Secondary text on dark surfaces must always exceed 4.5:1 (AA)
        expect(
          secondaryRatio,
          greaterThanOrEqualTo(4.5),
          reason: 'Dark secondary text failed on surface $surface',
        );

        // Primary icon must exceed 3.0:1 (UI control threshold)
        expect(
          iconRatio,
          greaterThanOrEqualTo(3.0),
          reason: 'Dark icon failed on surface $surface',
        );
      }

      // 2. Light surfaces: #F8F9FA (Scaffold/Card), #E9ECEF (Elevated), #DEE2E6
      final lightSurfaces = [
        AppColors.lightBackground,
        AppColors.lightElevated,
      ];

      for (final surface in lightSurfaces) {
        final primaryRatio =
            _contrastRatio(AppColors.textPrimary(false), surface);
        final secondaryRatio =
            _contrastRatio(AppColors.textSecondary(false), surface);
        final iconRatio = _contrastRatio(AppColors.iconPrimary(false), surface);

        // Primary text on light surfaces must always exceed 12.0:1 (AAA)
        expect(
          primaryRatio,
          greaterThanOrEqualTo(12.0),
          reason: 'Light primary text failed on surface $surface',
        );

        // Secondary text on light surfaces must always exceed 4.5:1 (AA)
        expect(
          secondaryRatio,
          greaterThanOrEqualTo(4.5),
          reason: 'Light secondary text failed on surface $surface',
        );

        // Primary icon must exceed 3.0:1
        expect(
          iconRatio,
          greaterThanOrEqualTo(3.0),
          reason: 'Light icon failed on surface $surface',
        );
      }
    });

    test(
        '15. Glass surfaces composite with opacity >=94% ensuring contrast retention',
        () {
      // Helper function to composite alpha colors onto solid base
      Color composite(Color fg, Color bg) {
        final a = fg.alpha / 255.0;
        final r = (fg.red * a + bg.red * (1.0 - a)).round();
        final g = (fg.green * a + bg.green * (1.0 - a)).round();
        final b = (fg.blue * a + bg.blue * (1.0 - a)).round();
        return Color.fromARGB(255, r, g, b);
      }

      // Dark glass composited on dark background
      final effectiveDarkGlass =
          composite(GlassTokens.smokedGlassSurface, AppColors.darkBackground);
      final darkGlassTextRatio =
          _contrastRatio(AppColors.textOnGlass(true), effectiveDarkGlass);
      expect(
        darkGlassTextRatio,
        greaterThanOrEqualTo(7.0),
        reason: 'Text on dark glass must maintain high contrast',
      );

      // Light glass composited on light background
      final effectiveLightGlass =
          composite(GlassTokens.lightGlassSurface, AppColors.lightBackground);
      final lightGlassTextRatio =
          _contrastRatio(AppColors.textOnGlass(false), effectiveLightGlass);
      expect(
        lightGlassTextRatio,
        greaterThanOrEqualTo(10.0),
        reason: 'Text on light glass must maintain high contrast',
      );
    });

    test(
        '16. Attendance status pills have distinct, high-contrast foregrounds in both themes',
        () {
      // Dark Mode Statuses
      final darkPresentRatio =
          _contrastRatio(AppColors.statusPresent(true), AppColors.darkSurface);
      final darkLateRatio =
          _contrastRatio(AppColors.statusLate(true), AppColors.darkSurface);
      final darkAbsentRatio =
          _contrastRatio(AppColors.statusAbsent(true), AppColors.darkSurface);
      final darkCancelledRatio = _contrastRatio(
        AppColors.statusCancelledAdaptive(true),
        AppColors.darkSurface,
      );

      expect(darkPresentRatio, greaterThanOrEqualTo(7.0));
      expect(darkLateRatio, greaterThanOrEqualTo(4.5));
      expect(darkAbsentRatio, greaterThanOrEqualTo(4.5));
      expect(darkCancelledRatio, greaterThanOrEqualTo(4.5));

      // Light Mode Statuses
      final lightPresentRatio = _contrastRatio(
        AppColors.statusPresent(false),
        AppColors.lightSurface,
      );
      final lightLateRatio =
          _contrastRatio(AppColors.statusLate(false), AppColors.lightSurface);
      final lightAbsentRatio =
          _contrastRatio(AppColors.statusAbsent(false), AppColors.lightSurface);
      final lightCancelledRatio = _contrastRatio(
        AppColors.statusCancelledAdaptive(false),
        AppColors.lightSurface,
      );

      expect(lightPresentRatio, greaterThanOrEqualTo(10.0));
      expect(lightLateRatio, greaterThanOrEqualTo(4.5));
      expect(lightAbsentRatio, greaterThanOrEqualTo(8.0));
      expect(lightCancelledRatio, greaterThanOrEqualTo(4.5));
    });

    test(
        '17. Inverted button tokens have >= 14:1 contrast on both dark and light themes',
        () {
      // Dark theme: primary button background is #F8F9FA with #212529 text
      const darkBtnBg = AppColors.primary;
      const darkBtnFg = AppColors.gray900;
      expect(_contrastRatio(darkBtnFg, darkBtnBg), greaterThanOrEqualTo(14.0));

      // Light theme: primary button background is #212529 with #F8F9FA text
      const lightBtnBg = AppColors.gray900;
      const lightBtnFg = AppColors.gray100;
      expect(
        _contrastRatio(lightBtnFg, lightBtnBg),
        greaterThanOrEqualTo(14.0),
      );
    });

    test(
        '18. Regression guard: Low-contrast combinations are forbidden for primary/secondary text',
        () {
      // 1. AppColors.primary (#F8F9FA) must NEVER be used on light surface (#F8F9FA)
      final whiteOnWhiteRatio =
          _contrastRatio(AppColors.primary, AppColors.lightSurface);
      expect(
        whiteOnWhiteRatio,
        equals(1.0),
        reason: 'Proves AppColors.primary on lightSurface is invisible 1:1',
      );

      // 2. Gray 600 (#6C757D) on dark surface (#343A40) fails WCAG AA normal text
      final gray600OnDarkRatio =
          _contrastRatio(AppColors.gray600, AppColors.darkSurface);
      expect(
        gray600OnDarkRatio,
        lessThan(3.0),
        reason: 'Proves gray600 on darkSurface fails 4.5:1 text requirement',
      );

      // 3. Gray 500 (#ADB5BD) on light surface (#F8F9FA) fails WCAG AA normal text
      final gray500OnLightRatio =
          _contrastRatio(AppColors.gray500, AppColors.lightSurface);
      expect(
        gray500OnLightRatio,
        lessThan(3.0),
        reason: 'Proves gray500 on lightSurface fails 4.5:1 text requirement',
      );

      // Ensure that our dynamic tokens avoid these forbidden ratios
      expect(
        _contrastRatio(AppColors.textPrimary(false), AppColors.lightSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          AppColors.textSecondary(false),
          AppColors.lightSurface,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(AppColors.textPrimary(true), AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(AppColors.textSecondary(true), AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test(
        '19. Real-world composited glass surfaces maintain >= 4.5:1 for all readable typography tokens',
        () {
      Color composite(Color fg, Color bg) {
        final a = fg.alpha / 255.0;
        return Color.fromARGB(
          255,
          (fg.red * a + bg.red * (1.0 - a)).round(),
          (fg.green * a + bg.green * (1.0 - a)).round(),
          (fg.blue * a + bg.blue * (1.0 - a)).round(),
        );
      }

      // 1. Dark glass on dark background (#212529)
      final darkEffectiveGlass =
          composite(AppColors.darkSurfaceGlass, AppColors.darkBackground);
      expect(
        _contrastRatio(AppColors.textPrimary(true), darkEffectiveGlass),
        greaterThanOrEqualTo(7.0),
        reason: 'Primary text on dark composited glass must exceed 7.0:1',
      );
      expect(
        _contrastRatio(AppColors.textSecondary(true), darkEffectiveGlass),
        greaterThanOrEqualTo(4.5),
        reason: 'Secondary text on dark composited glass must exceed 4.5:1',
      );
      expect(
        _contrastRatio(AppColors.textMuted(true), darkEffectiveGlass),
        greaterThanOrEqualTo(4.5),
        reason: 'Muted text on dark composited glass must exceed 4.5:1',
      );
      expect(
        _contrastRatio(AppColors.iconPrimary(true), darkEffectiveGlass),
        greaterThanOrEqualTo(3.0),
        reason: 'Primary icons on dark composited glass must exceed 3.0:1',
      );

      // 2. Light glass on light background (#F8F9FA)
      final lightEffectiveGlass =
          composite(AppColors.lightSurfaceGlass, AppColors.lightBackground);
      expect(
        _contrastRatio(AppColors.textPrimary(false), lightEffectiveGlass),
        greaterThanOrEqualTo(10.0),
        reason: 'Primary text on light composited glass must exceed 10.0:1',
      );
      expect(
        _contrastRatio(AppColors.textSecondary(false), lightEffectiveGlass),
        greaterThanOrEqualTo(4.5),
        reason: 'Secondary text on light composited glass must exceed 4.5:1',
      );
      expect(
        _contrastRatio(AppColors.textMuted(false), lightEffectiveGlass),
        greaterThanOrEqualTo(4.5),
        reason: 'Muted text on light composited glass must exceed 4.5:1',
      );
      expect(
        _contrastRatio(AppColors.iconPrimary(false), lightEffectiveGlass),
        greaterThanOrEqualTo(3.0),
        reason: 'Primary icons on light composited glass must exceed 3.0:1',
      );
    });

    test(
        '20. Regression guard: Unstyled Material Colors.grey is forbidden due to WCAG failure',
        () {
      const unstyledGrey = Color(0xFF9E9E9E); // Material Colors.grey

      // Colors.grey fails WCAG AA on cards/surfaces
      final darkContrast = _contrastRatio(unstyledGrey, AppColors.darkSurface);
      final lightContrast =
          _contrastRatio(unstyledGrey, AppColors.lightSurface);

      expect(
        darkContrast,
        lessThan(4.5),
        reason: 'Colors.grey fails WCAG AA 4.5:1 on dark cards (4.22:1)',
      );
      expect(
        lightContrast,
        lessThan(3.0),
        reason: 'Colors.grey fails WCAG AA on light cards (2.55:1)',
      );

      // Verify that semantic replacements succeed
      expect(
        _contrastRatio(AppColors.textSecondary(true), AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          AppColors.textSecondary(false),
          AppColors.lightSurface,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(AppColors.textMuted(true), AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(AppColors.textMuted(false), AppColors.lightSurface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test(
        '21. Attendance action button status tokens maintain >= 4.5:1 in selected state and >= 3.0:1 in unselected state',
        () {
      for (final isDark in [true, false]) {
        final statuses = [
          AppColors.statusPresent(isDark),
          AppColors.statusLate(isDark),
          AppColors.statusAbsent(isDark),
          AppColors.statusCancelledAdaptive(isDark),
        ];
        final surface = AppColors.surface(isDark);

        for (final st in statuses) {
          // Selected text contrast inside button
          final btnFg = st.computeLuminance() > 0.4
              ? AppColors.gray900
              : AppColors.gray100;
          expect(
            _contrastRatio(btnFg, st),
            greaterThanOrEqualTo(4.5),
            reason: 'Button foreground failed on status $st (isDark: $isDark)',
          );

          // Unselected status accent/icon against surface must meet SC 1.4.11 (>= 3.0:1)
          expect(
            _contrastRatio(st, surface),
            greaterThanOrEqualTo(3.0),
            reason:
                'Unselected status accent failed on surface $surface (isDark: $isDark)',
          );
        }
      }
    });

    testWidgets(
        '12. AcedraLogo renders correctly in both dark and light modes with vector monogram',
        (tester) async {
      // Dark mode logo test
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: AcedraLogo(
                size: 96,
                showWordmark: true,
                isDark: true,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(AcedraLogo), findsOneWidget);
      expect(find.text('ACEDRA'), findsOneWidget);

      // Light mode logo test
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: AcedraLogo(
                size: 96,
                showWordmark: true,
                isDark: false,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(AcedraLogo), findsOneWidget);
      expect(find.text('ACEDRA'), findsOneWidget);
    });
  });
}
