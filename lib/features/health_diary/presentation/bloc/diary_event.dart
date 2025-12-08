import 'package:equatable/equatable.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/mood_level.dart';

/// 日记事件基类
abstract class DiaryEvent extends Equatable {
  const DiaryEvent();

  @override
  List<Object?> get props => [];
}

/// 加载指定日期的日记
class LoadDiaryByDate extends DiaryEvent {
  final DateTime date;

  const LoadDiaryByDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// 加载最近的日记
class LoadRecentDiaries extends DiaryEvent {
  final int limit;

  const LoadRecentDiaries({this.limit = 7});

  @override
  List<Object?> get props => [limit];
}

/// 加载月份中有日记的日期
class LoadDatesWithDiary extends DiaryEvent {
  final DateTime month;

  const LoadDatesWithDiary(this.month);

  @override
  List<Object?> get props => [month];
}

/// 保存日记
class SaveDiaryEvent extends DiaryEvent {
  final DateTime date;
  final MoodLevel mood;
  final double? sleepHours;
  final SleepQuality? sleepQuality;
  final DateTime? bedTime;
  final DateTime? wakeTime;
  final int? stressLevel;
  final int? energyLevel;
  final int? waterIntake;
  final int? steps;
  final double? weight;
  final List<ActivityType> activities;
  final WeatherType? weather;
  final String? notes;
  final List<String> gratitudes;
  final List<GoalProgress> goals;

  const SaveDiaryEvent({
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
  });

  @override
  List<Object?> get props => [
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
      ];
}

/// 删除日记
class DeleteDiaryEvent extends DiaryEvent {
  final String id;

  const DeleteDiaryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 加载日记统计
class LoadDiarySummary extends DiaryEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadDiarySummary(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}
