import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// 获取指定日期日记用例
class GetDiaryByDate {
  final DiaryRepository repository;

  GetDiaryByDate(this.repository);

  Future<Either<Failure, DiaryEntry?>> call(DateTime date) {
    return repository.getDiaryByDate(date);
  }
}

/// 获取日期范围内日记用例
class GetDiariesByDateRange {
  final DiaryRepository repository;

  GetDiariesByDateRange(this.repository);

  Future<Either<Failure, List<DiaryEntry>>> call(
    DateTime startDate,
    DateTime endDate,
  ) {
    return repository.getDiariesByDateRange(startDate, endDate);
  }
}

/// 获取最近日记用例
class GetRecentDiaries {
  final DiaryRepository repository;

  GetRecentDiaries(this.repository);

  Future<Either<Failure, List<DiaryEntry>>> call({int limit = 7}) {
    return repository.getRecentDiaries(limit: limit);
  }
}
