import 'package:equatable/equatable.dart';
import '../../domain/entities/diary_entry.dart';

/// 日记状态基类
abstract class DiaryState extends Equatable {
  const DiaryState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class DiaryInitial extends DiaryState {}

/// 加载中
class DiaryLoading extends DiaryState {}

/// 单个日记加载成功
class DiaryLoaded extends DiaryState {
  final DiaryEntry? entry;
  final DateTime selectedDate;

  const DiaryLoaded({
    this.entry,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [entry, selectedDate];
}

/// 日记列表加载成功
class DiaryListLoaded extends DiaryState {
  final List<DiaryEntry> entries;

  const DiaryListLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

/// 有日记的日期列表加载成功
class DiaryDatesLoaded extends DiaryState {
  final List<DateTime> dates;
  final DateTime month;

  const DiaryDatesLoaded({
    required this.dates,
    required this.month,
  });

  @override
  List<Object?> get props => [dates, month];
}

/// 日记统计加载成功
class DiarySummaryLoaded extends DiaryState {
  final DiarySummary summary;

  const DiarySummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// 日记操作成功
class DiaryOperationSuccess extends DiaryState {
  final String message;
  final DiaryEntry? entry;

  const DiaryOperationSuccess({
    required this.message,
    this.entry,
  });

  @override
  List<Object?> get props => [message, entry];
}

/// 日期范围内日记加载成功
class DiaryRangeLoaded extends DiaryState {
  final List<DiaryEntry> entries;
  final DateTime startDate;
  final DateTime endDate;

  const DiaryRangeLoaded({
    required this.entries,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [entries, startDate, endDate];
}

/// 错误状态
class DiaryError extends DiaryState {
  final String message;

  const DiaryError(this.message);

  @override
  List<Object?> get props => [message];
}
