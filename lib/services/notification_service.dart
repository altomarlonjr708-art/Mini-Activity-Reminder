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

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<bool> requestNotificationPermission() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
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
