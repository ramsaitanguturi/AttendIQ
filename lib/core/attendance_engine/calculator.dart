class AttendanceCalculator {
  AttendanceCalculator._();

  /// Calculates the current actual attendance percentage of a subject.
  /// P = (A_attended / A_total) * 100
  /// If A_total is 0, returns 100.0.
  static double calculatePercentage({
    required int attended,
    required int total,
  }) {
    if (total <= 0) return 100.0;
    final percentage = (attended / total) * 100.0;
    return percentage.clamp(0.0, 100.0);
  }

  /// Calculates how many consecutive future classes a student can skip (bunk)
  /// without their percentage dropping below the target threshold T (e.g. 75%).
  /// B_safe = max(0, floor((100 * A_attended - T * A_total) / T))
  /// If A_total = 0, returns 0.
  static int calculateSafeBunks({
    required int attended,
    required int total,
    required double target,
  }) {
    if (total <= 0) return 0;
    if (target <= 0) return 0;
    
    final value = ((100.0 * attended) - (target * total)) / target;
    final safeBunks = value.floor();
    
    return safeBunks < 0 ? 0 : safeBunks;
  }

  /// Calculates how many consecutive classes a student must attend to reach the
  /// target threshold T if their current percentage is below T.
  /// A_req = ceil((T * A_total - 100 * A_attended) / (100 - T))
  /// If T = 100 and A_attended < A_total, it returns null (representing N/A).
  /// If current percentage is already above or equal to T, returns 0.
  static int? calculateRequiredClasses({
    required int attended,
    required int total,
    required double target,
  }) {
    final currentPercentage = calculatePercentage(attended: attended, total: total);
    if (currentPercentage >= target) return 0;
    
    if (target >= 100.0) {
      if (attended < total) {
        return null; // N/A
      }
      return 0;
    }

    final value = ((target * total) - (100.0 * attended)) / (100.0 - target);
    return value.ceil();
  }
}
