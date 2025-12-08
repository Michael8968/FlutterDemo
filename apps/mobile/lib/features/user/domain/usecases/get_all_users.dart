import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetAllUsers {
  final UserRepository repository;

  GetAllUsers(this.repository);

  Future<Either<Failure, List<User>>> call() async {
    return await repository.getAllUsers();
  }
}

