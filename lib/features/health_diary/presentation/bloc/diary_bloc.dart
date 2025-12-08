import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import 'diary_event.dart';
import 'diary_state.dart';

/// 日记 Bloc
class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final DiaryRepository repository;

  DiaryBloc({required this.repository}) : super(DiaryInitial()) {
    on<LoadDiaryByDate>(_onLoadDiaryByDate);
    on<LoadRecentDiaries>(_onLoadRecentDiaries);
    on<LoadDatesWithDiary>(_onLoadDatesWithDiary);
    on<SaveDiaryEvent>(_onSaveDiary);
    on<DeleteDiaryEvent>(_onDeleteDiary);
    on<LoadDiarySummary>(_onLoadDiarySummary);
    on<LoadDiaryRange>(_onLoadDiaryRange);
  }

  Future<void> _onLoadDiaryByDate(
    LoadDiaryByDate event,
    Emitter<DiaryState> emit,
  ) async {
    emit(DiaryLoading());
    final result = await repository.getDiaryByDate(event.date);
    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (entry) => emit(DiaryLoaded(
        entry: entry,
        selectedDate: event.date,
      )),
    );
  }

  Future<void> _onLoadRecentDiaries(
    LoadRecentDiaries event,
    Emitter<DiaryState> emit,
  ) async {
    emit(DiaryLoading());
    final result = await repository.getRecentDiaries(limit: event.limit);
    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (entries) => emit(DiaryListLoaded(entries)),
    );
  }

  Future<void> _onLoadDatesWithDiary(
    LoadDatesWithDiary event,
    Emitter<DiaryState> emit,
  ) async {
    final result = await repository.getDatesWithDiary(event.month);
    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (dates) => emit(DiaryDatesLoaded(dates: dates, month: event.month)),
    );
  }

  Future<void> _onSaveDiary(
    SaveDiaryEvent event,
    Emitter<DiaryState> emit,
  ) async {
    emit(DiaryLoading());

    // 先检查是否已有当天的日记
    final existingResult = await repository.getDiaryByDate(event.date);
    String id = '${DateTime.now().millisecondsSinceEpoch}';
    DateTime createdAt = DateTime.now();

    existingResult.fold(
      (failure) {},
      (existing) {
        if (existing != null) {
          id = existing.id;
          createdAt = existing.createdAt;
        }
      },
    );

    final entry = DiaryEntry(
      id: id,
      date: DateTime(event.date.year, event.date.month, event.date.day),
      mood: event.mood,
      sleepHours: event.sleepHours,
      sleepQuality: event.sleepQuality,
      bedTime: event.bedTime,
      wakeTime: event.wakeTime,
      stressLevel: event.stressLevel,
      energyLevel: event.energyLevel,
      waterIntake: event.waterIntake,
      steps: event.steps,
      weight: event.weight,
      activities: event.activities,
      weather: event.weather,
      notes: event.notes,
      gratitudes: event.gratitudes,
      goals: event.goals,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await repository.saveDiary(entry);
    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (savedEntry) => emit(DiaryOperationSuccess(
        message: '日记已保存',
        entry: savedEntry,
      )),
    );
  }

  Future<void> _onDeleteDiary(
    DeleteDiaryEvent event,
    Emitter<DiaryState> emit,
  ) async {
    emit(DiaryLoading());
    final result = await repository.deleteDiary(event.id);
    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (_) => emit(const DiaryOperationSuccess(message: '日记已删除')),
    );
  }

  Future<void> _onLoadDiarySummary(
    LoadDiarySummary event,
    Emitter<DiaryState> emit,
  ) async {
    emit(DiaryLoading());
    final result = await repository.getDiarySummary(
      event.startDate,
      event.endDate,
    );
    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (summary) => emit(DiarySummaryLoaded(summary)),
    );
  }

  Future<void> _onLoadDiaryRange(
    LoadDiaryRange event,
    Emitter<DiaryState> emit,
  ) async {
    final result = await repository.getDiariesByDateRange(
      event.startDate,
      event.endDate,
    );
    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (entries) => emit(DiaryRangeLoaded(
        entries: entries,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }
}
