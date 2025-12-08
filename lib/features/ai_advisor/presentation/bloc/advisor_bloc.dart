import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../health_diary/domain/repositories/diary_repository.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import '../../../symptom_tracker/domain/repositories/symptom_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/health_advice.dart';
import '../../domain/services/health_analyzer.dart';
import 'advisor_event.dart';
import 'advisor_state.dart';

/// AI 健康建议 Bloc
class AdvisorBloc extends Bloc<AdvisorEvent, AdvisorState> {
  final DiaryRepository diaryRepository;
  final SymptomRepository symptomRepository;
  final ProfileRepository profileRepository;
  final HealthAnalyzer _analyzer = HealthAnalyzer();

  HealthReport? _currentReport;

  AdvisorBloc({
    required this.diaryRepository,
    required this.symptomRepository,
    required this.profileRepository,
  }) : super(const AdvisorInitial()) {
    on<GenerateHealthReport>(_onGenerateHealthReport);
    on<MarkAdviceRead>(_onMarkAdviceRead);
    on<DismissAdvice>(_onDismissAdvice);
    on<RefreshAdvices>(_onRefreshAdvices);
  }

  Future<void> _onGenerateHealthReport(
    GenerateHealthReport event,
    Emitter<AdvisorState> emit,
  ) async {
    emit(const AdvisorLoading());

    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: event.days));

      // 获取日记数据
      final diaryResult = await diaryRepository.getDiariesByDateRange(
        startDate,
        now,
      );

      // 获取症状数据
      final symptomResult = await symptomRepository.getSymptomsByDateRange(
        startDate,
        now,
      );

      // 获取用户档案
      final profileResult = await profileRepository.getProfile();

      // 分析数据
      final diaries = diaryResult.fold(
        (_) => <DiaryEntry>[],
        (d) => d,
      );
      final symptoms = symptomResult.fold(
        (_) => <SymptomEntry>[],
        (s) => s,
      );
      final profile = profileResult.fold((_) => null, (p) => p);

      final report = _analyzer.analyzeHealth(
        recentDiaries: diaries,
        recentSymptoms: symptoms,
        profile: profile,
        goals: profile?.healthGoals,
      );

      _currentReport = report;
      emit(AdvisorLoaded(report));
    } catch (e) {
      emit(AdvisorError('生成健康报告失败: $e'));
    }
  }

  Future<void> _onMarkAdviceRead(
    MarkAdviceRead event,
    Emitter<AdvisorState> emit,
  ) async {
    if (_currentReport == null) return;

    final updatedAdvices = _currentReport!.advices.map((advice) {
      if (advice.id == event.adviceId) {
        return advice.copyWith(isRead: true);
      }
      return advice;
    }).toList();

    _currentReport = HealthReport(
      overallScore: _currentReport!.overallScore,
      categoryScores: _currentReport!.categoryScores,
      advices: updatedAdvices,
      highlights: _currentReport!.highlights,
      concerns: _currentReport!.concerns,
      analyzedAt: _currentReport!.analyzedAt,
    );

    emit(AdvisorLoaded(_currentReport!));
  }

  Future<void> _onDismissAdvice(
    DismissAdvice event,
    Emitter<AdvisorState> emit,
  ) async {
    if (_currentReport == null) return;

    final updatedAdvices = _currentReport!.advices
        .where((advice) => advice.id != event.adviceId)
        .toList();

    _currentReport = HealthReport(
      overallScore: _currentReport!.overallScore,
      categoryScores: _currentReport!.categoryScores,
      advices: updatedAdvices,
      highlights: _currentReport!.highlights,
      concerns: _currentReport!.concerns,
      analyzedAt: _currentReport!.analyzedAt,
    );

    emit(AdvisorLoaded(_currentReport!));
  }

  Future<void> _onRefreshAdvices(
    RefreshAdvices event,
    Emitter<AdvisorState> emit,
  ) async {
    add(const GenerateHealthReport());
  }
}
