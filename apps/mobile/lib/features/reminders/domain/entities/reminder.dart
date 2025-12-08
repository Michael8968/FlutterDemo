import 'package:equatable/equatable.dart';

/// 提醒类型
enum ReminderType {
  water('喝水提醒', 'water_drop', '该喝水了，保持身体水分充足'),
  medicine('用药提醒', 'medication', '记得按时服药'),
  exercise('运动提醒', 'fitness_center', '该活动一下了，久坐不利于健康'),
  sleep('睡眠提醒', 'bedtime', '该休息了，保证充足的睡眠'),
  diary('日记提醒', 'book', '记录今天的心情和健康状况'),
  meal('用餐提醒', 'restaurant', '该吃饭了，保持规律饮食'),
  custom('自定义提醒', 'notifications', '');

  final String displayName;
  final String iconName;
  final String defaultMessage;

  const ReminderType(this.displayName, this.iconName, this.defaultMessage);
}

/// 重复类型
enum RepeatType {
  once('仅一次'),
  daily('每天'),
  weekdays('工作日'),
  weekend('周末'),
  custom('自定义');

  final String displayName;

  const RepeatType(this.displayName);
}

/// 提醒实体
class Reminder extends Equatable {
  final String id;
  final ReminderType type;
  final String title;
  final String message;
  final int hour;
  final int minute;
  final RepeatType repeatType;
  final List<int> customDays; // 0-6 代表周日-周六
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  const Reminder({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.hour,
    required this.minute,
    this.repeatType = RepeatType.daily,
    this.customDays = const [],
    this.isEnabled = true,
    required this.createdAt,
    this.lastTriggered,
  });

  Reminder copyWith({
    String? id,
    ReminderType? type,
    String? title,
    String? message,
    int? hour,
    int? minute,
    RepeatType? repeatType,
    List<int>? customDays,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return Reminder(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatType: repeatType ?? this.repeatType,
      customDays: customDays ?? this.customDays,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  /// 获取时间显示字符串
  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 获取重复描述
  String get repeatDescription {
    switch (repeatType) {
      case RepeatType.once:
        return '仅一次';
      case RepeatType.daily:
        return '每天';
      case RepeatType.weekdays:
        return '工作日';
      case RepeatType.weekend:
        return '周末';
      case RepeatType.custom:
        if (customDays.isEmpty) return '未设置';
        final days = ['日', '一', '二', '三', '四', '五', '六'];
        final selectedDays = customDays.map((d) => '周${days[d]}').join('、');
        return selectedDays;
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        hour,
        minute,
        repeatType,
        customDays,
        isEnabled,
        createdAt,
        lastTriggered,
      ];
}

/// 预设提醒模板
class ReminderTemplate {
  final ReminderType type;
  final String defaultTitle;
  final String defaultMessage;
  final int defaultHour;
  final int defaultMinute;
  final RepeatType defaultRepeat;

  const ReminderTemplate({
    required this.type,
    required this.defaultTitle,
    required this.defaultMessage,
    required this.defaultHour,
    required this.defaultMinute,
    this.defaultRepeat = RepeatType.daily,
  });

  static List<ReminderTemplate> get templates => [
        const ReminderTemplate(
          type: ReminderType.water,
          defaultTitle: '喝水提醒',
          defaultMessage: '该喝水了，保持身体水分充足',
          defaultHour: 10,
          defaultMinute: 0,
        ),
        const ReminderTemplate(
          type: ReminderType.water,
          defaultTitle: '喝水提醒',
          defaultMessage: '下午记得补充水分',
          defaultHour: 15,
          defaultMinute: 0,
        ),
        const ReminderTemplate(
          type: ReminderType.exercise,
          defaultTitle: '运动提醒',
          defaultMessage: '该活动一下了，久坐不利于健康',
          defaultHour: 11,
          defaultMinute: 0,
          defaultRepeat: RepeatType.weekdays,
        ),
        const ReminderTemplate(
          type: ReminderType.sleep,
          defaultTitle: '睡眠提醒',
          defaultMessage: '该休息了，保证充足的睡眠',
          defaultHour: 22,
          defaultMinute: 30,
        ),
        const ReminderTemplate(
          type: ReminderType.diary,
          defaultTitle: '日记提醒',
          defaultMessage: '记录今天的心情和健康状况',
          defaultHour: 21,
          defaultMinute: 0,
        ),
        const ReminderTemplate(
          type: ReminderType.meal,
          defaultTitle: '午餐提醒',
          defaultMessage: '该吃午餐了，保持规律饮食',
          defaultHour: 12,
          defaultMinute: 0,
          defaultRepeat: RepeatType.weekdays,
        ),
      ];
}
