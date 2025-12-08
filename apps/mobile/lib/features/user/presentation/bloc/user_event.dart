import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserById extends UserEvent {
  final String id;

  const LoadUserById(this.id);

  @override
  List<Object> get props => [id];
}

class LoadAllUsers extends UserEvent {
  const LoadAllUsers();
}

class CreateUser extends UserEvent {
  final String name;
  final String email;

  const CreateUser({
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [name, email];
}

class DeleteUser extends UserEvent {
  final String id;

  const DeleteUser(this.id);

  @override
  List<Object> get props => [id];
}

