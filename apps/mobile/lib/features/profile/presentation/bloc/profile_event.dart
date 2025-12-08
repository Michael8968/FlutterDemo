import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/health_goal.dart';

/// 个人档案事件基类
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// 加载档案
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// 保存档案
class SaveProfile extends ProfileEvent {
  final UserProfile profile;

  const SaveProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// 更新档案
class UpdateProfile extends ProfileEvent {
  final UserProfile profile;

  const UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// 添加健康目标
class AddGoal extends ProfileEvent {
  final HealthGoal goal;

  const AddGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

/// 更新健康目标
class UpdateGoal extends ProfileEvent {
  final HealthGoal goal;

  const UpdateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

/// 删除健康目标
class DeleteGoal extends ProfileEvent {
  final String goalId;

  const DeleteGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

/// 更新目标进度
class UpdateProgress extends ProfileEvent {
  final String goalId;
  final double value;

  const UpdateProgress(this.goalId, this.value);

  @override
  List<Object?> get props => [goalId, value];
}

/// 添加过敏源
class AddAllergy extends ProfileEvent {
  final String allergy;

  const AddAllergy(this.allergy);

  @override
  List<Object?> get props => [allergy];
}

/// 删除过敏源
class RemoveAllergy extends ProfileEvent {
  final String allergy;

  const RemoveAllergy(this.allergy);

  @override
  List<Object?> get props => [allergy];
}

/// 添加慢性病
class AddChronicDisease extends ProfileEvent {
  final String disease;

  const AddChronicDisease(this.disease);

  @override
  List<Object?> get props => [disease];
}

/// 删除慢性病
class RemoveChronicDisease extends ProfileEvent {
  final String disease;

  const RemoveChronicDisease(this.disease);

  @override
  List<Object?> get props => [disease];
}

/// 添加药物
class AddMedication extends ProfileEvent {
  final String medication;

  const AddMedication(this.medication);

  @override
  List<Object?> get props => [medication];
}

/// 删除药物
class RemoveMedication extends ProfileEvent {
  final String medication;

  const RemoveMedication(this.medication);

  @override
  List<Object?> get props => [medication];
}
