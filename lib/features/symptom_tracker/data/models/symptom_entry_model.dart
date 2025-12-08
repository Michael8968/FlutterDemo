import 'package:hive/hive.dart';
import '../../domain/entities/symptom_entry.dart';
import '../../domain/entities/symptom_category.dart';

part 'symptom_entry_model.g.dart';

@HiveType(typeId: 10)
class SymptomEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String symptomName;

  @HiveField(3)
  final String? templateId;

  @HiveField(4)
  final int typeIndex;

  @HiveField(5)
  final int severity;

  @HiveField(6)
  final List<String> bodyParts;

  @HiveField(7)
  final int? durationMinutes;

  @HiveField(8)
  final List<String> triggers;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final bool isOngoing;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  SymptomEntryModel({
    required this.id,
    required this.timestamp,
    required this.symptomName,
    this.templateId,
    required this.typeIndex,
    required this.severity,
    required this.bodyParts,
    this.durationMinutes,
    required this.triggers,
    this.notes,
    required this.isOngoing,
    required this.createdAt,
    this.updatedAt,
  });

  /// 从实体创建模型
  factory SymptomEntryModel.fromEntity(SymptomEntry entity) {
    return SymptomEntryModel(
      id: entity.id,
      timestamp: entity.timestamp,
      symptomName: entity.symptomName,
      templateId: entity.templateId,
      typeIndex: entity.type.index,
      severity: entity.severity,
      bodyParts: entity.bodyParts,
      durationMinutes: entity.durationMinutes,
      triggers: entity.triggers,
      notes: entity.notes,
      isOngoing: entity.isOngoing,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// 转换为实体
  SymptomEntry toEntity() {
    return SymptomEntry(
      id: id,
      timestamp: timestamp,
      symptomName: symptomName,
      templateId: templateId,
      type: SymptomType.values[typeIndex],
      severity: severity,
      bodyParts: bodyParts,
      durationMinutes: durationMinutes,
      triggers: triggers,
      notes: notes,
      isOngoing: isOngoing,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 从 JSON 创建模型
  factory SymptomEntryModel.fromJson(Map<String, dynamic> json) {
    return SymptomEntryModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      symptomName: json['symptomName'] as String,
      templateId: json['templateId'] as String?,
      typeIndex: json['typeIndex'] as int,
      severity: json['severity'] as int,
      bodyParts: List<String>.from(json['bodyParts'] ?? []),
      durationMinutes: json['durationMinutes'] as int?,
      triggers: List<String>.from(json['triggers'] ?? []),
      notes: json['notes'] as String?,
      isOngoing: json['isOngoing'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'symptomName': symptomName,
      'templateId': templateId,
      'typeIndex': typeIndex,
      'severity': severity,
      'bodyParts': bodyParts,
      'durationMinutes': durationMinutes,
      'triggers': triggers,
      'notes': notes,
      'isOngoing': isOngoing,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
