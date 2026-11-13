import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../handlers/notification_action_handler.dart';
import '../models/notification_item.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;
  if (actionId != null && actionId.isNotEmpty && payload != null) {
    await NotificationActionHandler.handleAction(
      actionId: actionId,
      payload: payload,
    );
  }
}

void onNotificationResponseForeground(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;
  if (actionId != null && actionId.isNotEmpty && payload != null) {
    await NotificationActionHandler.handleAction(
      actionId: actionId,
      payload: payload,
    );
  }
}

abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> scheduleNotification(NotificationItem item);
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
}

class LocalNotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;
  Future<void>? _inFlightInit;
  bool enableLateAttendance = false;

  LocalNotificationServiceImpl([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() {
    if (_isInitialized) {
      return Future<void>.value();
    }
    final inFlight = _inFlightInit;
    if (inFlight != null) {
      return inFlight;
    }

    late final Future<void> future;
    future = _performInitialize().whenComplete(() {
      if (identical(_inFlightInit, future)) {
        _inFlightInit = null;
      }
    });
    _inFlightInit = future;
    return future;
  }

  Future<void> _performInitialize() async {
    tz.initializeTimeZones();
    _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponseForeground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Set up Android notification channels
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      const AndroidNotificationChannel classRemindersChannel =
          AndroidNotificationChannel(
        'class_reminders',
        'Class Reminders',
        description: 'Notifications sent before scheduled classes start.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel attendanceWarningsChannel =
          AndroidNotificationChannel(
        'attendance_warnings',
        'Attendance Warnings',
        description:
            'Notifications sent when attendance falls near or below target threshold.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel weeklyReportsChannel =
          AndroidNotificationChannel(
        'weekly_reports',
        'Weekly Reports',
        description: 'Weekly summaries of class attendance.',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
      );

      const AndroidNotificationChannel defaultChannel =
          AndroidNotificationChannel(
        'default',
        'General Notifications',
        description: 'General app notifications.',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      );

      await androidImplementation
          .createNotificationChannel(classRemindersChannel);
      await androidImplementation
          .createNotificationChannel(attendanceWarningsChannel);
      await androidImplementation
          .createNotificationChannel(weeklyReportsChannel);
      await androidImplementation.createNotificationChannel(defaultChannel);
    }

    _isInitialized = true;
  }

  void _configureLocalTimeZone() {
    try {
      final currentTimeZone = DateTime.now().timeZoneName;
      if (tz.timeZoneDatabase.locations.containsKey(currentTimeZone)) {
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
        return;
      }
      final offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
      tz.Location? matched;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offsetMs) {
          matched = loc;
          break;
        }
      }
      if (matched != null) {
        tz.setLocalLocation(matched);
      }
    } catch (e) {
      debugPrint('Could not set local timezone location: $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    final bool? iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final bool? androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return (iosGranted ?? false) || (androidGranted ?? false);
  }

  @override
  Future<void> scheduleNotification(
    NotificationItem item, {
    bool? enableLateAttendance,
  }) async {
    final useLate = enableLateAttendance ?? this.enableLateAttendance;
    final int notificationId = item.effectiveAndroidNotificationId;
    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
      item.scheduledTime.toLocal(),
      tz.local,
    );

    String channelId;
    String channelName;
    String channelDescription;
    Importance importance;
    bool playSound;
    bool enableVibrate;

    final type = NotificationType.fromString(item.type);
    switch (type) {
      case NotificationType.CLASS_REMINDER:
        channelId = 'class_reminders';
        channelName = 'Class Reminders';
        channelDescription =
            'Notifications sent before scheduled classes start.';
        importance = Importance.max;
        playSound = true;
        enableVibrate = true;
        break;
      case NotificationType.ATTENDANCE_WARNING:
      case NotificationType.LOW_ATTENDANCE_ALERT:
        channelId = 'attendance_warnings';
        channelName = 'Attendance Warnings';
        channelDescription =
            'Notifications sent when attendance falls near or below target threshold.';
        importance = Importance.max;
        playSound = true;
        enableVibrate = true;
        break;
      case NotificationType.WEEKLY_REPORT:
        channelId = 'weekly_reports';
        channelName = 'Weekly Reports';
        channelDescription = 'Weekly summaries of class attendance.';
        importance = Importance.defaultImportance;
        playSound = true;
        enableVibrate = false;
        break;
      default:
        channelId = 'default';
        channelName = 'General Notifications';
        channelDescription = 'General app notifications.';
        importance = Importance.defaultImportance;
        playSound = true;
        enableVibrate = false;
    }

    List<AndroidNotificationAction>? actions;
    if (type == NotificationType.CLASS_REMINDER) {
      actions = [
        const AndroidNotificationAction(
          NotificationActionHandler.actionPresent,
          'PRESENT',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          NotificationActionHandler.actionAbsent,
          'ABSENT',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          NotificationActionHandler.actionCancelled,
          'CANCELLED',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        if (useLate)
          const AndroidNotificationAction(
            NotificationActionHandler.actionLate,
            'LATE',
            showsUserInterface: false,
            cancelNotification: true,
          ),
      ];
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: enableVibrate,
      actions: actions,
      ongoing: type == NotificationType.CLASS_REMINDER,
      autoCancel: true,
      category: type == NotificationType.CLASS_REMINDER
          ? AndroidNotificationCategory.reminder
          : null,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.zonedSchedule(
        notificationId,
        item.title,
        item.body,
        scheduledTZDateTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: item.relatedId,
      );
    } catch (e) {
      debugPrint(
          'Exact notification scheduling failed (e.g., SecurityException on Android 14+): $e');
      debugPrint('Attempting fallback to inexact notification scheduling...');
      try {
        await _plugin.zonedSchedule(
          notificationId,
          item.title,
          item.body,
          scheduledTZDateTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: item.relatedId,
        );
        debugPrint('Inexact notification scheduling fallback succeeded.');
      } catch (fallbackError) {
        debugPrint(
            'Fallback notification scheduling also failed: $fallbackError');
      }
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(NotificationItem.normalizeAndroidId(id));
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
