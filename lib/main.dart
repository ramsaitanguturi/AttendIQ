import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/isar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (wrapped in a try-catch for safe Phase 0 initialization)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Please add firebase_options.dart or platform configs to configure Firebase fully.');
  }

  // Pre-warm the Isar database provider so it is initialized before the UI loads
  final container = ProviderContainer();
  try {
    await container.read(isarProvider.future);
  } catch (e) {
    debugPrint('Isar initialization failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AttendIQApp(),
    ),
  );
}
