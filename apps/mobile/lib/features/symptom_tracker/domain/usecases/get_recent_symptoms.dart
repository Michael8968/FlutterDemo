import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/symptom_entry.dart';
import '../repositories/symptom_repository.dart';

/// 获取最近症状记录用例
class GetRecentSymptoms {
  final SymptomRepository repository;

  GetRecentSymptoms(this.repository);

  Future<Either<Failure, List<SymptomEntry>>> call({int limit = 10}) {
    return repository.getRecentSymptoms(limit: limit);
  }
}
