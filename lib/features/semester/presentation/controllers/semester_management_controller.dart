import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/notifications/providers/notification_providers.dart';
import '../../../widgets/services/widget_refresh_service.dart';
import '../../domain/entities/semester.dart';
import 'semester_controller.dart';

part 'semester_management_controller.g.dart';

@riverpod
class SemesterManagementController extends _$SemesterManagementController {
  @override
  FutureOr<void> build() async {}

  Future<void> createSemester(Semester semester) async {
    final repo = ref.read(semesterRepositoryProvider);
    await repo.createSemester(semester);
    await _syncAfterMutation();
  }

  Future<void> updateSemester(Semester semester) async {
    final repo = ref.read(semesterRepositoryProvider);
    await repo.updateSemester(semester);
    await _syncAfterMutation();
  }

  Future<void> setActiveSemester(int localId) async {
    final repo = ref.read(semesterRepositoryProvider);
    await repo.setActiveSemester(localId);
    await _syncAfterMutation();
  }

  Future<void> archiveSemester(int localId) async {
    final repo = ref.read(semesterRepositoryProvider);
    await repo.archiveSemester(localId);
    await _syncAfterMutation();
  }

  Future<void> _syncAfterMutation() async {
    ref.invalidate(hasActiveSemesterProvider);
    ref.invalidate(activeSemesterProvider);
    ref.invalidate(allSemestersProvider);

    try {
      await ref.read(widgetRefreshServiceProvider).refreshAllWidgets();
    } catch (_) {}

    try {
      final scheduler = ref.read(notificationSchedulerProvider);
      await scheduler.rescheduleAll();
    } catch (_) {}
  }
}
