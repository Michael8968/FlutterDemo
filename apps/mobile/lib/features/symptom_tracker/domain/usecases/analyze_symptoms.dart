import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/symptom_entry.dart';
import '../repositories/symptom_repository.dart';

/// 分析症状用例
class AnalyzeSymptoms {
  final SymptomRepository repository;

  AnalyzeSymptoms(this.repository);

  Future<Either<Failure, SymptomAnalysis>> call(
    DateTime startDate,
    DateTime endDate,
  ) {
    return repository.getSymptomAnalysis(startDate, endDate);
  }
}
