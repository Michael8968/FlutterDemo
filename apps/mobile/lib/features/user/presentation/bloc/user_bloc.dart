import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_by_id.dart';
import '../../domain/usecases/get_all_users.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserById getUserById;
  final GetAllUsers getAllUsers;
  final UserRepository userRepository;

  UserBloc({
    required this.getUserById,
    required this.getAllUsers,
    required this.userRepository,
  }) : super(UserInitial()) {
    on<LoadUserById>(_onLoadUserById);
    on<LoadAllUsers>(_onLoadAllUsers);
    on<CreateUser>(_onCreateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadUserById(
    LoadUserById event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await getUserById(event.id);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user: user)),
    );
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await getAllUsers();
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (users) => emit(UserLoaded(users: users)),
    );
  }

  Future<void> _onCreateUser(
    CreateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      email: event.email,
    );
    final result = await userRepository.createUser(user);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (createdUser) => emit(UserLoaded(user: createdUser)),
    );
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await userRepository.deleteUser(event.id);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) {
        // 删除成功后重新加载列表
        add(const LoadAllUsers());
      },
    );
  }
}

