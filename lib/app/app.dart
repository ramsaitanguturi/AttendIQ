import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/constants/app_constants.dart';
import '../core/database/isar_provider.dart';
import '../core/notifications/providers/notification_providers.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/database_startup_error_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import '../features/widgets/services/widget_refresh_service.dart';
import 'app_router.dart';

class AttendIQApp extends ConsumerWidget {
  const AttendIQApp({super.key});

  void _retryDatabaseStartup(WidgetRef ref) {
    ref.read(databaseStartupFailureProvider.notifier).clear();
    ref.invalidate(notificationInitializerProvider);
    ref.invalidate(isarProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupFailure = ref.watch(databaseStartupFailureProvider);
    if (startupFailure != null) {
      return _AttendIQErrorApp(
        error: startupFailure,
        onRetry: () => _retryDatabaseStartup(ref),
      );
    }

    final isarAsync = ref.watch(isarProvider);
    return isarAsync.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      data: (_) => const _AttendIQRouterShell(),
      loading: () => MaterialApp(
        key: const ValueKey('attendiq_loading_app'),
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
      error: (error, _) => _AttendIQErrorApp(
        error: error,
        onRetry: () => _retryDatabaseStartup(ref),
      ),
    );
  }
}

class _AttendIQErrorApp extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _AttendIQErrorApp({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const ValueKey('attendiq_error_app'),
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: DatabaseStartupErrorPage(
        error: error,
        onRetry: onRetry,
      ),
    );
  }
}

/// Mounted only after [isarProvider] has resolved to a valid open [Isar]
/// instance so database-dependent controllers and routes never evaluate early.
class _AttendIQRouterShell extends ConsumerStatefulWidget {
  const _AttendIQRouterShell();

  @override
  ConsumerState<_AttendIQRouterShell> createState() =>
      _AttendIQRouterShellState();
}

class _AttendIQRouterShellState extends ConsumerState<_AttendIQRouterShell> {
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    _initHomeWidgetDeepLinks();
    _ensureNotificationsInitialized();
    _refreshWidgetsOnLaunch();
  }

  void _ensureNotificationsInitialized() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        unawaited(
          ref.read(notificationInitializerProvider.future).catchError(
            (Object error, StackTrace stackTrace) {
              developer.log(
                'Notification initialization failed during router shell startup: $error',
                name: 'AttendIQApp',
                error: error,
                stackTrace: stackTrace,
              );
            },
          ),
        );
      } catch (error, stackTrace) {
        developer.log(
          'Failed to trigger notification initialization: $error',
          name: 'AttendIQApp',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }

  void _refreshWidgetsOnLaunch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        unawaited(
          ref.read(widgetRefreshServiceProvider).refreshAllWidgets().catchError(
            (Object error, StackTrace stackTrace) {
              developer.log(
                'Launch widget refresh failed: $error',
                name: 'AttendIQApp',
                error: error,
                stackTrace: stackTrace,
              );
            },
          ),
        );
      } catch (error, stackTrace) {
        developer.log(
          'Launch widget refresh scheduling failed: $error',
          name: 'AttendIQApp',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }

  void _initHomeWidgetDeepLinks() {
    try {
      HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
        if (uri != null && mounted) {
          _handleWidgetUri(uri);
        }
      }).catchError((Object _) {});

      _sub = HomeWidget.widgetClicked.listen(
        (uri) {
          if (uri != null && mounted) {
            _handleWidgetUri(uri);
          }
        },
        onError: (Object _) {},
      );
    } catch (_) {}
  }

  void _handleWidgetUri(Uri uri) {
    try {
      final router = ref.read(appRouterProvider);
      final host =
          uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', '');

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
      key: const ValueKey('attendiq_router_app'),
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
