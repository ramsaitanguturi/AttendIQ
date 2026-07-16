class AttendancePredictor {
  AttendancePredictor._();

  /// Predicts final attendance at the end of the semester by projecting recent attendance behavior.
  /// Let R be remaining scheduled classes, P_recent be the recent attendance rate.
  /// A_forecasted_present = A_attended + (R * P_recent)
  /// A_forecasted_total = A_total + R
  /// P_forecasted = (A_forecasted_present / A_forecasted_total) * 100
  static double predictFutureAttendance({
    required int attended,
    required int total,
    required int remaining,
    required double recentRate, // range [0.0, 1.0] representing percentage / 100
  }) {
    final forecastedPresent = attended + (remaining * recentRate);
    final forecastedTotal = total + remaining;

    if (forecastedTotal <= 0) return 100.0;
    final forecastedPercentage = (forecastedPresent / forecastedTotal) * 100.0;
    return forecastedPercentage.clamp(0.0, 100.0);
  }
}
