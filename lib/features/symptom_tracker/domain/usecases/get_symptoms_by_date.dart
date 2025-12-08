import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/symptom_entry.dart';
import '../repositories/symptom_repository.dart';

/// 获取指定日期症状用例
class GetSymptomsByDate {
  final SymptomRepository repository;

  GetSymptomsByDate(this.repository);

  Future<Either<Failure, List<SymptomEntry>>> call(DateTime date) {
    return repository.getSymptomsByDate(date);
  }
}

/// 获取日期范围内症状用例
class GetSymptomsByDateRange {
  final SymptomRepository repository;

  GetSymptomsByDateRange(this.repository);

  Future<Either<Failure, List<SymptomEntry>>> call(
    DateTime startDate,
    DateTime endDate,
  ) {
    return repository.getSymptomsByDateRange(startDate, endDate);
  }
}
