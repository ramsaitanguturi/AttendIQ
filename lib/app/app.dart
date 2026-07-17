import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import 'app_router.dart';

class AttendIQApp extends ConsumerWidget {
  const AttendIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

