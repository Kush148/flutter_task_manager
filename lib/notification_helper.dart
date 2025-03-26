import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones(); // Initialize timezones

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Schedule notification
  static Future<void> scheduleNotification(
      int taskId, String taskTitle, DateTime taskDueDate) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      taskId,
      'Task Reminder',
      taskTitle,
      tz.TZDateTime.from(taskDueDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Reminders',
          channelDescription: 'Channel for task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Updated
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a scheduled notification
  static Future<void> cancelNotification(int taskId) async {
    await _flutterLocalNotificationsPlugin.cancel(taskId);
  }
}
