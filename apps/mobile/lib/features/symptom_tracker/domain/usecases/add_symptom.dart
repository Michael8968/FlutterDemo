import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/symptom_entry.dart';
import '../repositories/symptom_repository.dart';

/// 添加症状用例
class AddSymptom {
  final SymptomRepository repository;

  AddSymptom(this.repository);

  Future<Either<Failure, SymptomEntry>> call(SymptomEntry entry) {
    return repository.addSymptom(entry);
  }
}
