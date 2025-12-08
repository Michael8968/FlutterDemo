import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// 个人档案 BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<SaveProfile>(_onSaveProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<UpdateProgress>(_onUpdateProgress);
    on<AddAllergy>(_onAddAllergy);
    on<RemoveAllergy>(_onRemoveAllergy);
    on<AddChronicDisease>(_onAddChronicDisease);
    on<RemoveChronicDisease>(_onRemoveChronicDisease);
    on<AddMedication>(_onAddMedication);
    on<RemoveMedication>(_onRemoveMedication);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.getProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.saveProfile(event.profile);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.updateProfile(event.profile);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onAddGoal(
    AddGoal event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.addHealthGoal(event.goal);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(GoalUpdated(profile)),
    );
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.updateHealthGoal(event.goal);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(GoalUpdated(profile)),
    );
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.deleteHealthGoal(event.goalId);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(GoalUpdated(profile)),
    );
  }

  Future<void> _onUpdateProgress(
    UpdateProgress event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.updateGoalProgress(
      event.goalId,
      event.value,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => add(const LoadProfile()),
    );
  }

  Future<void> _onAddAllergy(
    AddAllergy event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.addAllergy(event.allergy);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onRemoveAllergy(
    RemoveAllergy event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.removeAllergy(event.allergy);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onAddChronicDisease(
    AddChronicDisease event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.addChronicDisease(event.disease);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onRemoveChronicDisease(
    RemoveChronicDisease event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.removeChronicDisease(event.disease);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onAddMedication(
    AddMedication event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.addMedication(event.medication);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onRemoveMedication(
    RemoveMedication event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await repository.removeMedication(event.medication);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  /// 创建新的用户档案
  UserProfile createNewProfile() {
    final now = DateTime.now();
    return UserProfile(
      id: '${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
    );
  }
}
