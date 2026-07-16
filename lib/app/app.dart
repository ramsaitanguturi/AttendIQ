import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';

class AttendIQApp extends StatelessWidget {
  const AttendIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respect system light/dark settings
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
