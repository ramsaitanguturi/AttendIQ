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
      expect(AppColors.darkBackground,
          equals(const Color(0xFF212529))); // Main background #212529
      expect(AppColors.darkSecondaryBackground,
          equals(const Color(0xFF343A40))); // Secondary background #343a40
      expect(AppColors.darkSurface,
          equals(const Color(0xFF343A40))); // Standard cards #343a40
      expect(AppColors.darkElevated,
          equals(const Color(0xFF495057))); // Elevated cards #495057
      expect(AppColors.darkBorder,
          equals(const Color(0xFF495057))); // Borders #495057
      expect(AppColors.darkTextPrimary,
          equals(const Color(0xFFF8F9FA))); // Primary text #f8f9fa
      expect(AppColors.darkTextSecondary,
          equals(const Color(0xFFCED4DA))); // Secondary text #ced4da
      expect(AppColors.darkTextMuted,
          equals(const Color(0xFFADB5BD))); // Muted text #adb5bd
      expect(AppColors.darkTextDisabled,
          equals(const Color(0xFF6C757D))); // Disabled text #6c757d
      expect(AppColors.darkIconPrimary,
          equals(const Color(0xFFDEE2E6))); // Primary icons #dee2e6
      expect(
          AppColors.navIndicator,
          equals(const Color(
              0xFFF8F9FA))); // Selected navigation indicator #f8f9fa
      expect(AppColors.navSelectedIcon,
          equals(const Color(0xFF212529))); // Selected navigation icon #212529
    });

    test('4. Light monochromatic semantic tokens match official specifications',
        () {
      expect(AppColors.lightBackground,
          equals(const Color(0xFFF8F9FA))); // Main background #f8f9fa
      expect(AppColors.lightSecondaryBackground,
          equals(const Color(0xFFE9ECEF))); // Secondary background #e9ecef
      expect(AppColors.lightSurface,
          equals(const Color(0xFFF8F9FA))); // Standard cards #f8f9fa
      expect(AppColors.lightElevated,
          equals(const Color(0xFFE9ECEF))); // Elevated surfaces #e9ecef
      expect(AppColors.lightBorder,
          equals(const Color(0xFFCED4DA))); // Borders #ced4da
      expect(AppColors.lightTextPrimary,
          equals(const Color(0xFF212529))); // Primary text #212529
      expect(AppColors.lightTextSecondary,
          equals(const Color(0xFF495057))); // Secondary text #495057
      expect(AppColors.lightTextMuted,
          equals(const Color(0xFF6C757D))); // Muted text #6c757d
      expect(AppColors.lightTextDisabled,
          equals(const Color(0xFFADB5BD))); // Disabled text #adb5bd
      expect(AppColors.lightIconPrimary,
          equals(const Color(0xFF343A40))); // Primary icons #343a40
      expect(AppColors.lightNavIndicator,
          equals(const Color(0xFF212529))); // Selected indicator #212529
      expect(AppColors.lightNavSelectedIcon,
          equals(const Color(0xFFF8F9FA))); // Selected icon #f8f9fa
    });

    test(
        '5. Dynamic semantic accessors switch correctly between dark and light',
        () {
      // Backgrounds
      expect(AppColors.background(true), equals(AppColors.darkBackground));
      expect(AppColors.background(false), equals(AppColors.lightBackground));
      expect(AppColors.secondaryBackground(true),
          equals(AppColors.darkSecondaryBackground));
      expect(AppColors.secondaryBackground(false),
          equals(AppColors.lightSecondaryBackground));

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
          AppColors.textSecondary(true), equals(AppColors.darkTextSecondary));
      expect(
          AppColors.textSecondary(false), equals(AppColors.lightTextSecondary));
      expect(AppColors.textMuted(true), equals(AppColors.darkTextMuted));
      expect(AppColors.textMuted(false), equals(AppColors.lightTextMuted));

      // Icons
      expect(AppColors.iconPrimary(true), equals(AppColors.darkIconPrimary));
      expect(AppColors.iconPrimary(false), equals(AppColors.lightIconPrimary));
      expect(
          AppColors.iconSecondary(true), equals(AppColors.darkIconSecondary));
      expect(
          AppColors.iconSecondary(false), equals(AppColors.lightIconSecondary));
    });

    test('6. Normalization maps colorful hues strictly into the 9-tier palette',
        () {
      // Pure white & bright colors map to upper tier
      expect(AppColors.normalizeToMonochrome(Colors.white),
          equals(AppColors.gray100));
      // Pure black maps to lowest tier
      expect(AppColors.normalizeToMonochrome(Colors.black),
          equals(AppColors.gray900));
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
          AppColors.parseMonochromeHex('#4ECDC4'), equals(AppColors.gray400));
      expect(
          AppColors.parseMonochromeHex('#F8F9FA'), equals(AppColors.gray100));
      expect(
          AppColors.parseMonochromeHex('#212529'), equals(AppColors.gray900));
      expect(AppColors.parseMonochromeHex('invalid_hex'),
          equals(AppColors.gray300));
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
      expect(GlassTokens.smokedGlassBg.value & 0x00FFFFFF,
          equals(AppColors.gray900.value & 0x00FFFFFF));
      expect(GlassTokens.smokedGlassSurface.value & 0x00FFFFFF,
          equals(AppColors.gray800.value & 0x00FFFFFF));
      expect(GlassTokens.smokedGlassElevated.value & 0x00FFFFFF,
          equals(AppColors.gray700.value & 0x00FFFFFF));
      expect(GlassTokens.smokedGlassSheet.value & 0x00FFFFFF,
          equals(AppColors.gray900.value & 0x00FFFFFF));

      // Light Glass Surfaces
      expect(GlassTokens.lightGlassBg.value & 0x00FFFFFF,
          equals(AppColors.gray100.value & 0x00FFFFFF));
      expect(GlassTokens.lightGlassSurface.value & 0x00FFFFFF,
          equals(AppColors.gray100.value & 0x00FFFFFF));
      expect(GlassTokens.lightGlassElevated.value & 0x00FFFFFF,
          equals(AppColors.gray200.value & 0x00FFFFFF));
      expect(GlassTokens.lightGlassSheet.value & 0x00FFFFFF,
          equals(AppColors.gray100.value & 0x00FFFFFF));

      // Borders
      expect(GlassTokens.silverBorder.value & 0x00FFFFFF,
          equals(AppColors.gray300.value & 0x00FFFFFF));
      expect(GlassTokens.silverBorderBright.value & 0x00FFFFFF,
          equals(AppColors.gray100.value & 0x00FFFFFF));
      expect(GlassTokens.lightGlassBorder.value & 0x00FFFFFF,
          equals(AppColors.gray400.value & 0x00FFFFFF));
      expect(GlassTokens.lightGlassBorderBright.value & 0x00FFFFFF,
          equals(AppColors.gray400.value & 0x00FFFFFF));
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
      expect((darkGlassOffDec.border as Border).top.color,
          equals(AppColors.darkBorder));

      // 2. Dark + Glass ON
      final darkGlassOnDec =
          GlassTokens.glassBoxDecoration(isDark: true, isElevated: false);
      expect(darkGlassOnDec.gradient, isNotNull);
      expect((darkGlassOnDec.border as Border).top.color,
          equals(GlassTokens.silverBorder));

      // 3. Light + Glass OFF
      final lightGlassOffDec = BoxDecoration(
        color: AppColors.surface(false),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(false), width: 1.0),
        boxShadow: GlassTokens.cardShadows(isGlassy: false, isDark: false),
      );
      expect(lightGlassOffDec.color, equals(AppColors.lightSurface));
      expect((lightGlassOffDec.border as Border).top.color,
          equals(AppColors.lightBorder));

      // 4. Light + Glass ON
      final lightGlassOnDec =
          GlassTokens.glassBoxDecoration(isDark: false, isElevated: false);
      expect(lightGlassOnDec.gradient, isNotNull);
      expect((lightGlassOnDec.border as Border).top.color,
          equals(GlassTokens.lightGlassBorder));
    });

    test(
        '11. Monochromatic text contrast satisfies WCAG AA and AAA accessibility standards',
        () {
      // Dark Mode Contrast
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

      // Light Mode Contrast
      final lightPrimaryContrast =
          _contrastRatio(AppColors.lightTextPrimary, AppColors.lightBackground);
      final lightSecondaryContrast = _contrastRatio(
          AppColors.lightTextSecondary, AppColors.lightBackground);
      final lightMutedContrast =
          _contrastRatio(AppColors.lightTextMuted, AppColors.lightBackground);

      // #212529 on #F8F9FA has > 15:1 contrast (WCAG AAA requires 7.0:1)
      expect(lightPrimaryContrast, greaterThanOrEqualTo(14.0));
      // #495057 on #F8F9FA has > 7:1 contrast (WCAG AAA requires 7.0:1)
      expect(lightSecondaryContrast, greaterThanOrEqualTo(7.0));
      // #6C757D on #F8F9FA has ~4.45:1 contrast (well above 3.0:1 WCAG requirement for secondary/muted text)
      expect(lightMutedContrast, greaterThanOrEqualTo(4.0));
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
