import 'package:equatable/equatable.dart';
import '../../domain/entities/symptom_entry.dart';
import '../../domain/entities/symptom_category.dart';

/// 症状事件基类
abstract class SymptomEvent extends Equatable {
  const SymptomEvent();

  @override
  List<Object?> get props => [];
}

/// 加载最近症状
class LoadRecentSymptoms extends SymptomEvent {
  final int limit;

  const LoadRecentSymptoms({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// 加载指定日期的症状
class LoadSymptomsByDate extends SymptomEvent {
  final DateTime date;

  const LoadSymptomsByDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// 加载日期范围内的症状
class LoadSymptomsByDateRange extends SymptomEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadSymptomsByDateRange(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}

/// 添加症状
class AddSymptomEvent extends SymptomEvent {
  final String symptomName;
  final String? templateId;
  final SymptomType type;
  final int severity;
  final List<String> bodyParts;
  final int? durationMinutes;
  final List<String> triggers;
  final String? notes;
  final bool isOngoing;

  const AddSymptomEvent({
    required this.symptomName,
    this.templateId,
    required this.type,
    required this.severity,
    this.bodyParts = const [],
    this.durationMinutes,
    this.triggers = const [],
    this.notes,
    this.isOngoing = false,
  });

  @override
  List<Object?> get props => [
        symptomName,
        templateId,
        type,
        severity,
        bodyParts,
        durationMinutes,
        triggers,
        notes,
        isOngoing,
      ];
}

/// 更新症状
class UpdateSymptomEvent extends SymptomEvent {
  final SymptomEntry entry;

  const UpdateSymptomEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// 删除症状
class DeleteSymptomEvent extends SymptomEvent {
  final String id;

  const DeleteSymptomEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 搜索症状
class SearchSymptoms extends SymptomEvent {
  final String query;

  const SearchSymptoms(this.query);

  @override
  List<Object?> get props => [query];
}

/// 加载症状分析
class LoadSymptomAnalysis extends SymptomEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadSymptomAnalysis(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}

/// 标记症状结束
class MarkSymptomEnded extends SymptomEvent {
  final String id;
  final int durationMinutes;

  const MarkSymptomEnded(this.id, this.durationMinutes);

  @override
  List<Object?> get props => [id, durationMinutes];
}
