import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/reports/models/attendance_report.dart';
import '../../../../core/reports/services/report_service.dart';

part 'reports_controller.g.dart';

@riverpod
class ReportsController extends _$ReportsController {
  @override
  FutureOr<AttendanceReport?> build() async {
    final service = ref.watch(reportServiceProvider);
    return await service.generateSemesterReport();
  }

  Future<void> generateReport() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(reportServiceProvider);
      return await service.generateSemesterReport();
    });
  }
}
