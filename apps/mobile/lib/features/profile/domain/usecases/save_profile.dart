import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// 保存用户档案用例
class SaveProfile {
  final ProfileRepository repository;

  SaveProfile(this.repository);

  Future<Either<Failure, UserProfile>> call(UserProfile profile) {
    return repository.saveProfile(profile);
  }
}
