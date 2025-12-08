import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../entities/reminder.dart';

/// 通知服务
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化时区
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // Android 设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// 请求通知权限
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final ios = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// 调度提醒通知
  Future<void> scheduleReminder(Reminder reminder) async {
    if (!reminder.isEnabled) return;

    await cancelReminder(reminder.id);

    final notificationDetails = _getNotificationDetails(reminder.type);

    switch (reminder.repeatType) {
      case RepeatType.once:
        await _scheduleOnce(reminder, notificationDetails);
        break;
      case RepeatType.daily:
        await _scheduleDaily(reminder, notificationDetails);
        break;
      case RepeatType.weekdays:
        await _scheduleWeekdays(reminder, notificationDetails);
        break;
      case RepeatType.weekend:
        await _scheduleWeekend(reminder, notificationDetails);
        break;
      case RepeatType.custom:
        await _scheduleCustomDays(reminder, notificationDetails);
        break;
    }
  }

  /// 调度一次性提醒
  Future<void> _scheduleOnce(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    // 如果时间已过，调度到明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _getNotificationId(reminder.id, 0),
      reminder.title,
      reminder.message,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 调度每日提醒
  Future<void> _scheduleDaily(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    await _notifications.zonedSchedule(
      _getNotificationId(reminder.id, 0),
      reminder.title,
      reminder.message,
      _nextInstanceOfTime(reminder.hour, reminder.minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 调度工作日提醒
  Future<void> _scheduleWeekdays(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    for (int day = 1; day <= 5; day++) {
      await _notifications.zonedSchedule(
        _getNotificationId(reminder.id, day),
        reminder.title,
        reminder.message,
        _nextInstanceOfWeekday(day, reminder.hour, reminder.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// 调度周末提醒
  Future<void> _scheduleWeekend(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    // 周六
    await _notifications.zonedSchedule(
      _getNotificationId(reminder.id, 6),
      reminder.title,
      reminder.message,
      _nextInstanceOfWeekday(6, reminder.hour, reminder.minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    // 周日
    await _notifications.zonedSchedule(
      _getNotificationId(reminder.id, 0),
      reminder.title,
      reminder.message,
      _nextInstanceOfWeekday(7, reminder.hour, reminder.minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// 调度自定义日期提醒
  Future<void> _scheduleCustomDays(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    for (int day in reminder.customDays) {
      // customDays 使用 0-6 (周日-周六)，转换为 DateTime.weekday 格式 (1-7, 周一-周日)
      final weekday = day == 0 ? 7 : day;
      await _notifications.zonedSchedule(
        _getNotificationId(reminder.id, day),
        reminder.title,
        reminder.message,
        _nextInstanceOfWeekday(weekday, reminder.hour, reminder.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// 取消提醒
  Future<void> cancelReminder(String reminderId) async {
    // 取消所有可能的通知 (0-7 对应不同的星期)
    for (int i = 0; i <= 7; i++) {
      await _notifications.cancel(_getNotificationId(reminderId, i));
    }
  }

  /// 取消所有提醒
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  /// 获取下一个指定时间
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// 获取下一个指定星期的时间
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    var scheduledDate = _nextInstanceOfTime(hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// 生成通知 ID
  int _getNotificationId(String reminderId, int dayOffset) {
    return reminderId.hashCode + dayOffset;
  }

  /// 获取通知详情
  NotificationDetails _getNotificationDetails(ReminderType type) {
    String channelId;
    String channelName;

    switch (type) {
      case ReminderType.water:
        channelId = 'water_reminder';
        channelName = '喝水提醒';
        break;
      case ReminderType.medicine:
        channelId = 'medicine_reminder';
        channelName = '用药提醒';
        break;
      case ReminderType.exercise:
        channelId = 'exercise_reminder';
        channelName = '运动提醒';
        break;
      case ReminderType.sleep:
        channelId = 'sleep_reminder';
        channelName = '睡眠提醒';
        break;
      case ReminderType.diary:
        channelId = 'diary_reminder';
        channelName = '日记提醒';
        break;
      case ReminderType.meal:
        channelId = 'meal_reminder';
        channelName = '用餐提醒';
        break;
      case ReminderType.custom:
        channelId = 'custom_reminder';
        channelName = '自定义提醒';
        break;
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: '健康提醒通知',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// 通知点击回调
  void _onNotificationTapped(NotificationResponse response) {
    // 可以在这里处理通知点击事件
    // 例如跳转到相应页面
  }

  /// 发送即时通知（用于测试）
  Future<void> showTestNotification(Reminder reminder) async {
    final details = _getNotificationDetails(reminder.type);
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      reminder.title,
      reminder.message,
      details,
    );
  }
}
