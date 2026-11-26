import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'actmind_test';

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) {},
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      'ActMind test reminders',
      description: 'A test reminder used to verify scheduled notifications.',
      importance: Importance.high,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);

    const toneChannels = [
      AndroidNotificationChannel('actmind_gentle', 'ActMind gentle reminders', description: 'Daily gentle reminders before a deadline.', importance: Importance.defaultImportance),
      AndroidNotificationChannel('actmind_reminder', 'ActMind reminders', description: 'Every-six-hour reminders for approaching deadlines.', importance: Importance.high),
      AndroidNotificationChannel('actmind_urgent', 'ActMind urgent reminders', description: 'Every-two-hour urgent reminders for imminent deadlines.', importance: Importance.high),
      AndroidNotificationChannel('actmind_very_urgent', 'ActMind very urgent reminders', description: 'Every-fifteen-minute reminders under one hour.', importance: Importance.max),
      AndroidNotificationChannel('actmind_overdue', 'ActMind overdue reminders', description: 'Every-thirty-minute reminders after a deadline.', importance: Importance.max),
    ];
    for (final toneChannel in toneChannels) {
      await android?.createNotificationChannel(toneChannel);
    }
  }

  static Future<bool> requestNotificationPermission() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false;
  }

  static Future<bool> requestExactAlarmPermission() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission() ??
        false;
  }

  static Future<void> scheduleTestNotification() async {
    await _plugin.zonedSchedule(
      id: 9001,
      title: 'ActMind test reminder',
      body: 'Your scheduled notification is working.',
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'ActMind test reminders',
          channelDescription: 'A test reminder used to verify scheduled notifications.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
