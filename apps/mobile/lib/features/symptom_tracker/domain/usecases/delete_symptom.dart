import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/symptom_repository.dart';

/// 删除症状记录用例
class DeleteSymptom {
  final SymptomRepository repository;

  DeleteSymptom(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteSymptom(id);
  }
}
