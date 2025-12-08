import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    try {
      // 先尝试从本地获取
      final localUser = await localDataSource.getUserById(id);
      if (localUser != null) {
        return Right(localUser);
      }

      // 从远程获取
      final remoteUser = await remoteDataSource.getUserById(id);
      
      // 缓存到本地
      await localDataSource.cacheUser(remoteUser);
      
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      // 先尝试从本地获取
      final localUsers = await localDataSource.getAllUsers();
      if (localUsers.isNotEmpty) {
        return Right(localUsers);
      }

      // 从远程获取
      final remoteUsers = await remoteDataSource.getAllUsers();
      
      // 缓存到本地
      await localDataSource.cacheUsers(remoteUsers);
      
      return Right(remoteUsers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> createUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await remoteDataSource.createUser(userModel);
      
      // 缓存到本地
      await localDataSource.cacheUser(createdUser);
      
      return Right(createdUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await remoteDataSource.deleteUser(id);
      await localDataSource.deleteUser(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('未知错误: ${e.toString()}'));
    }
  }
}

