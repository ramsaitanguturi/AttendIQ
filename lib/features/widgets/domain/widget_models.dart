import 'dart:convert';

class TodayWidgetItem {
  final String subjectName;
  final String startTime;
  final String endTime;
  final String? room;
  final String status; // 'PRESENT', 'ABSENT', 'CANCELLED', 'UPCOMING'

  const TodayWidgetItem({
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'status': status,
    };
  }

  factory TodayWidgetItem.fromMap(Map<String, dynamic> map) {
    return TodayWidgetItem(
      subjectName: map['subjectName'] as String? ?? '',
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
      room: map['room'] as String?,
      status: map['status'] as String? ?? 'UPCOMING',
    );
  }

  String toJson() => jsonEncode(toMap());
  factory TodayWidgetItem.fromJson(String source) =>
      TodayWidgetItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class TodayWidgetData {
  final String dateText;
  final bool isHoliday;
  final String? holidayTitle;
  final TodayWidgetItem? nextClass;
  final List<TodayWidgetItem> classes;

  const TodayWidgetData({
    required this.dateText,
    this.isHoliday = false,
    this.holidayTitle,
    this.nextClass,
    this.classes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'dateText': dateText,
      'isHoliday': isHoliday,
      'holidayTitle': holidayTitle,
      'nextClass': nextClass?.toMap(),
      'classes': classes.map((x) => x.toMap()).toList(),
    };
  }

  factory TodayWidgetData.fromMap(Map<String, dynamic> map) {
    return TodayWidgetData(
      dateText: map['dateText'] as String? ?? '',
      isHoliday: map['isHoliday'] as bool? ?? false,
      holidayTitle: map['holidayTitle'] as String?,
      nextClass: map['nextClass'] != null
          ? TodayWidgetItem.fromMap(map['nextClass'] as Map<String, dynamic>)
          : null,
      classes: (map['classes'] as List<dynamic>?)
              ?.map((x) => TodayWidgetItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory TodayWidgetData.fromJson(String source) =>
      TodayWidgetData.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class WeeklyWidgetClass {
  final String subjectName;
  final String startTime;
  final String endTime;
  final bool isCancelled;
  final bool isExtra;

  const WeeklyWidgetClass({
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    this.isCancelled = false,
    this.isExtra = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'startTime': startTime,
      'endTime': endTime,
      'isCancelled': isCancelled,
      'isExtra': isExtra,
    };
  }

  factory WeeklyWidgetClass.fromMap(Map<String, dynamic> map) {
    return WeeklyWidgetClass(
      subjectName: map['subjectName'] as String? ?? '',
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
      isCancelled: map['isCancelled'] as bool? ?? false,
      isExtra: map['isExtra'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WeeklyWidgetClass.fromJson(String source) =>
      WeeklyWidgetClass.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class WeeklyWidgetDay {
  final String dayName; // 'MON', 'TUE', etc.
  final String dateText;
  final bool isHoliday;
  final String? holidayTitle;
  final List<WeeklyWidgetClass> classes;

  const WeeklyWidgetDay({
    required this.dayName,
    required this.dateText,
    this.isHoliday = false,
    this.holidayTitle,
    this.classes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'dateText': dateText,
      'isHoliday': isHoliday,
      'holidayTitle': holidayTitle,
      'classes': classes.map((x) => x.toMap()).toList(),
    };
  }

  factory WeeklyWidgetDay.fromMap(Map<String, dynamic> map) {
    return WeeklyWidgetDay(
      dayName: map['dayName'] as String? ?? '',
      dateText: map['dateText'] as String? ?? '',
      isHoliday: map['isHoliday'] as bool? ?? false,
      holidayTitle: map['holidayTitle'] as String?,
      classes: (map['classes'] as List<dynamic>?)
              ?.map((x) => WeeklyWidgetClass.fromMap(x as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WeeklyWidgetDay.fromJson(String source) =>
      WeeklyWidgetDay.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class WeeklyWidgetData {
  final String weekTitle; // e.g. "Week 5"
  final List<WeeklyWidgetDay> days;

  const WeeklyWidgetData({
    required this.weekTitle,
    this.days = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'weekTitle': weekTitle,
      'days': days.map((x) => x.toMap()).toList(),
    };
  }

  factory WeeklyWidgetData.fromMap(Map<String, dynamic> map) {
    return WeeklyWidgetData(
      weekTitle: map['weekTitle'] as String? ?? '',
      days: (map['days'] as List<dynamic>?)
              ?.map((x) => WeeklyWidgetDay.fromMap(x as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WeeklyWidgetData.fromJson(String source) =>
      WeeklyWidgetData.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class MonthWidgetDay {
  final int dayNumber;
  final String dateString;
  final bool isToday;
  final bool hasClasses; // Green
  final bool hasExams; // Red
  final bool hasTasks; // Orange
  final bool hasHolidays; // Yellow
  final bool hasEvents; // Purple

  const MonthWidgetDay({
    required this.dayNumber,
    required this.dateString,
    this.isToday = false,
    this.hasClasses = false,
    this.hasExams = false,
    this.hasTasks = false,
    this.hasHolidays = false,
    this.hasEvents = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'dateString': dateString,
      'isToday': isToday,
      'hasClasses': hasClasses,
      'hasExams': hasExams,
      'hasTasks': hasTasks,
      'hasHolidays': hasHolidays,
      'hasEvents': hasEvents,
    };
  }

  factory MonthWidgetDay.fromMap(Map<String, dynamic> map) {
    return MonthWidgetDay(
      dayNumber: map['dayNumber'] as int? ?? 1,
      dateString: map['dateString'] as String? ?? '',
      isToday: map['isToday'] as bool? ?? false,
      hasClasses: map['hasClasses'] as bool? ?? false,
      hasExams: map['hasExams'] as bool? ?? false,
      hasTasks: map['hasTasks'] as bool? ?? false,
      hasHolidays: map['hasHolidays'] as bool? ?? false,
      hasEvents: map['hasEvents'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory MonthWidgetDay.fromJson(String source) =>
      MonthWidgetDay.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class MonthUpcomingItem {
  final String dateText; // e.g. "22 July"
  final String title;
  final String type; // 'EXAM', 'TASK', 'HOLIDAY', 'EVENT'

  const MonthUpcomingItem({
    required this.dateText,
    required this.title,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateText': dateText,
      'title': title,
      'type': type,
    };
  }

  factory MonthUpcomingItem.fromMap(Map<String, dynamic> map) {
    return MonthUpcomingItem(
      dateText: map['dateText'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? 'EVENT',
    );
  }

  String toJson() => jsonEncode(toMap());
  factory MonthUpcomingItem.fromJson(String source) =>
      MonthUpcomingItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class MonthWidgetData {
  final String monthTitle; // e.g. "July 2026"
  final List<MonthWidgetDay> days;
  final List<MonthUpcomingItem> upcomingItems;

  const MonthWidgetData({
    required this.monthTitle,
    this.days = const [],
    this.upcomingItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'monthTitle': monthTitle,
      'days': days.map((x) => x.toMap()).toList(),
      'upcomingItems': upcomingItems.map((x) => x.toMap()).toList(),
    };
  }

  factory MonthWidgetData.fromMap(Map<String, dynamic> map) {
    return MonthWidgetData(
      monthTitle: map['monthTitle'] as String? ?? '',
      days: (map['days'] as List<dynamic>?)
              ?.map((x) => MonthWidgetDay.fromMap(x as Map<String, dynamic>))
              .toList() ??
          const [],
      upcomingItems: (map['upcomingItems'] as List<dynamic>?)
              ?.map((x) => MonthUpcomingItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory MonthWidgetData.fromJson(String source) =>
      MonthWidgetData.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class WidgetSettingsModel {
  final bool enabled;
  final String refreshFrequency; // 'auto', '1h', '6h'

  const WidgetSettingsModel({
    this.enabled = true,
    this.refreshFrequency = 'auto',
  });

  WidgetSettingsModel copyWith({
    bool? enabled,
    String? refreshFrequency,
  }) {
    return WidgetSettingsModel(
      enabled: enabled ?? this.enabled,
      refreshFrequency: refreshFrequency ?? this.refreshFrequency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'refreshFrequency': refreshFrequency,
    };
  }

  factory WidgetSettingsModel.fromMap(Map<String, dynamic> map) {
    return WidgetSettingsModel(
      enabled: map['enabled'] as bool? ?? true,
      refreshFrequency: map['refreshFrequency'] as String? ?? 'auto',
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WidgetSettingsModel.fromJson(String source) =>
      WidgetSettingsModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
