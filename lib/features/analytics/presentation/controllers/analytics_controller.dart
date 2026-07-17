import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/analytics/models/attendance_analytics.dart';
import '../../../../core/analytics/services/analytics_service.dart';

part 'analytics_controller.g.dart';

@riverpod
class AnalyticsController extends _$AnalyticsController {
  @override
  FutureOr<AttendanceAnalytics?> build() async {
    return ref.watch(attendanceAnalyticsProvider.future);
  }
}
