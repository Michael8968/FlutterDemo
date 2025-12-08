import 'package:equatable/equatable.dart';

/// AI 建议事件基类
abstract class AdvisorEvent extends Equatable {
  const AdvisorEvent();

  @override
  List<Object?> get props => [];
}

/// 生成健康报告
class GenerateHealthReport extends AdvisorEvent {
  final int days;

  const GenerateHealthReport({this.days = 7});

  @override
  List<Object?> get props => [days];
}

/// 标记建议已读
class MarkAdviceRead extends AdvisorEvent {
  final String adviceId;

  const MarkAdviceRead(this.adviceId);

  @override
  List<Object?> get props => [adviceId];
}

/// 忽略建议
class DismissAdvice extends AdvisorEvent {
  final String adviceId;

  const DismissAdvice(this.adviceId);

  @override
  List<Object?> get props => [adviceId];
}

/// 刷新建议
class RefreshAdvices extends AdvisorEvent {
  const RefreshAdvices();
}
