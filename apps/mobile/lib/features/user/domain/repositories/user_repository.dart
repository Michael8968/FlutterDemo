import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUserById(String id);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, User>> createUser(User user);
  Future<Either<Failure, void>> deleteUser(String id);
}

