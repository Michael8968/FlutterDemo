import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../entities/health_goal.dart';

/// 用户档案仓库接口
abstract class ProfileRepository {
  /// 获取用户档案
  Future<Either<Failure, UserProfile?>> getProfile();

  /// 保存用户档案
  Future<Either<Failure, UserProfile>> saveProfile(UserProfile profile);

  /// 更新用户档案
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  /// 添加健康目标
  Future<Either<Failure, UserProfile>> addHealthGoal(HealthGoal goal);

  /// 更新健康目标
  Future<Either<Failure, UserProfile>> updateHealthGoal(HealthGoal goal);

  /// 删除健康目标
  Future<Either<Failure, UserProfile>> deleteHealthGoal(String goalId);

  /// 更新目标进度
  Future<Either<Failure, HealthGoal>> updateGoalProgress(
    String goalId,
    double value,
  );

  /// 添加过敏源
  Future<Either<Failure, UserProfile>> addAllergy(String allergy);

  /// 删除过敏源
  Future<Either<Failure, UserProfile>> removeAllergy(String allergy);

  /// 添加慢性病
  Future<Either<Failure, UserProfile>> addChronicDisease(String disease);

  /// 删除慢性病
  Future<Either<Failure, UserProfile>> removeChronicDisease(String disease);

  /// 添加药物
  Future<Either<Failure, UserProfile>> addMedication(String medication);

  /// 删除药物
  Future<Either<Failure, UserProfile>> removeMedication(String medication);
}
