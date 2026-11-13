import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.attendanceLow,
      ),
      dividerColor: AppColors.lightBorder,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.lightTextPrimary),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.lightTextSecondary),
        labelSmall: AppTextStyles.labelSmall
            .copyWith(color: AppColors.lightTextSecondary),
      ),
      cardTheme: const CardTheme(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.silverReflect,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.silverReflect,
        secondary: AppColors.silverReflect,
        surface: AppColors.darkSurface,
        error: AppColors.attendanceLow,
        outline: AppColors.silverBorderSubtle,
      ),
      dividerColor: AppColors.silverBorderSubtle,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.silverReflect),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.silverReflect,
        unselectedItemColor: AppColors.darkTextSecondary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.darkTextPrimary),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.darkTextSecondary),
        labelSmall: AppTextStyles.labelSmall
            .copyWith(color: AppColors.darkTextSecondary),
      ),
      cardTheme: const CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: AppColors.silverBorderSubtle, width: 1.0),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          side: BorderSide(color: AppColors.silverBorderSubtle, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          side: BorderSide(color: AppColors.silverBorderSubtle, width: 1.0),
        ),
      ),
    );
  }
}
