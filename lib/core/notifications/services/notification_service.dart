import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/notification_item.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> scheduleNotification(NotificationItem item);
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
}

class LocalNotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationServiceImpl([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _plugin.initialize(
      initializationSettings,
    );

    // Set up Android notification channels
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      const AndroidNotificationChannel classRemindersChannel = AndroidNotificationChannel(
        'class_reminders',
        'Class Reminders',
        description: 'Notifications sent before scheduled classes start.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel attendanceWarningsChannel = AndroidNotificationChannel(
        'attendance_warnings',
        'Attendance Warnings',
        description: 'Notifications sent when attendance falls near or below target threshold.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel weeklyReportsChannel = AndroidNotificationChannel(
        'weekly_reports',
        'Weekly Reports',
        description: 'Weekly summaries of class attendance.',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
      );

      await androidImplementation.createNotificationChannel(classRemindersChannel);
      await androidImplementation.createNotificationChannel(attendanceWarningsChannel);
      await androidImplementation.createNotificationChannel(weeklyReportsChannel);
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
  Future<void> scheduleNotification(NotificationItem item) async {
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
        channelDescription = 'Notifications sent before scheduled classes start.';
        importance = Importance.max;
        playSound = true;
        enableVibrate = true;
        break;
      case NotificationType.ATTENDANCE_WARNING:
      case NotificationType.LOW_ATTENDANCE_ALERT:
        channelId = 'attendance_warnings';
        channelName = 'Attendance Warnings';
        channelDescription = 'Notifications sent when attendance falls near or below target threshold.';
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

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: enableVibrate,
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

    await _plugin.zonedSchedule(
      item.id,
      item.title,
      item.body,
      scheduledTZDateTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: item.relatedId,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
