import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.primaryFont,
      primaryColor: AppColors.gray900,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.gray900,
        onPrimary: AppColors.gray100,
        secondary: AppColors.gray700,
        onSecondary: AppColors.gray100,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.gray600,
        onError: AppColors.gray100,
        outline: AppColors.lightBorder,
      ),
      dividerColor: AppColors.lightBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.lightIconPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightNavIndicator,
        unselectedItemColor: AppColors.lightNavUnselectedIcon,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightIconPrimary),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.lightTextPrimary),
        displayMedium: const TextStyle(
            color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(
            color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: const TextStyle(
            color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(
            color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: const TextStyle(
            color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(
            color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.lightTextPrimary),
        titleSmall: const TextStyle(
            color: AppColors.lightTextSecondary, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppColors.lightTextSecondary),
        bodyMedium: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.lightTextSecondary),
        bodySmall: const TextStyle(color: AppColors.lightTextMuted),
        labelLarge: const TextStyle(
            color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(color: AppColors.lightTextSecondary),
        labelSmall:
            AppTextStyles.labelSmall.copyWith(color: AppColors.lightTextMuted),
      ),
      cardTheme: const CardTheme(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          side: BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          side: BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gray900,
          foregroundColor: AppColors.gray100,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gray900,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gray900,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gray900,
        foregroundColor: AppColors.gray100,
        elevation: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gray100;
          }
          return AppColors.gray600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gray900;
          }
          return AppColors.gray300;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.gray900,
        inactiveTrackColor: AppColors.gray400,
        thumbColor: AppColors.gray900,
        overlayColor: Color(0x33212529),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gray900,
        linearTrackColor: AppColors.lightBorder,
        refreshBackgroundColor: AppColors.lightSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray900,
        contentTextStyle: const TextStyle(color: AppColors.gray100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gray700, width: 1.0),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.lightSecondaryBackground,
        filled: true,
        hintStyle:
            const TextStyle(color: AppColors.lightTextHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        helperStyle: const TextStyle(color: AppColors.lightTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray900, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.primaryFont,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.attendanceLow,
        onError: AppColors.gray100,
        outline: AppColors.darkBorder,
      ),
      dividerColor: AppColors.darkBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.darkIconPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.navIndicator,
        unselectedItemColor: AppColors.navUnselectedIcon,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkIconPrimary),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.darkTextPrimary),
        displayMedium: const TextStyle(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: const TextStyle(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: const TextStyle(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.darkTextPrimary),
        titleSmall: const TextStyle(
            color: AppColors.darkTextSecondary, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppColors.darkTextSecondary),
        bodyMedium: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.darkTextSecondary),
        bodySmall: const TextStyle(color: AppColors.darkTextMuted),
        labelLarge: const TextStyle(
            color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(color: AppColors.darkTextSecondary),
        labelSmall:
            AppTextStyles.labelSmall.copyWith(color: AppColors.darkTextMuted),
      ),
      cardTheme: const CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          side: BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          side: BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gray900;
          }
          return AppColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gray100;
          }
          return AppColors.gray700;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.gray100,
        inactiveTrackColor: AppColors.gray700,
        thumbColor: AppColors.gray100,
        overlayColor: Color(0x33F8F9FA),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkBorder,
        refreshBackgroundColor: AppColors.darkSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.darkSurface,
        filled: true,
        hintStyle: const TextStyle(color: AppColors.darkTextHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        helperStyle: const TextStyle(color: AppColors.darkTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
