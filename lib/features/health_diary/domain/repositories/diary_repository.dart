import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../entities/mood_level.dart';

/// 日记仓库接口
abstract class DiaryRepository {
  /// 创建或更新日记条目
  Future<Either<Failure, DiaryEntry>> saveDiary(DiaryEntry entry);

  /// 删除日记条目
  Future<Either<Failure, void>> deleteDiary(String id);

  /// 根据ID获取日记
  Future<Either<Failure, DiaryEntry>> getDiaryById(String id);

  /// 获取指定日期的日记
  Future<Either<Failure, DiaryEntry?>> getDiaryByDate(DateTime date);

  /// 获取日期范围内的日记列表
  Future<Either<Failure, List<DiaryEntry>>> getDiariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// 获取最近的日记列表
  Future<Either<Failure, List<DiaryEntry>>> getRecentDiaries({int limit = 7});

  /// 获取有日记记录的日期列表（用于日历标记）
  Future<Either<Failure, List<DateTime>>> getDatesWithDiary(
    DateTime month,
  );

  /// 获取日记统计摘要
  Future<Either<Failure, DiarySummary>> getDiarySummary(
    DateTime startDate,
    DateTime endDate,
  );

  /// 搜索日记内容
  Future<Either<Failure, List<DiaryEntry>>> searchDiaries(String query);

  /// 按心情筛选日记
  Future<Either<Failure, List<DiaryEntry>>> getDiariesByMood(
    MoodLevel mood, {
    int? limit,
  });
}
