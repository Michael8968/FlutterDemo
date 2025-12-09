import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/health_goal.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

/// 用户档案仓库实现
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final SyncManager? syncManager;

  ProfileRepositoryImpl({
    required this.localDataSource,
    this.syncManager,
  });

  String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

  @override
  Future<Either<Failure, UserProfile?>> getProfile() async {
    try {
      final model = await localDataSource.getProfile();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(CacheFailure( '获取档案失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> saveProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await localDataSource.saveProfile(model);

      // 添加到同步队列
      syncManager?.addPendingChange(PendingChange(
        id: profile.id,
        dataType: 'profile',
        changeType: ChangeType.create,
        data: model.toJson(),
      ));

      return Right(profile);
    } catch (e) {
      return Left(CacheFailure( '保存档案失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
      UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      final model = UserProfileModel.fromEntity(updatedProfile);
      await localDataSource.saveProfile(model);

      // 添加到同步队列
      syncManager?.addPendingChange(PendingChange(
        id: profile.id,
        dataType: 'profile',
        changeType: ChangeType.update,
        data: model.toJson(),
      ));

      return Right(updatedProfile);
    } catch (e) {
      return Left(CacheFailure( '更新档案失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> addHealthGoal(HealthGoal goal) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          final newGoal = HealthGoal(
            id: goal.id.isEmpty ? _generateId() : goal.id,
            type: goal.type,
            targetValue: goal.targetValue,
            currentValue: goal.currentValue,
            frequency: goal.frequency,
            startDate: goal.startDate,
            endDate: goal.endDate,
            isActive: goal.isActive,
            records: goal.records,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final updatedGoals = [...profile.healthGoals, newGoal];
          final updatedProfile = profile.copyWith(
            healthGoals: updatedGoals,
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '添加目标失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateHealthGoal(
      HealthGoal goal) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          final updatedGoals = profile.healthGoals.map((g) {
            if (g.id == goal.id) {
              return goal.copyWith(updatedAt: DateTime.now());
            }
            return g;
          }).toList();

          final updatedProfile = profile.copyWith(
            healthGoals: updatedGoals,
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '更新目标失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> deleteHealthGoal(String goalId) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          final updatedGoals =
              profile.healthGoals.where((g) => g.id != goalId).toList();
          final updatedProfile = profile.copyWith(
            healthGoals: updatedGoals,
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '删除目标失败: $e'));
    }
  }

  @override
  Future<Either<Failure, HealthGoal>> updateGoalProgress(
    String goalId,
    double value,
  ) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          HealthGoal? targetGoal;
          final updatedGoals = profile.healthGoals.map((g) {
            if (g.id == goalId) {
              targetGoal = g.copyWith(
                currentValue: value,
                updatedAt: DateTime.now(),
              );
              return targetGoal!;
            }
            return g;
          }).toList();

          if (targetGoal == null) {
            return const Left(CacheFailure('目标不存在'));
          }

          final updatedProfile = profile.copyWith(
            healthGoals: updatedGoals,
            updatedAt: DateTime.now(),
          );

          await updateProfile(updatedProfile);
          return Right(targetGoal!);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '更新进度失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> addAllergy(String allergy) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          if (profile.allergies.contains(allergy)) {
            return Right(profile);
          }

          final updatedProfile = profile.copyWith(
            allergies: [...profile.allergies, allergy],
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '添加过敏源失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> removeAllergy(String allergy) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          final updatedProfile = profile.copyWith(
            allergies: profile.allergies.where((a) => a != allergy).toList(),
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '删除过敏源失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> addChronicDisease(
      String disease) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          if (profile.chronicDiseases.contains(disease)) {
            return Right(profile);
          }

          final updatedProfile = profile.copyWith(
            chronicDiseases: [...profile.chronicDiseases, disease],
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '添加慢性病失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> removeChronicDisease(
      String disease) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          final updatedProfile = profile.copyWith(
            chronicDiseases:
                profile.chronicDiseases.where((d) => d != disease).toList(),
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '删除慢性病失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> addMedication(String medication) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          if (profile.medications.contains(medication)) {
            return Right(profile);
          }

          final updatedProfile = profile.copyWith(
            medications: [...profile.medications, medication],
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '添加药物失败: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> removeMedication(
      String medication) async {
    try {
      final profileResult = await getProfile();
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) async {
          if (profile == null) {
            return const Left(CacheFailure('档案不存在'));
          }

          final updatedProfile = profile.copyWith(
            medications:
                profile.medications.where((m) => m != medication).toList(),
            updatedAt: DateTime.now(),
          );

          return await updateProfile(updatedProfile);
        },
      );
    } catch (e) {
      return Left(CacheFailure( '删除药物失败: $e'));
    }
  }
}
