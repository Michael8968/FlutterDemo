import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// 保存日记用例
class SaveDiary {
  final DiaryRepository repository;

  SaveDiary(this.repository);

  Future<Either<Failure, DiaryEntry>> call(DiaryEntry entry) {
    return repository.saveDiary(entry);
  }
}
