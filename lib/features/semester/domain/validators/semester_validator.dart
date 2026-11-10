import '../../../../core/errors/app_exception.dart';
import '../entities/semester.dart';

/// Shared business validation rules for semester lifecycle, date ordering, and
/// non-overlapping date intervals (`docs/DOMAIN_RULES.md` §2).
class SemesterValidator {
  SemesterValidator._();

  /// Normalizes any [DateTime] to a timezone-independent UTC calendar date.
  static DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Converts a [DateTime] to a local midnight calendar date so Isar's
  /// UTC-serialize / local-deserialize roundtrip preserves the exact calendar
  /// day across all device timezones.
  static DateTime toLocalCalendarDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns `true` strictly when [startDate] precedes [endDate] by calendar
  /// day (`startDate < endDate`).
  static bool hasValidDateRange(DateTime startDate, DateTime endDate) {
    return normalizeDate(startDate).isBefore(normalizeDate(endDate));
  }

  /// Returns `true` when `[startA, endA]` and `[startB, endB]` share at least
  /// one calendar day (inclusive bounds).
  static bool datesOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    final normStartA = normalizeDate(startA);
    final normEndA = normalizeDate(endA);
    final normStartB = normalizeDate(startB);
    final normEndB = normalizeDate(endB);

    return !normEndA.isBefore(normStartB) && !normStartA.isAfter(normEndB);
  }

  /// Returns a human-readable validation error if `[startDate, endDate]` does
  /// not satisfy `startDate < endDate`, or `null` if valid.
  static String? validateDateRangeMessage(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (!hasValidDateRange(startDate, endDate)) {
      return 'End date must be after start date.';
    }
    return null;
  }

  /// Returns the first semester in [existingSemesters] whose date range
  /// overlaps `[startDate, endDate]`, excluding [excludeLocalId].
  static Semester? findOverlappingSemester({
    required DateTime startDate,
    required DateTime endDate,
    required Iterable<Semester> existingSemesters,
    int? excludeLocalId,
  }) {
    for (final existing in existingSemesters) {
      if (excludeLocalId != null && existing.localId == excludeLocalId) {
        continue;
      }
      if (datesOverlap(
        startDate,
        endDate,
        existing.startDate,
        existing.endDate,
      )) {
        return existing;
      }
    }
    return null;
  }

  /// Validates intrinsic properties of [candidate] (`name`, attendance target,
  /// and `startDate < endDate`), throwing [ValidationException] on violation.
  static void validateBasic(Semester candidate) {
    if (candidate.name.trim().isEmpty) {
      throw const ValidationException(
        'Semester name cannot be empty.',
        'SEMESTER_NAME_EMPTY',
      );
    }

    final rate = candidate.requiredAttendanceRate;
    if (rate.isNaN || rate < 0.0 || rate > 100.0) {
      throw const ValidationException(
        'Required attendance rate must be between 0% and 100%.',
        'SEMESTER_INVALID_RATE',
      );
    }

    if (!hasValidDateRange(candidate.startDate, candidate.endDate)) {
      throw const ValidationException(
        'Start date must be strictly before end date.',
        'SEMESTER_INVALID_DATE_RANGE',
      );
    }
  }

  /// Validates [candidate] including date-overlap checks against
  /// [existingSemesters], throwing [ValidationException] on violation.
  static void validateForSave({
    required Semester candidate,
    required Iterable<Semester> existingSemesters,
  }) {
    validateBasic(candidate);

    final overlapping = findOverlappingSemester(
      startDate: candidate.startDate,
      endDate: candidate.endDate,
      existingSemesters: existingSemesters,
      excludeLocalId: candidate.localId,
    );
    if (overlapping != null) {
      throw ValidationException(
        'Semester dates overlap with "${overlapping.name}" '
            '(${_formatDate(overlapping.startDate)} – ${_formatDate(overlapping.endDate)}).',
        'SEMESTER_DATE_OVERLAP',
      );
    }
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
