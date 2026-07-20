import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/isar_provider.dart';
import 'core/notifications/providers/notification_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('AttendIQ starting initialization...');

  final container = ProviderContainer();
  
  // Pre-warm the Isar database provider and Notification Service with timeouts
  try {
    debugPrint('Initializing Isar database...');
    await container.read(isarProvider.future).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Isar database initialization timed out (5s).');
        throw TimeoutException('Isar database initialization timed out');
      },
    );
    debugPrint('Isar database initialized successfully.');

    debugPrint('Initializing Notification Service...');
    await container.read(notificationInitializerProvider.future).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Notification service initialization timed out (5s).');
        throw TimeoutException('Notification service initialization timed out');
      },
    );
    debugPrint('Notification Service initialized successfully.');
  } catch (e, stack) {
    debugPrint('Startup service initialization failed: $e');
    debugPrint(stack.toString());
  }

  debugPrint('Initialization steps completed or timed out. Booting UI...');
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AttendIQApp(),
    ),
  );
}
