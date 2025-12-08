import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/symptom_entry.dart';
import '../../domain/repositories/symptom_repository.dart';
import 'symptom_event.dart';
import 'symptom_state.dart';

/// 症状 Bloc
class SymptomBloc extends Bloc<SymptomEvent, SymptomState> {
  final SymptomRepository repository;

  SymptomBloc({required this.repository}) : super(SymptomInitial()) {
    on<LoadRecentSymptoms>(_onLoadRecentSymptoms);
    on<LoadSymptomsByDate>(_onLoadSymptomsByDate);
    on<LoadSymptomsByDateRange>(_onLoadSymptomsByDateRange);
    on<AddSymptomEvent>(_onAddSymptom);
    on<UpdateSymptomEvent>(_onUpdateSymptom);
    on<DeleteSymptomEvent>(_onDeleteSymptom);
    on<SearchSymptoms>(_onSearchSymptoms);
    on<LoadSymptomAnalysis>(_onLoadSymptomAnalysis);
    on<MarkSymptomEnded>(_onMarkSymptomEnded);
  }

  Future<void> _onLoadRecentSymptoms(
    LoadRecentSymptoms event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());
    final result = await repository.getRecentSymptoms(limit: event.limit);
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (symptoms) => emit(SymptomLoaded(symptoms: symptoms)),
    );
  }

  Future<void> _onLoadSymptomsByDate(
    LoadSymptomsByDate event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());
    final result = await repository.getSymptomsByDate(event.date);
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (symptoms) => emit(SymptomLoaded(
        symptoms: symptoms,
        selectedDate: event.date,
      )),
    );
  }

  Future<void> _onLoadSymptomsByDateRange(
    LoadSymptomsByDateRange event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());
    final result = await repository.getSymptomsByDateRange(
      event.startDate,
      event.endDate,
    );
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (symptoms) => emit(SymptomLoaded(symptoms: symptoms)),
    );
  }

  Future<void> _onAddSymptom(
    AddSymptomEvent event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());

    final now = DateTime.now();
    final entry = SymptomEntry(
      id: '${now.millisecondsSinceEpoch}',
      timestamp: now,
      symptomName: event.symptomName,
      templateId: event.templateId,
      type: event.type,
      severity: event.severity,
      bodyParts: event.bodyParts,
      durationMinutes: event.durationMinutes,
      triggers: event.triggers,
      notes: event.notes,
      isOngoing: event.isOngoing,
      createdAt: now,
    );

    final result = await repository.addSymptom(entry);
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (savedEntry) => emit(SymptomOperationSuccess(
        message: '症状记录已保存',
        entry: savedEntry,
      )),
    );
  }

  Future<void> _onUpdateSymptom(
    UpdateSymptomEvent event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());

    final updatedEntry = event.entry.copyWith(updatedAt: DateTime.now());
    final result = await repository.updateSymptom(updatedEntry);
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (savedEntry) => emit(SymptomOperationSuccess(
        message: '症状记录已更新',
        entry: savedEntry,
      )),
    );
  }

  Future<void> _onDeleteSymptom(
    DeleteSymptomEvent event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());
    final result = await repository.deleteSymptom(event.id);
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (_) => emit(const SymptomOperationSuccess(message: '症状记录已删除')),
    );
  }

  Future<void> _onSearchSymptoms(
    SearchSymptoms event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());
    final result = await repository.searchSymptoms(event.query);
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (symptoms) => emit(SymptomLoaded(symptoms: symptoms)),
    );
  }

  Future<void> _onLoadSymptomAnalysis(
    LoadSymptomAnalysis event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());
    final result = await repository.getSymptomAnalysis(
      event.startDate,
      event.endDate,
    );
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (analysis) => emit(SymptomAnalysisLoaded(analysis)),
    );
  }

  Future<void> _onMarkSymptomEnded(
    MarkSymptomEnded event,
    Emitter<SymptomState> emit,
  ) async {
    emit(SymptomLoading());
    final result = await repository.markSymptomEnded(
      event.id,
      event.durationMinutes,
    );
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (entry) => emit(SymptomOperationSuccess(
        message: '症状已标记结束',
        entry: entry,
      )),
    );
  }
}
