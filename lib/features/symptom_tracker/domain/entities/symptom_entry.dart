import 'package:equatable/equatable.dart';
import 'symptom_category.dart';

/// 症状记录实体
class SymptomEntry extends Equatable {
  /// 唯一标识
  final String id;

  /// 记录时间
  final DateTime timestamp;

  /// 症状名称
  final String symptomName;

  /// 症状模板ID（如果使用预置模板）
  final String? templateId;

  /// 症状类型
  final SymptomType type;

  /// 严重程度 (1-10)
  final int severity;

  /// 涉及的身体部位
  final List<String> bodyParts;

  /// 持续时间（分钟）
  final int? durationMinutes;

  /// 可能的诱因
  final List<String> triggers;

  /// 备注
  final String? notes;

  /// 是否正在发作
  final bool isOngoing;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  const SymptomEntry({
    required this.id,
    required this.timestamp,
    required this.symptomName,
    this.templateId,
    required this.type,
    required this.severity,
    this.bodyParts = const [],
    this.durationMinutes,
    this.triggers = const [],
    this.notes,
    this.isOngoing = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// 获取严重程度等级
  SeverityLevel get severityLevel => SeverityLevel.fromScore(severity);

  /// 获取持续时间的友好显示
  String? get durationDisplay {
    if (durationMinutes == null) return null;
    if (durationMinutes! < 60) return '$durationMinutes 分钟';
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    if (minutes == 0) return '$hours 小时';
    return '$hours 小时 $minutes 分钟';
  }

  /// 复制并更新
  SymptomEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? symptomName,
    String? templateId,
    SymptomType? type,
    int? severity,
    List<String>? bodyParts,
    int? durationMinutes,
    List<String>? triggers,
    String? notes,
    bool? isOngoing,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      symptomName: symptomName ?? this.symptomName,
      templateId: templateId ?? this.templateId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      bodyParts: bodyParts ?? this.bodyParts,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
      isOngoing: isOngoing ?? this.isOngoing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        symptomName,
        templateId,
        type,
        severity,
        bodyParts,
        durationMinutes,
        triggers,
        notes,
        isOngoing,
        createdAt,
        updatedAt,
      ];
}

/// 症状统计摘要
class SymptomSummary extends Equatable {
  /// 症状名称
  final String symptomName;

  /// 发生次数
  final int count;

  /// 平均严重程度
  final double averageSeverity;

  /// 最近一次发生时间
  final DateTime lastOccurrence;

  /// 常见诱因
  final List<String> commonTriggers;

  /// 常见身体部位
  final List<String> commonBodyParts;

  const SymptomSummary({
    required this.symptomName,
    required this.count,
    required this.averageSeverity,
    required this.lastOccurrence,
    this.commonTriggers = const [],
    this.commonBodyParts = const [],
  });

  @override
  List<Object?> get props => [
        symptomName,
        count,
        averageSeverity,
        lastOccurrence,
        commonTriggers,
        commonBodyParts,
      ];
}

/// 日期范围内的症状分析
class SymptomAnalysis extends Equatable {
  /// 分析的日期范围
  final DateTime startDate;
  final DateTime endDate;

  /// 总记录数
  final int totalEntries;

  /// 按症状类型分组的统计
  final Map<SymptomType, int> countByType;

  /// 各症状的摘要
  final List<SymptomSummary> summaries;

  /// 最常见的症状
  final List<String> topSymptoms;

  /// 最常见的诱因
  final List<String> topTriggers;

  /// 趋势：与上一周期相比的变化
  final double? trendPercentage;

  const SymptomAnalysis({
    required this.startDate,
    required this.endDate,
    required this.totalEntries,
    this.countByType = const {},
    this.summaries = const [],
    this.topSymptoms = const [],
    this.topTriggers = const [],
    this.trendPercentage,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalEntries,
        countByType,
        summaries,
        topSymptoms,
        topTriggers,
        trendPercentage,
      ];
}
