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
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.lightTextPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.lightTextSecondary),
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
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.attendanceLow,
      ),
      dividerColor: AppColors.darkBorder,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.darkTextSecondary),
      ),
      cardTheme: const CardTheme(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),
    );
  }
}
