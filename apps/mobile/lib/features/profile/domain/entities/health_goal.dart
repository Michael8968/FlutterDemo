import 'package:equatable/equatable.dart';

/// 健康目标类型
enum GoalType {
  sleep('睡眠', '💤', '小时/天'),
  exercise('运动', '🏃', '分钟/天'),
  water('喝水', '💧', '杯/天'),
  steps('步数', '👟', '步/天'),
  weight('体重', '⚖️', 'kg'),
  meditation('冥想', '🧘', '分钟/天'),
  reading('阅读', '📚', '分钟/天'),
  noPhone('少看手机', '📱', '小时/天');

  final String displayName;
  final String emoji;
  final String unit;

  const GoalType(this.displayName, this.emoji, this.unit);
}

/// 目标频率
enum GoalFrequency {
  daily('每天'),
  weekly('每周'),
  monthly('每月');

  final String displayName;

  const GoalFrequency(this.displayName);
}

/// 健康目标实体
class HealthGoal extends Equatable {
  final String id;
  final GoalType type;
  final double targetValue;
  final double currentValue;
  final GoalFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<GoalRecord> records;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthGoal({
    required this.id,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.frequency = GoalFrequency.daily,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.records = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 计算完成百分比
  double get completionPercentage {
    if (targetValue <= 0) return 0;
    final percentage = (currentValue / targetValue) * 100;
    return percentage > 100 ? 100 : percentage;
  }

  /// 是否已完成
  bool get isCompleted => currentValue >= targetValue;

  /// 剩余数值
  double get remaining {
    final diff = targetValue - currentValue;
    return diff > 0 ? diff : 0;
  }

  /// 获取进度描述
  String get progressDescription {
    return '${currentValue.toStringAsFixed(1)} / ${targetValue.toStringAsFixed(1)} ${type.unit}';
  }

  /// 连续完成天数
  int get streakDays {
    if (records.isEmpty) return 0;

    final sortedRecords = List<GoalRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (final record in sortedRecords) {
      if (!record.isCompleted) break;

      if (lastDate == null) {
        // 检查是否是今天或昨天
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final recordDate =
            DateTime(record.date.year, record.date.month, record.date.day);
        final diff = today.difference(recordDate).inDays;
        if (diff > 1) break;
        streak++;
        lastDate = recordDate;
      } else {
        final recordDate =
            DateTime(record.date.year, record.date.month, record.date.day);
        final diff = lastDate.difference(recordDate).inDays;
        if (diff != 1) break;
        streak++;
        lastDate = recordDate;
      }
    }

    return streak;
  }

  HealthGoal copyWith({
    String? id,
    GoalType? type,
    double? targetValue,
    double? currentValue,
    GoalFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<GoalRecord>? records,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      records: records ?? this.records,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        targetValue,
        currentValue,
        frequency,
        startDate,
        endDate,
        isActive,
        records,
        createdAt,
        updatedAt,
      ];
}

/// 目标记录
class GoalRecord extends Equatable {
  final String id;
  final DateTime date;
  final double value;
  final String? note;

  const GoalRecord({
    required this.id,
    required this.date,
    required this.value,
    this.note,
  });

  bool get isCompleted => value > 0;

  @override
  List<Object?> get props => [id, date, value, note];
}

/// 预设健康目标模板
class HealthGoalTemplates {
  static List<HealthGoal> get defaultGoals {
    final now = DateTime.now();
    return [
      HealthGoal(
        id: 'sleep_goal',
        type: GoalType.sleep,
        targetValue: 8,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'exercise_goal',
        type: GoalType.exercise,
        targetValue: 30,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'water_goal',
        type: GoalType.water,
        targetValue: 8,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'steps_goal',
        type: GoalType.steps,
        targetValue: 8000,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
