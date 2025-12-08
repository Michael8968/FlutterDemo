import 'package:equatable/equatable.dart';

/// 健康建议类型
enum AdviceType {
  sleep('睡眠', 'bedtime'),
  mood('心情', 'mood'),
  exercise('运动', 'fitness_center'),
  nutrition('饮食', 'restaurant'),
  stress('压力', 'self_improvement'),
  symptom('症状', 'healing'),
  hydration('补水', 'water_drop'),
  general('综合', 'tips_and_updates');

  final String displayName;
  final String iconName;

  const AdviceType(this.displayName, this.iconName);
}

/// 建议优先级
enum AdvicePriority {
  high('高', 3),
  medium('中', 2),
  low('低', 1);

  final String displayName;
  final int value;

  const AdvicePriority(this.displayName, this.value);
}

/// 健康建议实体
class HealthAdvice extends Equatable {
  final String id;
  final AdviceType type;
  final AdvicePriority priority;
  final String title;
  final String description;
  final List<String> actionItems;
  final String? reason;
  final DateTime generatedAt;
  final bool isRead;
  final bool isDismissed;

  const HealthAdvice({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.actionItems = const [],
    this.reason,
    required this.generatedAt,
    this.isRead = false,
    this.isDismissed = false,
  });

  HealthAdvice copyWith({
    String? id,
    AdviceType? type,
    AdvicePriority? priority,
    String? title,
    String? description,
    List<String>? actionItems,
    String? reason,
    DateTime? generatedAt,
    bool? isRead,
    bool? isDismissed,
  }) {
    return HealthAdvice(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      actionItems: actionItems ?? this.actionItems,
      reason: reason ?? this.reason,
      generatedAt: generatedAt ?? this.generatedAt,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        priority,
        title,
        description,
        actionItems,
        reason,
        generatedAt,
        isRead,
        isDismissed,
      ];
}

/// 健康分析报告
class HealthReport extends Equatable {
  final int overallScore;
  final Map<String, double> categoryScores;
  final List<HealthAdvice> advices;
  final List<String> highlights;
  final List<String> concerns;
  final DateTime analyzedAt;

  const HealthReport({
    required this.overallScore,
    required this.categoryScores,
    required this.advices,
    this.highlights = const [],
    this.concerns = const [],
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
        overallScore,
        categoryScores,
        advices,
        highlights,
        concerns,
        analyzedAt,
      ];
}
