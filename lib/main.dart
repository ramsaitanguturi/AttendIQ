import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/isar_provider.dart';
import 'core/notifications/providers/notification_providers.dart';

@immutable
class AppBootstrapResult {
  final bool databaseReady;
  final bool notificationsReady;
  final Object? error;
  final StackTrace? stackTrace;
  final Object? notificationError;
  final StackTrace? notificationStackTrace;

  const AppBootstrapResult._({
    required this.databaseReady,
    required this.notificationsReady,
    this.error,
    this.stackTrace,
    this.notificationError,
    this.notificationStackTrace,
  });

  const AppBootstrapResult.success({
    this.notificationsReady = true,
    this.notificationError,
    this.notificationStackTrace,
  })  : databaseReady = true,
        error = null,
        stackTrace = null;

  const AppBootstrapResult.failure(Object error, [StackTrace? stackTrace])
      : this._(
          databaseReady: false,
          notificationsReady: false,
          error: error,
          stackTrace: stackTrace,
        );
}

/// Initializes the Isar database and secondary startup services.
///
/// Database initialization errors and timeouts are logged and surfaced through
/// Riverpod state so [AttendIQApp] can show a recovery screen instead of
/// mounting database-dependent routes.
Future<AppBootstrapResult> initializeAppStartup(
  ProviderContainer container, {
  Duration isarTimeout = defaultDatabaseInitTimeout,
  Duration notificationTimeout = const Duration(seconds: 5),
}) async {
  developer.log('Initializing Isar database...', name: 'AppStartup');

  if (container.exists(isarProvider) &&
      (container.read(isarProvider).hasError ||
          container.read(databaseStartupFailureProvider) != null)) {
    container.read(databaseStartupFailureProvider.notifier).clear();
    container.invalidate(isarProvider);
  }

  try {
    await container.read(isarProvider.future).timeout(
      isarTimeout,
      onTimeout: () {
        throw TimeoutException(
          'Isar database initialization timed out after ${isarTimeout.inSeconds}s.',
        );
      },
    );
    container.read(databaseStartupFailureProvider.notifier).clear();
    developer.log(
      'Isar database initialized successfully.',
      name: 'AppStartup',
    );
  } catch (error, stackTrace) {
    developer.log(
      'Isar database initialization failed: $error',
      name: 'AppStartup',
      error: error,
      stackTrace: stackTrace,
    );
    final isarAsync = container.read(isarProvider);
    if (!isarAsync.hasError) {
      container.read(databaseStartupFailureProvider.notifier).reportFailure(
            error,
          );
    }
    return AppBootstrapResult.failure(error, stackTrace);
  }

  // Only initialize notifications after Isar is verified open.
  try {
    developer.log('Initializing Notification Service...', name: 'AppStartup');
    if (container.exists(notificationInitializerProvider) &&
        container.read(notificationInitializerProvider).hasError) {
      container.invalidate(notificationInitializerProvider);
    }
    await container.read(notificationInitializerProvider.future).timeout(
      notificationTimeout,
      onTimeout: () {
        throw TimeoutException(
          'Notification service initialization timed out after ${notificationTimeout.inSeconds}s.',
        );
      },
    );
    developer.log(
      'Notification Service initialized successfully.',
      name: 'AppStartup',
    );
  } catch (error, stackTrace) {
    developer.log(
      'Notification service initialization failed (continuing startup): $error',
      name: 'AppStartup',
      error: error,
      stackTrace: stackTrace,
    );
    return AppBootstrapResult.success(
      notificationsReady: false,
      notificationError: error,
      notificationStackTrace: stackTrace,
    );
  }

  return const AppBootstrapResult.success();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('AttendIQ starting initialization...', name: 'AppStartup');

  final container = ProviderContainer();
  await initializeAppStartup(container);

  runApp(
    AttendIQRootScope(
      container: container,
      child: const AttendIQApp(),
    ),
  );
}

/// Hosts the root [ProviderContainer] and ensures it (and its retained [Isar]
/// instance) is disposed when the application genuinely exits or detaches.
class AttendIQRootScope extends StatefulWidget {
  final ProviderContainer container;
  final Widget child;

  const AttendIQRootScope({
    super.key,
    required this.container,
    required this.child,
  });

  @override
  State<AttendIQRootScope> createState() => _AttendIQRootScopeState();
}

class _AttendIQRootScopeState extends State<AttendIQRootScope> {
  late final AppLifecycleListener _lifecycleListener;
  bool _containerDisposed = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onDetach: _disposeContainerOnce,
      onExitRequested: () async {
        _disposeContainerOnce();
        return AppExitResponse.exit;
      },
    );
  }

  void _disposeContainerOnce() {
    if (_containerDisposed) return;
    _containerDisposed = true;
    widget.container.dispose();
  }

  @override
  void didUpdateWidget(covariant AttendIQRootScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.container, widget.container)) {
      if (!_containerDisposed) {
        oldWidget.container.dispose();
      }
      _containerDisposed = false;
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _disposeContainerOnce();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: widget.container,
      child: widget.child,
    );
  }
}
