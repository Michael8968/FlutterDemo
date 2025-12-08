import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../entities/health_goal.dart';
import '../repositories/profile_repository.dart';

/// 添加健康目标用例
class AddHealthGoal {
  final ProfileRepository repository;

  AddHealthGoal(this.repository);

  Future<Either<Failure, UserProfile>> call(HealthGoal goal) {
    return repository.addHealthGoal(goal);
  }
}

/// 更新健康目标用例
class UpdateHealthGoal {
  final ProfileRepository repository;

  UpdateHealthGoal(this.repository);

  Future<Either<Failure, UserProfile>> call(HealthGoal goal) {
    return repository.updateHealthGoal(goal);
  }
}

/// 删除健康目标用例
class DeleteHealthGoal {
  final ProfileRepository repository;

  DeleteHealthGoal(this.repository);

  Future<Either<Failure, UserProfile>> call(String goalId) {
    return repository.deleteHealthGoal(goalId);
  }
}

/// 更新目标进度用例
class UpdateGoalProgress {
  final ProfileRepository repository;

  UpdateGoalProgress(this.repository);

  Future<Either<Failure, HealthGoal>> call(String goalId, double value) {
    return repository.updateGoalProgress(goalId, value);
  }
}
