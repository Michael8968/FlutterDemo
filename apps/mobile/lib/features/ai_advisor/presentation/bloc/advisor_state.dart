import 'package:equatable/equatable.dart';
import '../../domain/entities/health_advice.dart';

/// AI 建议状态基类
abstract class AdvisorState extends Equatable {
  const AdvisorState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class AdvisorInitial extends AdvisorState {
  const AdvisorInitial();
}

/// 加载中
class AdvisorLoading extends AdvisorState {
  const AdvisorLoading();
}

/// 报告生成成功
class AdvisorLoaded extends AdvisorState {
  final HealthReport report;

  const AdvisorLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// 错误状态
class AdvisorError extends AdvisorState {
  final String message;

  const AdvisorError(this.message);

  @override
  List<Object?> get props => [message];
}
