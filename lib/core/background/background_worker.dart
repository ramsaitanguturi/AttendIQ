import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/widgets/data/widget_data_service.dart';
import '../../features/widgets/domain/widget_models.dart';
import '../backup/backup_scheduler.dart';
import '../constants/app_constants.dart';
import '../database/isar_provider.dart';

const String widgetRefreshTaskKey = 'com.ramsa.attendiq.widget_refresh';
const String widgetRefreshPeriodicUniqueName =
    'attendiq_widget_refresh_periodic';
const String widgetRefreshTag = 'attendiq_widget_refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      if (taskName == widgetRefreshTaskKey ||
          taskName == widgetRefreshPeriodicUniqueName) {
        return await _runWidgetRefreshTask();
      }
      if (taskName == BackupScheduler.weeklyAutoBackupTaskKey) {
        return await _runWithIsar((isar) async {
          await BackupScheduler.checkAndRunAutoBackup(isar);
          return true;
        });
      }
      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          'Background task $taskName failed: $e\n$stack',
          name: 'BackgroundWorker',
          error: e,
          stackTrace: stack,
        );
      }
      return false;
    }
  });
}

Future<bool> _runWidgetRefreshTask() {
  return _runWithIsar((isar) async {
    final service = WidgetDataService.fromIsar(isar);
    await service.updateAllWidgets(respectEnabledSetting: true);
    return true;
  });
}

Future<bool> runWithBackgroundIsar(Future<bool> Function(Isar isar) action) =>
    _runWithIsar(action);

Future<bool> _runWithIsar(Future<bool> Function(Isar isar) action) async {
  Isar? isar;
  var openedHere = false;

  try {
    try {
      final existing = Isar.get(
        schemas: appIsarSchemas,
        name: AppConstants.isarDbName,
      );
      if (existing.isOpen) {
        isar = existing;
      }
    } on IsarNotReadyError {
      // Not open in this isolate yet; open below.
    }

    if (isar == null) {
      final dir = await defaultDatabaseDirectoryResolver();
      isar = Isar.open(
        schemas: appIsarSchemas,
        name: AppConstants.isarDbName,
        directory: dir,
        inspector: false,
      );
      openedHere = true;
    }

    return await action(isar);
  } finally {
    if (openedHere && isar != null && isar.isOpen) {
      isar.close();
    }
  }
}

class WidgetBackgroundScheduler {
  static bool _initialized = false;

  static bool get _isMobilePlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<void> initialize() async {
    if (_initialized || !_isMobilePlatform) return;
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Workmanager initialize skipped/failed: $e',
          name: 'WidgetBackgroundScheduler',
        );
      }
    }
  }

  static Duration frequencyForSetting(String refreshFrequency) {
    switch (refreshFrequency) {
      case '1h':
        return const Duration(hours: 1);
      case '6h':
        return const Duration(hours: 6);
      case 'auto':
      default:
        // Daily/12h background rollover safety net in addition to event-driven updates.
        return const Duration(hours: 12);
    }
  }

  static Future<void> syncSchedule(WidgetSettingsModel settings) async {
    if (!_isMobilePlatform) return;
    try {
      await initialize();
      if (!settings.enabled) {
        await Workmanager().cancelByUniqueName(widgetRefreshPeriodicUniqueName);
        return;
      }

      final frequency = frequencyForSetting(settings.refreshFrequency);
      await Workmanager().registerPeriodicTask(
        widgetRefreshPeriodicUniqueName,
        widgetRefreshTaskKey,
        tag: widgetRefreshTag,
        frequency: frequency,
        initialDelay: frequency,
        existingWorkPolicy: ExistingWorkPolicy.update,
        constraints: Constraints(
          networkType: NetworkType.not_required,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Failed to sync widget background schedule: $e',
          name: 'WidgetBackgroundScheduler',
        );
      }
    }
  }
}
