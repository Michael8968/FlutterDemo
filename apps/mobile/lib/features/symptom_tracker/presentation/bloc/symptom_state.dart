import 'package:equatable/equatable.dart';
import '../../domain/entities/symptom_entry.dart';

/// 症状状态基类
abstract class SymptomState extends Equatable {
  const SymptomState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class SymptomInitial extends SymptomState {}

/// 加载中
class SymptomLoading extends SymptomState {}

/// 症状列表加载成功
class SymptomLoaded extends SymptomState {
  final List<SymptomEntry> symptoms;
  final DateTime? selectedDate;

  const SymptomLoaded({
    required this.symptoms,
    this.selectedDate,
  });

  @override
  List<Object?> get props => [symptoms, selectedDate];
}

/// 症状分析加载成功
class SymptomAnalysisLoaded extends SymptomState {
  final SymptomAnalysis analysis;

  const SymptomAnalysisLoaded(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

/// 症状操作成功（添加/更新/删除）
class SymptomOperationSuccess extends SymptomState {
  final String message;
  final SymptomEntry? entry;

  const SymptomOperationSuccess({
    required this.message,
    this.entry,
  });

  @override
  List<Object?> get props => [message, entry];
}

/// 错误状态
class SymptomError extends SymptomState {
  final String message;

  const SymptomError(this.message);

  @override
  List<Object?> get props => [message];
}
