import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/acedra_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorderSubtle,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                    blurRadius: 30.0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 20.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AcedraLogo(
                    size: 80.0,
                    showWordmark: true,
                    spacing: 16.0,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    'Academic & Attendance Intelligence',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48.0),
            const SizedBox(
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.silverReflect),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Initializing ACEDRA...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
