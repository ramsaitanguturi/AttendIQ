import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import '../features/widgets/services/widget_refresh_service.dart';
import 'app_router.dart';

class AttendIQApp extends ConsumerStatefulWidget {
  const AttendIQApp({super.key});

  @override
  ConsumerState<AttendIQApp> createState() => _AttendIQAppState();
}

class _AttendIQAppState extends ConsumerState<AttendIQApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initHomeWidgetDeepLinks();
    _refreshWidgetsOnLaunch();
  }

  void _refreshWidgetsOnLaunch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(widgetRefreshServiceProvider).refreshAllWidgets();
      } catch (_) {}
    });
  }

  void _initHomeWidgetDeepLinks() {
    try {
      HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
        if (uri != null) _handleWidgetUri(uri);
      }).catchError((_) {});

      _sub = HomeWidget.widgetClicked.listen(
        (uri) {
          if (uri != null) _handleWidgetUri(uri);
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _handleWidgetUri(Uri uri) {
    try {
      final router = ref.read(appRouterProvider);
      final host = uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', '');

      if (host == 'today') {
        router.go('/dashboard');
      } else if (host == 'timetable') {
        router.go('/timetable');
      } else if (host == 'calendar' || host == 'planner') {
        router.go('/planner');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
