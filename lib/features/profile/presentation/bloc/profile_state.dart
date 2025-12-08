import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

/// 个人档案状态基类
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// 加载中
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// 加载成功
class ProfileLoaded extends ProfileState {
  final UserProfile? profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// 保存成功
class ProfileSaved extends ProfileState {
  final UserProfile profile;

  const ProfileSaved(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// 错误状态
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 目标更新成功
class GoalUpdated extends ProfileState {
  final UserProfile profile;

  const GoalUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}
