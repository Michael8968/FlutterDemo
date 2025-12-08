import 'package:equatable/equatable.dart';
import 'mood_level.dart';

/// 健康日记条目
class DiaryEntry extends Equatable {
  /// 唯一标识
  final String id;

  /// 日期（只保留年月日）
  final DateTime date;

  /// 心情等级 (1-5)
  final MoodLevel mood;

  /// 睡眠时长（小时）
  final double? sleepHours;

  /// 睡眠质量 (1-5)
  final SleepQuality? sleepQuality;

  /// 入睡时间
  final DateTime? bedTime;

  /// 起床时间
  final DateTime? wakeTime;

  /// 压力等级 (1-10)
  final int? stressLevel;

  /// 精力等级 (1-10)
  final int? energyLevel;

  /// 饮水量（毫升）
  final int? waterIntake;

  /// 步数
  final int? steps;

  /// 体重（公斤）
  final double? weight;

  /// 活动列表
  final List<ActivityType> activities;

  /// 天气
  final WeatherType? weather;

  /// 文字日记内容
  final String? notes;

  /// 今日感恩（正面思考）
  final List<String> gratitudes;

  /// 今日目标完成情况
  final List<GoalProgress> goals;

  /// 关联的症状ID列表
  final List<String> symptomIds;

  /// 照片路径列表
  final List<String> photoPaths;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  const DiaryEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.sleepHours,
    this.sleepQuality,
    this.bedTime,
    this.wakeTime,
    this.stressLevel,
    this.energyLevel,
    this.waterIntake,
    this.steps,
    this.weight,
    this.activities = const [],
    this.weather,
    this.notes,
    this.gratitudes = const [],
    this.goals = const [],
    this.symptomIds = const [],
    this.photoPaths = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// 获取压力等级描述
  String? get stressDescription {
    if (stressLevel == null) return null;
    if (stressLevel! <= 3) return '低压力';
    if (stressLevel! <= 6) return '中等压力';
    return '高压力';
  }

  /// 获取精力等级描述
  String? get energyDescription {
    if (energyLevel == null) return null;
    if (energyLevel! <= 3) return '精力不足';
    if (energyLevel! <= 6) return '精力一般';
    return '精力充沛';
  }

  /// 复制并更新
  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    MoodLevel? mood,
    double? sleepHours,
    SleepQuality? sleepQuality,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? stressLevel,
    int? energyLevel,
    int? waterIntake,
    int? steps,
    double? weight,
    List<ActivityType>? activities,
    WeatherType? weather,
    String? notes,
    List<String>? gratitudes,
    List<GoalProgress>? goals,
    List<String>? symptomIds,
    List<String>? photoPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      waterIntake: waterIntake ?? this.waterIntake,
      steps: steps ?? this.steps,
      weight: weight ?? this.weight,
      activities: activities ?? this.activities,
      weather: weather ?? this.weather,
      notes: notes ?? this.notes,
      gratitudes: gratitudes ?? this.gratitudes,
      goals: goals ?? this.goals,
      symptomIds: symptomIds ?? this.symptomIds,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        mood,
        sleepHours,
        sleepQuality,
        bedTime,
        wakeTime,
        stressLevel,
        energyLevel,
        waterIntake,
        steps,
        weight,
        activities,
        weather,
        notes,
        gratitudes,
        goals,
        symptomIds,
        photoPaths,
        createdAt,
        updatedAt,
      ];
}

/// 目标进度
class GoalProgress extends Equatable {
  final String title;
  final bool completed;
  final String? note;

  const GoalProgress({
    required this.title,
    this.completed = false,
    this.note,
  });

  GoalProgress copyWith({
    String? title,
    bool? completed,
    String? note,
  }) {
    return GoalProgress(
      title: title ?? this.title,
      completed: completed ?? this.completed,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [title, completed, note];
}

/// 日记统计摘要
class DiarySummary extends Equatable {
  /// 统计的日期范围
  final DateTime startDate;
  final DateTime endDate;

  /// 记录天数
  final int totalDays;

  /// 平均心情
  final double averageMood;

  /// 平均睡眠时长
  final double? averageSleepHours;

  /// 平均压力等级
  final double? averageStress;

  /// 平均精力等级
  final double? averageEnergy;

  /// 心情分布
  final Map<MoodLevel, int> moodDistribution;

  /// 最常见的活动
  final List<ActivityType> topActivities;

  /// 目标完成率
  final double goalCompletionRate;

  const DiarySummary({
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.averageMood,
    this.averageSleepHours,
    this.averageStress,
    this.averageEnergy,
    this.moodDistribution = const {},
    this.topActivities = const [],
    this.goalCompletionRate = 0,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalDays,
        averageMood,
        averageSleepHours,
        averageStress,
        averageEnergy,
        moodDistribution,
        topActivities,
        goalCompletionRate,
      ];
}
