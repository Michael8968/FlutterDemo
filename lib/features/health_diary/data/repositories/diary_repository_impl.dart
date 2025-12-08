import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/mood_level.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_local_datasource.dart';
import '../models/diary_entry_model.dart';

/// 日记仓库实现
class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalDataSource localDataSource;

  DiaryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, DiaryEntry>> saveDiary(DiaryEntry entry) async {
    try {
      final model = DiaryEntryModel.fromEntity(entry);
      final result = await localDataSource.saveDiary(model);
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDiary(String id) async {
    try {
      await localDataSource.deleteDiary(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry>> getDiaryById(String id) async {
    try {
      final result = await localDataSource.getDiaryById(id);
      if (result == null) {
        return const Left(CacheFailure('Diary not found'));
      }
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry?>> getDiaryByDate(DateTime date) async {
    try {
      final result = await localDataSource.getDiaryByDate(date);
      return Right(result?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getDiariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final results = await localDataSource.getDiariesByDateRange(
        startDate,
        endDate,
      );
      return Right(results.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getRecentDiaries({
    int limit = 7,
  }) async {
    try {
      final results = await localDataSource.getRecentDiaries(limit: limit);
      return Right(results.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getDatesWithDiary(
    DateTime month,
  ) async {
    try {
      final dates = await localDataSource.getDatesWithDiary(month);
      return Right(dates);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DiarySummary>> getDiarySummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final results = await localDataSource.getDiariesByDateRange(
        startDate,
        endDate,
      );
      final entries = results.map((m) => m.toEntity()).toList();

      if (entries.isEmpty) {
        return Right(DiarySummary(
          startDate: startDate,
          endDate: endDate,
          totalDays: 0,
          averageMood: 0,
        ));
      }

      // 计算平均心情
      final avgMood = entries.map((e) => e.mood.value).reduce((a, b) => a + b) /
          entries.length;

      // 计算平均睡眠
      final sleepEntries = entries.where((e) => e.sleepHours != null);
      final avgSleep = sleepEntries.isNotEmpty
          ? sleepEntries.map((e) => e.sleepHours!).reduce((a, b) => a + b) /
              sleepEntries.length
          : null;

      // 计算平均压力
      final stressEntries = entries.where((e) => e.stressLevel != null);
      final avgStress = stressEntries.isNotEmpty
          ? stressEntries.map((e) => e.stressLevel!).reduce((a, b) => a + b) /
              stressEntries.length
          : null;

      // 计算平均精力
      final energyEntries = entries.where((e) => e.energyLevel != null);
      final avgEnergy = energyEntries.isNotEmpty
          ? energyEntries.map((e) => e.energyLevel!).reduce((a, b) => a + b) /
              energyEntries.length
          : null;

      // 心情分布
      final moodDist = <MoodLevel, int>{};
      for (final entry in entries) {
        moodDist[entry.mood] = (moodDist[entry.mood] ?? 0) + 1;
      }

      // 最常见活动
      final activityCounts = <ActivityType, int>{};
      for (final entry in entries) {
        for (final activity in entry.activities) {
          activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
        }
      }
      final sortedActivities = activityCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topActivities = sortedActivities.take(5).map((e) => e.key).toList();

      // 目标完成率
      var totalGoals = 0;
      var completedGoals = 0;
      for (final entry in entries) {
        totalGoals += entry.goals.length;
        completedGoals += entry.goals.where((g) => g.completed).length;
      }
      final goalRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

      return Right(DiarySummary(
        startDate: startDate,
        endDate: endDate,
        totalDays: entries.length,
        averageMood: avgMood,
        averageSleepHours: avgSleep,
        averageStress: avgStress,
        averageEnergy: avgEnergy,
        moodDistribution: moodDist,
        topActivities: topActivities,
        goalCompletionRate: goalRate,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> searchDiaries(String query) async {
    try {
      final results = await localDataSource.searchDiaries(query);
      return Right(results.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getDiariesByMood(
    MoodLevel mood, {
    int? limit,
  }) async {
    try {
      final allResults = await localDataSource.getRecentDiaries(limit: 1000);
      var filtered = allResults
          .where((m) => m.moodValue == mood.value)
          .map((m) => m.toEntity())
          .toList();
      if (limit != null && filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }
      return Right(filtered);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
