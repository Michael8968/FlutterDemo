import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// 获取日记统计摘要用例
class GetDiarySummary {
  final DiaryRepository repository;

  GetDiarySummary(this.repository);

  Future<Either<Failure, DiarySummary>> call(
    DateTime startDate,
    DateTime endDate,
  ) {
    return repository.getDiarySummary(startDate, endDate);
  }
}
