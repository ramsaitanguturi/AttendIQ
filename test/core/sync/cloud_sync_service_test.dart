import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/sync/cloud_sync_service.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import '../../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarInstance testDb;
  late Isar isar;
  late ProviderContainer container;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() async {
    testDb = openTestIsar(prefix: 'cloud_sync');
    isar = testDb.isar;

    container = ProviderContainer(
      overrides: [
        isarProvider.overrideWith((ref) => isar),
      ],
    );
    container.listen(settingsControllerProvider, (_, __) {});
    await container.read(settingsControllerProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await testDb.dispose();
  });

  group('CloudSyncNotifier Tests', () {
    test('Sync is disabled when cloud consent is not granted', () async {
      final notifier = container.read(cloudSyncStateProvider.notifier);
      final success = await notifier.syncNow();

      expect(success, isFalse);
      final state = container.read(cloudSyncStateProvider);
      expect(state.status, equals(CloudSyncStatus.disabled));
    });

    test('Conflict detection halts sync when remote backup is newer', () async {
      // Enable cloud sync with consent
      await container
          .read(settingsControllerProvider.notifier)
          .updateCloudSyncSettings(
            enabled: true,
            consentGiven: true,
          );

      final notifier = container.read(cloudSyncStateProvider.notifier);

      // Pass mock remote data with future timestamp
      final futureTime = DateTime.now().toUtc().add(const Duration(days: 1));
      final mockRemote = {
        'metadata': {
          'createdAt': futureTime.toIso8601String(),
          'version': 2,
        }
      };

      final success = await notifier.syncNow(mockRemoteData: mockRemote);

      expect(success, isFalse);
      final state = container.read(cloudSyncStateProvider);
      expect(state.status, equals(CloudSyncStatus.conflict));
      expect(state.message, contains('Cloud backup is newer'));
    });

    test('Sync completes successfully when authorized and no conflicts',
        () async {
      await container
          .read(settingsControllerProvider.notifier)
          .updateCloudSyncSettings(
            enabled: true,
            consentGiven: true,
          );

      final notifier = container.read(cloudSyncStateProvider.notifier);

      // Pass mock remote data with past timestamp
      final pastTime = DateTime.now().toUtc().subtract(const Duration(days: 1));
      final mockRemote = {
        'metadata': {
          'createdAt': pastTime.toIso8601String(),
          'version': 2,
        }
      };

      final success = await notifier.syncNow(mockRemoteData: mockRemote);

      expect(success, isTrue);
      final state = container.read(cloudSyncStateProvider);
      expect(state.status, equals(CloudSyncStatus.success));
      expect(state.lastSyncTime, isNotNull);
    });

    test('Delete cloud backup resets sync state', () async {
      final notifier = container.read(cloudSyncStateProvider.notifier);
      await notifier.deleteCloudBackup();

      final state = container.read(cloudSyncStateProvider);
      expect(state.status, equals(CloudSyncStatus.idle));
      expect(state.lastSyncTime, isNull);
    });
  });
}
