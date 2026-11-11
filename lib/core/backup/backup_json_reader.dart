/// Typed JSON reading helpers for backup deserialization and validation.
///
/// All methods throw [FormatException] with field-path context instead of
/// leaking raw Dart [TypeError] exceptions or silently coercing invalid values.
class BackupJsonReader {
  BackupJsonReader._();

  static final RegExp _isoDatePrefixPattern = RegExp(
    r'^\d{4}-\d{2}-\d{2}(?:[T\s].*)?$',
  );
  static final RegExp _isoYmdPrefix = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

  static Map<String, dynamic> asJsonObject(
    Object? value,
    String path,
  ) {
    if (value is! Map) {
      throw FormatException('$path: Expected a JSON object.');
    }
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw FormatException('$path: Expected string keys in JSON object.');
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }

  static Map<String, dynamic>? optionalObjectField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    if (!map.containsKey(key)) {
      return null;
    }
    final fieldPath = path.isEmpty ? key : '$path.$key';
    final value = map[key];
    if (value == null) {
      throw FormatException('$fieldPath: Expected a JSON object, got null.');
    }
    return asJsonObject(value, fieldPath);
  }

  static List<Map<String, dynamic>> requireObjectListField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    final fieldPath = path.isEmpty ? key : '$path.$key';
    if (!map.containsKey(key) || map[key] == null) {
      throw FormatException('$fieldPath: Missing required JSON array.');
    }
    return _asObjectList(map[key], fieldPath);
  }

  static List<Map<String, dynamic>>? optionalObjectListField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    if (!map.containsKey(key)) {
      return null;
    }
    final fieldPath = path.isEmpty ? key : '$path.$key';
    final value = map[key];
    if (value == null) {
      throw FormatException('$fieldPath: Expected a JSON array, got null.');
    }
    return _asObjectList(value, fieldPath);
  }

  static List<Map<String, dynamic>> _asObjectList(
    Object? value,
    String path,
  ) {
    if (value is! List) {
      throw FormatException('$path: Expected a JSON array.');
    }
    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < value.length; i++) {
      result.add(asJsonObject(value[i], '$path[$i]'));
    }
    return result;
  }

  static String requireStringField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    final fieldPath = '$path.$key';
    if (!map.containsKey(key) || map[key] == null) {
      throw FormatException('$fieldPath: Missing required string.');
    }
    final value = map[key];
    if (value is! String) {
      throw FormatException('$fieldPath: Expected a string.');
    }
    return value;
  }

  static String requireNonEmptyStringField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    final value = requireStringField(map, key, path);
    if (value.trim().isEmpty) {
      throw FormatException('$path.$key: Must not be empty.');
    }
    return value;
  }

  /// Reads an optional non-nullable string when omitted; rejects explicit null
  /// or non-string values when the key is present.
  static String? optionalNonNullStringField(
    Map<String, dynamic> map,
    String key,
    String path, {
    bool allowEmpty = true,
  }) {
    if (!map.containsKey(key)) {
      return null;
    }
    final fieldPath = '$path.$key';
    final value = map[key];
    if (value is! String) {
      throw FormatException('$fieldPath: Expected a string.');
    }
    if (!allowEmpty && value.trim().isEmpty) {
      throw FormatException('$fieldPath: Must not be empty.');
    }
    return value;
  }

  /// Reads a nullable string field (`null` is allowed, non-String is rejected).
  static String? nullableStringField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    if (!map.containsKey(key) || map[key] == null) {
      return null;
    }
    final value = map[key];
    if (value is! String) {
      throw FormatException('$path.$key: Expected a string or null.');
    }
    return value;
  }

  static int requireIntField(
    Map<String, dynamic> map,
    String key,
    String path, {
    int? min,
    int? max,
  }) {
    final fieldPath = '$path.$key';
    if (!map.containsKey(key) || map[key] == null) {
      throw FormatException('$fieldPath: Missing required integer.');
    }
    final value = map[key];
    if (value is! int) {
      throw FormatException('$fieldPath: Expected an integer.');
    }
    _checkIntBounds(value, fieldPath, min: min, max: max);
    return value;
  }

  /// Reads an optional non-nullable integer when omitted; rejects explicit null
  /// or non-integer values when the key is present.
  static int? optionalNonNullIntField(
    Map<String, dynamic> map,
    String key,
    String path, {
    int? min,
    int? max,
  }) {
    if (!map.containsKey(key)) {
      return null;
    }
    final fieldPath = '$path.$key';
    final value = map[key];
    if (value is! int) {
      throw FormatException('$fieldPath: Expected an integer.');
    }
    _checkIntBounds(value, fieldPath, min: min, max: max);
    return value;
  }

  /// Reads a nullable integer field (`null` is allowed, non-int is rejected).
  static int? nullableIntField(
    Map<String, dynamic> map,
    String key,
    String path, {
    int? min,
    int? max,
  }) {
    if (!map.containsKey(key) || map[key] == null) {
      return null;
    }
    final fieldPath = '$path.$key';
    final value = map[key];
    if (value is! int) {
      throw FormatException('$fieldPath: Expected an integer or null.');
    }
    _checkIntBounds(value, fieldPath, min: min, max: max);
    return value;
  }

  static void _checkIntBounds(
    int value,
    String fieldPath, {
    int? min,
    int? max,
  }) {
    if (min != null && value < min) {
      throw FormatException('$fieldPath: Must be >= $min (got $value).');
    }
    if (max != null && value > max) {
      throw FormatException('$fieldPath: Must be <= $max (got $value).');
    }
  }

  static double? optionalNonNullDoubleField(
    Map<String, dynamic> map,
    String key,
    String path, {
    double? min,
    double? max,
  }) {
    if (!map.containsKey(key)) {
      return null;
    }
    final fieldPath = '$path.$key';
    final value = map[key];
    if (value is! num) {
      throw FormatException('$fieldPath: Expected a number.');
    }
    final d = value.toDouble();
    if (!d.isFinite) {
      throw FormatException('$fieldPath: Number must be finite.');
    }
    if (min != null && d < min) {
      throw FormatException('$fieldPath: Must be >= $min (got $d).');
    }
    if (max != null && d > max) {
      throw FormatException('$fieldPath: Must be <= $max (got $d).');
    }
    return d;
  }

  static bool? optionalNonNullBoolField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    if (!map.containsKey(key)) {
      return null;
    }
    final value = map[key];
    if (value is! bool) {
      throw FormatException('$path.$key: Expected a boolean.');
    }
    return value;
  }

  static DateTime requireIsoDateTimeField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    final raw = requireNonEmptyStringField(map, key, path);
    return parseIsoDateTime(raw, '$path.$key');
  }

  static DateTime? optionalNonNullIsoDateTimeField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    final raw = optionalNonNullStringField(
      map,
      key,
      path,
      allowEmpty: false,
    );
    if (raw == null) {
      return null;
    }
    return parseIsoDateTime(raw, '$path.$key');
  }

  static DateTime? nullableIsoDateTimeField(
    Map<String, dynamic> map,
    String key,
    String path,
  ) {
    if (!map.containsKey(key) || map[key] == null) {
      return null;
    }
    final raw = map[key];
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException(
        '$path.$key: Expected a valid ISO-8601 date string or null.',
      );
    }
    return parseIsoDateTime(raw, '$path.$key');
  }

  /// Parses a date-only (`YYYY-MM-DD`) or full ISO-8601 timestamp
  /// (e.g. `YYYY-MM-DDTHH:mm:ssZ`), rejecting calendar overflows like Feb 30.
  static DateTime parseIsoDateTime(String raw, String fieldPath) {
    final trimmed = raw.trim();
    if (!_isoDatePrefixPattern.hasMatch(trimmed)) {
      throw FormatException(
        '$fieldPath: Expected an ISO-8601 date string (got "$raw").',
      );
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) {
      throw FormatException(
        '$fieldPath: Invalid ISO-8601 date string "$raw".',
      );
    }
    final ymdMatch = _isoYmdPrefix.firstMatch(trimmed);
    if (ymdMatch != null) {
      final year = int.parse(ymdMatch.group(1)!);
      final month = int.parse(ymdMatch.group(2)!);
      final day = int.parse(ymdMatch.group(3)!);
      final calendarCheck = DateTime.utc(year, month, day);
      if (calendarCheck.year != year ||
          calendarCheck.month != month ||
          calendarCheck.day != day) {
        throw FormatException(
          '$fieldPath: Calendar date does not exist in "$raw".',
        );
      }
    }
    return parsed;
  }
}
