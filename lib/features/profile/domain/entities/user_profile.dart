import 'package:equatable/equatable.dart';
import 'health_goal.dart';

/// 性别枚举
enum Gender {
  male('男', '👨'),
  female('女', '👩'),
  other('其他', '🧑');

  final String displayName;
  final String emoji;

  const Gender(this.displayName, this.emoji);
}

/// 血型枚举
enum BloodType {
  a('A型'),
  b('B型'),
  ab('AB型'),
  o('O型'),
  unknown('未知');

  final String displayName;

  const BloodType(this.displayName);
}

/// 用户档案实体
class UserProfile extends Equatable {
  final String id;
  final String? nickname;
  final String? avatarUrl;
  final Gender? gender;
  final DateTime? birthday;
  final double? height; // cm
  final double? weight; // kg
  final BloodType? bloodType;
  final List<String> allergies; // 过敏源
  final List<String> chronicDiseases; // 慢性病
  final List<String> medications; // 正在服用的药物
  final String? emergencyContact; // 紧急联系人
  final String? emergencyPhone; // 紧急联系电话
  final List<HealthGoal> healthGoals; // 健康目标
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.nickname,
    this.avatarUrl,
    this.gender,
    this.birthday,
    this.height,
    this.weight,
    this.bloodType,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.medications = const [],
    this.emergencyContact,
    this.emergencyPhone,
    this.healthGoals = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 计算年龄
  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  /// 计算BMI
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// 获取BMI等级
  String? get bmiLevel {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    if (bmiValue < 18.5) return '偏瘦';
    if (bmiValue < 24) return '正常';
    if (bmiValue < 28) return '偏重';
    return '肥胖';
  }

  /// 获取BMI颜色
  String? get bmiColorHex {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    if (bmiValue < 18.5) return '2196F3'; // 蓝色
    if (bmiValue < 24) return '4CAF50'; // 绿色
    if (bmiValue < 28) return 'FF9800'; // 橙色
    return 'F44336'; // 红色
  }

  /// 档案完成度
  double get completionRate {
    int total = 8;
    int completed = 0;

    if (nickname != null && nickname!.isNotEmpty) completed++;
    if (gender != null) completed++;
    if (birthday != null) completed++;
    if (height != null) completed++;
    if (weight != null) completed++;
    if (bloodType != null && bloodType != BloodType.unknown) completed++;
    if (emergencyContact != null && emergencyContact!.isNotEmpty) completed++;
    if (emergencyPhone != null && emergencyPhone!.isNotEmpty) completed++;

    return completed / total;
  }

  UserProfile copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    Gender? gender,
    DateTime? birthday,
    double? height,
    double? weight,
    BloodType? bloodType,
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<String>? medications,
    String? emergencyContact,
    String? emergencyPhone,
    List<HealthGoal>? healthGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      medications: medications ?? this.medications,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      healthGoals: healthGoals ?? this.healthGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nickname,
        avatarUrl,
        gender,
        birthday,
        height,
        weight,
        bloodType,
        allergies,
        chronicDiseases,
        medications,
        emergencyContact,
        emergencyPhone,
        healthGoals,
        createdAt,
        updatedAt,
      ];
}
