import 'package:hive/hive.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/mood_level.dart';

part 'diary_entry_model.g.dart';

@HiveType(typeId: 20)
class DiaryEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int moodValue;

  @HiveField(3)
  final double? sleepHours;

  @HiveField(4)
  final int? sleepQualityValue;

  @HiveField(5)
  final DateTime? bedTime;

  @HiveField(6)
  final DateTime? wakeTime;

  @HiveField(7)
  final int? stressLevel;

  @HiveField(8)
  final int? energyLevel;

  @HiveField(9)
  final int? waterIntake;

  @HiveField(10)
  final int? steps;

  @HiveField(11)
  final double? weight;

  @HiveField(12)
  final List<int> activityIndices;

  @HiveField(13)
  final int? weatherIndex;

  @HiveField(14)
  final String? notes;

  @HiveField(15)
  final List<String> gratitudes;

  @HiveField(16)
  final List<GoalProgressModel> goals;

  @HiveField(17)
  final List<String> symptomIds;

  @HiveField(18)
  final List<String> photoPaths;

  @HiveField(19)
  final DateTime createdAt;

  @HiveField(20)
  final DateTime? updatedAt;

  DiaryEntryModel({
    required this.id,
    required this.date,
    required this.moodValue,
    this.sleepHours,
    this.sleepQualityValue,
    this.bedTime,
    this.wakeTime,
    this.stressLevel,
    this.energyLevel,
    this.waterIntake,
    this.steps,
    this.weight,
    required this.activityIndices,
    this.weatherIndex,
    this.notes,
    required this.gratitudes,
    required this.goals,
    required this.symptomIds,
    required this.photoPaths,
    required this.createdAt,
    this.updatedAt,
  });

  factory DiaryEntryModel.fromEntity(DiaryEntry entity) {
    return DiaryEntryModel(
      id: entity.id,
      date: entity.date,
      moodValue: entity.mood.value,
      sleepHours: entity.sleepHours,
      sleepQualityValue: entity.sleepQuality?.value,
      bedTime: entity.bedTime,
      wakeTime: entity.wakeTime,
      stressLevel: entity.stressLevel,
      energyLevel: entity.energyLevel,
      waterIntake: entity.waterIntake,
      steps: entity.steps,
      weight: entity.weight,
      activityIndices: entity.activities.map((a) => a.index).toList(),
      weatherIndex: entity.weather?.index,
      notes: entity.notes,
      gratitudes: entity.gratitudes,
      goals: entity.goals.map((g) => GoalProgressModel.fromEntity(g)).toList(),
      symptomIds: entity.symptomIds,
      photoPaths: entity.photoPaths,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  DiaryEntry toEntity() {
    return DiaryEntry(
      id: id,
      date: date,
      mood: MoodLevel.fromValue(moodValue),
      sleepHours: sleepHours,
      sleepQuality: sleepQualityValue != null
          ? SleepQuality.fromValue(sleepQualityValue!)
          : null,
      bedTime: bedTime,
      wakeTime: wakeTime,
      stressLevel: stressLevel,
      energyLevel: energyLevel,
      waterIntake: waterIntake,
      steps: steps,
      weight: weight,
      activities: activityIndices.map((i) => ActivityType.values[i]).toList(),
      weather: weatherIndex != null ? WeatherType.values[weatherIndex!] : null,
      notes: notes,
      gratitudes: gratitudes,
      goals: goals.map((g) => g.toEntity()).toList(),
      symptomIds: symptomIds,
      photoPaths: photoPaths,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@HiveType(typeId: 21)
class GoalProgressModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final bool completed;

  @HiveField(2)
  final String? note;

  GoalProgressModel({
    required this.title,
    required this.completed,
    this.note,
  });

  factory GoalProgressModel.fromEntity(GoalProgress entity) {
    return GoalProgressModel(
      title: entity.title,
      completed: entity.completed,
      note: entity.note,
    );
  }

  GoalProgress toEntity() {
    return GoalProgress(
      title: title,
      completed: completed,
      note: note,
    );
  }
}
