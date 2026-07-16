enum BunkStatus {
  NORMAL,
  WARNING,
  CRITICAL
}

class BunkAnalysis {
  final BunkStatus status;
  final String statusText;
  final int safeBunks;
  final int? requiredClasses;
  final String recommendation;

  BunkAnalysis({
    required this.status,
    required this.statusText,
    required this.safeBunks,
    this.requiredClasses,
    required this.recommendation,
  });
}

class BunkAnalyzer {
  BunkAnalyzer._();

  /// Heuristic checks from DOMAIN_RULES.md:
  /// - Low Margin Warning: Triggered if P >= T but P - T <= 2.5%.
  /// - Critical Status: Triggered if P < T.
  static BunkAnalysis analyze({
    required double currentPercentage,
    required double targetPercentage,
    required int safeBunks,
    required int? requiredClasses,
  }) {
    if (currentPercentage < targetPercentage) {
      final reqStr = requiredClasses != null ? '$requiredClasses' : 'N/A';
      return BunkAnalysis(
        status: BunkStatus.CRITICAL,
        statusText: 'Critical',
        safeBunks: 0,
        requiredClasses: requiredClasses,
        recommendation: 'Attendance is below target! You must attend $reqStr consecutive classes to recover.',
      );
    } else if (currentPercentage - targetPercentage <= 2.5) {
      return BunkAnalysis(
        status: BunkStatus.WARNING,
        statusText: 'Warning',
        safeBunks: safeBunks,
        requiredClasses: 0,
        recommendation: 'Warning: Narrow attendance margin! Avoid skipping any more classes.',
      );
    } else {
      return BunkAnalysis(
        status: BunkStatus.NORMAL,
        statusText: 'Normal',
        safeBunks: safeBunks,
        requiredClasses: 0,
        recommendation: safeBunks > 0
            ? 'You are in the safe zone. You can bunk up to $safeBunks classes.'
            : 'You are in the safe zone, but cannot skip any classes without dropping below the target.',
      );
    }
  }
}
