import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/services/notification_service.dart';

/// 提醒数据仓库
class ReminderRepository {
  static const String _storageKey = 'health_reminders';
  final NotificationService _notificationService = NotificationService();

  /// 获取所有提醒
  Future<List<Reminder>> getAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => _fromJson(item)).toList();
  }

  /// 保存提醒
  Future<void> saveReminder(Reminder reminder) async {
    final reminders = await getAllReminders();
    final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);

    if (existingIndex >= 0) {
      reminders[existingIndex] = reminder;
    } else {
      reminders.add(reminder);
    }

    await _saveAllReminders(reminders);

    // 调度通知
    if (reminder.isEnabled) {
      await _notificationService.scheduleReminder(reminder);
    } else {
      await _notificationService.cancelReminder(reminder.id);
    }
  }

  /// 删除提醒
  Future<void> deleteReminder(String id) async {
    final reminders = await getAllReminders();
    reminders.removeWhere((r) => r.id == id);
    await _saveAllReminders(reminders);

    // 取消通知
    await _notificationService.cancelReminder(id);
  }

  /// 切换提醒状态
  Future<void> toggleReminder(String id, bool isEnabled) async {
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == id);

    if (index >= 0) {
      reminders[index] = reminders[index].copyWith(isEnabled: isEnabled);
      await _saveAllReminders(reminders);

      if (isEnabled) {
        await _notificationService.scheduleReminder(reminders[index]);
      } else {
        await _notificationService.cancelReminder(id);
      }
    }
  }

  /// 重新调度所有启用的提醒
  Future<void> rescheduleAllReminders() async {
    final reminders = await getAllReminders();
    for (final reminder in reminders) {
      if (reminder.isEnabled) {
        await _notificationService.scheduleReminder(reminder);
      }
    }
  }

  /// 保存所有提醒到存储
  Future<void> _saveAllReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reminders.map((r) => _toJson(r)).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  /// 转换为 JSON
  Map<String, dynamic> _toJson(Reminder reminder) {
    return {
      'id': reminder.id,
      'type': reminder.type.index,
      'title': reminder.title,
      'message': reminder.message,
      'hour': reminder.hour,
      'minute': reminder.minute,
      'repeatType': reminder.repeatType.index,
      'customDays': reminder.customDays,
      'isEnabled': reminder.isEnabled,
      'createdAt': reminder.createdAt.toIso8601String(),
      'lastTriggered': reminder.lastTriggered?.toIso8601String(),
    };
  }

  /// 从 JSON 转换
  Reminder _fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      type: ReminderType.values[json['type']],
      title: json['title'],
      message: json['message'],
      hour: json['hour'],
      minute: json['minute'],
      repeatType: RepeatType.values[json['repeatType']],
      customDays: List<int>.from(json['customDays'] ?? []),
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
    );
  }
}
