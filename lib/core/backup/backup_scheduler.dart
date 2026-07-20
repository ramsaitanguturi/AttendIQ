import 'dart:io';
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';
import '../../features/settings/data/models/user_preferences_local.dart';
import 'backup_service.dart';

class BackupScheduler {
  static const String weeklyAutoBackupTaskKey = 'com.ramsa.attendiq.weekly_auto_backup';
  static const String weeklyAutoBackupTag = 'attendiq_auto_backup';

  /// Computes the next scheduled backup date (defaulting to upcoming Sunday at 2:00 AM).
  static DateTime getNextScheduledBackup({
    DateTime? fromDate,
    int targetWeekday = DateTime.sunday,
    int targetHour = 2,
  }) {
    final now = fromDate ?? DateTime.now();
    DateTime candidate = DateTime(now.year, now.month, now.day, targetHour, 0);

    while (candidate.weekday != targetWeekday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
      if (candidate.weekday == targetWeekday) {
        candidate = DateTime(candidate.year, candidate.month, candidate.day, targetHour, 0);
        if (candidate.isAfter(now)) {
          break;
        }
      }
    }
    return candidate;
  }

  /// Checks whether automatic backup is due and runs it if required.
  static Future<bool> checkAndRunAutoBackup(Isar isar) async {
    try {
      final prefsList = await isar.userPreferencesLocals.where().findAll();
      if (prefsList.isEmpty) return false;

      final pref = prefsList.first;
      if (!pref.enableAutoBackup) return false;

      final now = DateTime.now();
      final lastBackup = pref.lastBackupDate;

      bool isDue = false;
      if (lastBackup == null) {
        isDue = true;
      } else {
        final daysSinceLast = now.difference(lastBackup).inDays;
        if (daysSinceLast >= 7) {
          isDue = true;
        } else {
          // Check if we passed a scheduled Sunday 2 AM window since last backup
          final nextAfterLast = getNextScheduledBackup(
            fromDate: lastBackup,
            targetWeekday: pref.autoBackupDay,
            targetHour: pref.autoBackupHour,
          );
          if (now.isAfter(nextAfterLast)) {
            isDue = true;
          }
        }
      }

      if (isDue) {
        final backupService = BackupService(isar);
        final timestamp = now.millisecondsSinceEpoch;
        final fileName = 'attendiq_backup_auto_$timestamp.attendiq';
        await backupService.exportToFile(customFileName: fileName);

        // Update last backup timestamp
        pref.lastBackupDate = now;
        pref.updatedAt = now.toUtc();
        await isar.writeAsync((isarDb) {
          isarDb.userPreferencesLocals.put(pref);
        });
        return true;
      }
    } catch (e) {
      // Log or handle error gracefully
    }
    return false;
  }

  /// Schedules or cancels periodic WorkManager auto-backup task based on user setting.
  static Future<void> scheduleOrCancelAutoBackup(bool enabled) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      if (enabled) {
        await Workmanager().registerPeriodicTask(
          weeklyAutoBackupTaskKey,
          weeklyAutoBackupTaskKey,
          tag: weeklyAutoBackupTag,
          frequency: const Duration(days: 7),
          existingWorkPolicy: ExistingWorkPolicy.keep,
          constraints: Constraints(
            networkType: NetworkType.not_required,
            requiresBatteryNotLow: true,
          ),
        );
      } else {
        await Workmanager().cancelByTag(weeklyAutoBackupTag);
      }
    } catch (_) {
      // Ignore background registration errors on unsupported target platforms
    }
  }
}
