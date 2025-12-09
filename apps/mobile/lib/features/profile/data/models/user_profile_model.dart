import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/health_goal.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 30)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? nickname;

  @HiveField(2)
  final String? avatarUrl;

  @HiveField(3)
  final int? genderIndex;

  @HiveField(4)
  final DateTime? birthday;

  @HiveField(5)
  final double? height;

  @HiveField(6)
  final double? weight;

  @HiveField(7)
  final int? bloodTypeIndex;

  @HiveField(8)
  final List<String> allergies;

  @HiveField(9)
  final List<String> chronicDiseases;

  @HiveField(10)
  final List<String> medications;

  @HiveField(11)
  final String? emergencyContact;

  @HiveField(12)
  final String? emergencyPhone;

  @HiveField(13)
  final List<HealthGoalModel> healthGoals;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    this.nickname,
    this.avatarUrl,
    this.genderIndex,
    this.birthday,
    this.height,
    this.weight,
    this.bloodTypeIndex,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.medications = const [],
    this.emergencyContact,
    this.emergencyPhone,
    this.healthGoals = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      nickname: entity.nickname,
      avatarUrl: entity.avatarUrl,
      genderIndex: entity.gender?.index,
      birthday: entity.birthday,
      height: entity.height,
      weight: entity.weight,
      bloodTypeIndex: entity.bloodType?.index,
      allergies: entity.allergies,
      chronicDiseases: entity.chronicDiseases,
      medications: entity.medications,
      emergencyContact: entity.emergencyContact,
      emergencyPhone: entity.emergencyPhone,
      healthGoals:
          entity.healthGoals.map((g) => HealthGoalModel.fromEntity(g)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      nickname: nickname,
      avatarUrl: avatarUrl,
      gender: genderIndex != null ? Gender.values[genderIndex!] : null,
      birthday: birthday,
      height: height,
      weight: weight,
      bloodType:
          bloodTypeIndex != null ? BloodType.values[bloodTypeIndex!] : null,
      allergies: allergies,
      chronicDiseases: chronicDiseases,
      medications: medications,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      healthGoals: healthGoals.map((g) => g.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'genderIndex': genderIndex,
      'birthday': birthday?.toIso8601String(),
      'height': height,
      'weight': weight,
      'bloodTypeIndex': bloodTypeIndex,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'medications': medications,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'healthGoals': healthGoals.map((g) => g.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      genderIndex: json['genderIndex'] as int?,
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodTypeIndex: json['bloodTypeIndex'] as int?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      chronicDiseases: (json['chronicDiseases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      healthGoals: (json['healthGoals'] as List<dynamic>?)
              ?.map((e) => HealthGoalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

@HiveType(typeId: 31)
class HealthGoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int typeIndex;

  @HiveField(2)
  final double targetValue;

  @HiveField(3)
  final double currentValue;

  @HiveField(4)
  final int frequencyIndex;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final List<GoalRecordModel> records;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  HealthGoalModel({
    required this.id,
    required this.typeIndex,
    required this.targetValue,
    this.currentValue = 0,
    this.frequencyIndex = 0,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.records = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthGoalModel.fromEntity(HealthGoal entity) {
    return HealthGoalModel(
      id: entity.id,
      typeIndex: entity.type.index,
      targetValue: entity.targetValue,
      currentValue: entity.currentValue,
      frequencyIndex: entity.frequency.index,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      records:
          entity.records.map((r) => GoalRecordModel.fromEntity(r)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  HealthGoal toEntity() {
    return HealthGoal(
      id: id,
      type: GoalType.values[typeIndex],
      targetValue: targetValue,
      currentValue: currentValue,
      frequency: GoalFrequency.values[frequencyIndex],
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      records: records.map((r) => r.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeIndex': typeIndex,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'frequencyIndex': frequencyIndex,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'records': records.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthGoalModel.fromJson(Map<String, dynamic> json) {
    return HealthGoalModel(
      id: json['id'] as String,
      typeIndex: json['typeIndex'] as int,
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      frequencyIndex: json['frequencyIndex'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      records: (json['records'] as List<dynamic>?)
              ?.map((e) => GoalRecordModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

@HiveType(typeId: 32)
class GoalRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double value;

  @HiveField(3)
  final String? note;

  GoalRecordModel({
    required this.id,
    required this.date,
    required this.value,
    this.note,
  });

  factory GoalRecordModel.fromEntity(GoalRecord entity) {
    return GoalRecordModel(
      id: entity.id,
      date: entity.date,
      value: entity.value,
      note: entity.note,
    );
  }

  GoalRecord toEntity() {
    return GoalRecord(
      id: id,
      date: date,
      value: value,
      note: note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'value': value,
      'note': note,
    };
  }

  factory GoalRecordModel.fromJson(Map<String, dynamic> json) {
    return GoalRecordModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }
}
