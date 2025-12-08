import 'package:flutter/material.dart';

/// 成就类别
enum AchievementCategory {
  streak('坚持打卡', Icons.local_fire_department, Colors.orange),
  health('健康达人', Icons.favorite, Colors.red),
  mood('心情管理', Icons.mood, Colors.pink),
  sleep('睡眠大师', Icons.bedtime, Colors.indigo),
  activity('运动健将', Icons.directions_run, Colors.green),
  milestone('里程碑', Icons.flag, Colors.blue);

  final String displayName;
  final IconData icon;
  final Color color;

  const AchievementCategory(this.displayName, this.icon, this.color);
}

/// 成就等级
enum AchievementLevel {
  bronze('铜牌', '🥉', 1),
  silver('银牌', '🥈', 2),
  gold('金牌', '🥇', 3),
  platinum('白金', '💎', 4),
  diamond('钻石', '💠', 5);

  final String displayName;
  final String emoji;
  final int level;

  const AchievementLevel(this.displayName, this.emoji, this.level);
}

/// 成就定义
class AchievementDefinition {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final AchievementLevel level;
  final int targetValue;
  final String unit;

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.level,
    required this.targetValue,
    this.unit = '',
  });

  /// 预定义成就列表
  static const List<AchievementDefinition> all = [
    // 坚持打卡系列
    AchievementDefinition(
      id: 'streak_3',
      name: '初露锋芒',
      description: '连续记录3天健康日记',
      category: AchievementCategory.streak,
      level: AchievementLevel.bronze,
      targetValue: 3,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'streak_7',
      name: '习惯养成',
      description: '连续记录7天健康日记',
      category: AchievementCategory.streak,
      level: AchievementLevel.silver,
      targetValue: 7,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'streak_30',
      name: '持之以恒',
      description: '连续记录30天健康日记',
      category: AchievementCategory.streak,
      level: AchievementLevel.gold,
      targetValue: 30,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'streak_100',
      name: '百日坚持',
      description: '连续记录100天健康日记',
      category: AchievementCategory.streak,
      level: AchievementLevel.platinum,
      targetValue: 100,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'streak_365',
      name: '全年无休',
      description: '连续记录365天健康日记',
      category: AchievementCategory.streak,
      level: AchievementLevel.diamond,
      targetValue: 365,
      unit: '天',
    ),

    // 心情管理系列
    AchievementDefinition(
      id: 'mood_happy_7',
      name: '快乐一周',
      description: '连续7天记录好心情',
      category: AchievementCategory.mood,
      level: AchievementLevel.bronze,
      targetValue: 7,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'mood_stable_14',
      name: '情绪稳定',
      description: '连续14天心情评分>=3',
      category: AchievementCategory.mood,
      level: AchievementLevel.silver,
      targetValue: 14,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'mood_tracker_30',
      name: '心情日记达人',
      description: '累计记录30次心情',
      category: AchievementCategory.mood,
      level: AchievementLevel.gold,
      targetValue: 30,
      unit: '次',
    ),

    // 睡眠大师系列
    AchievementDefinition(
      id: 'sleep_quality_7',
      name: '睡眠初学者',
      description: '连续7天睡眠7-9小时',
      category: AchievementCategory.sleep,
      level: AchievementLevel.bronze,
      targetValue: 7,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'sleep_quality_30',
      name: '睡眠专家',
      description: '连续30天睡眠7-9小时',
      category: AchievementCategory.sleep,
      level: AchievementLevel.gold,
      targetValue: 30,
      unit: '天',
    ),
    AchievementDefinition(
      id: 'early_bird_7',
      name: '早起达人',
      description: '连续7天早于7点起床',
      category: AchievementCategory.sleep,
      level: AchievementLevel.silver,
      targetValue: 7,
      unit: '天',
    ),

    // 运动健将系列
    AchievementDefinition(
      id: 'activity_10',
      name: '运动新手',
      description: '累计记录10次运动活动',
      category: AchievementCategory.activity,
      level: AchievementLevel.bronze,
      targetValue: 10,
      unit: '次',
    ),
    AchievementDefinition(
      id: 'activity_50',
      name: '运动爱好者',
      description: '累计记录50次运动活动',
      category: AchievementCategory.activity,
      level: AchievementLevel.silver,
      targetValue: 50,
      unit: '次',
    ),
    AchievementDefinition(
      id: 'activity_100',
      name: '运动达人',
      description: '累计记录100次运动活动',
      category: AchievementCategory.activity,
      level: AchievementLevel.gold,
      targetValue: 100,
      unit: '次',
    ),
    AchievementDefinition(
      id: 'steps_10000',
      name: '日行万步',
      description: '单日步数达到10000步',
      category: AchievementCategory.activity,
      level: AchievementLevel.silver,
      targetValue: 10000,
      unit: '步',
    ),

    // 里程碑系列
    AchievementDefinition(
      id: 'first_diary',
      name: '健康之旅启程',
      description: '记录第一篇健康日记',
      category: AchievementCategory.milestone,
      level: AchievementLevel.bronze,
      targetValue: 1,
      unit: '篇',
    ),
    AchievementDefinition(
      id: 'diary_50',
      name: '半百记录',
      description: '累计记录50篇健康日记',
      category: AchievementCategory.milestone,
      level: AchievementLevel.silver,
      targetValue: 50,
      unit: '篇',
    ),
    AchievementDefinition(
      id: 'diary_100',
      name: '百篇日记',
      description: '累计记录100篇健康日记',
      category: AchievementCategory.milestone,
      level: AchievementLevel.gold,
      targetValue: 100,
      unit: '篇',
    ),
    AchievementDefinition(
      id: 'complete_profile',
      name: '完善档案',
      description: '完成个人健康档案设置',
      category: AchievementCategory.health,
      level: AchievementLevel.bronze,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: 'first_goal',
      name: '目标制定者',
      description: '设置第一个健康目标',
      category: AchievementCategory.health,
      level: AchievementLevel.bronze,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: 'goal_completed',
      name: '目标达成',
      description: '完成一个健康目标',
      category: AchievementCategory.health,
      level: AchievementLevel.silver,
      targetValue: 1,
    ),
  ];

  static AchievementDefinition? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// 用户成就记录
class UserAchievement {
  final String id;
  final String definitionId;
  final DateTime unlockedAt;
  final int currentValue;
  final bool isNew;

  const UserAchievement({
    required this.id,
    required this.definitionId,
    required this.unlockedAt,
    required this.currentValue,
    this.isNew = true,
  });

  AchievementDefinition? get definition =>
      AchievementDefinition.getById(definitionId);

  bool get isUnlocked {
    final def = definition;
    return def != null && currentValue >= def.targetValue;
  }

  double get progress {
    final def = definition;
    if (def == null) return 0;
    return (currentValue / def.targetValue).clamp(0.0, 1.0);
  }

  UserAchievement copyWith({
    String? id,
    String? definitionId,
    DateTime? unlockedAt,
    int? currentValue,
    bool? isNew,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      definitionId: definitionId ?? this.definitionId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentValue: currentValue ?? this.currentValue,
      isNew: isNew ?? this.isNew,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'definitionId': definitionId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'currentValue': currentValue,
      'isNew': isNew,
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] as String,
      definitionId: json['definitionId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      currentValue: json['currentValue'] as int,
      isNew: json['isNew'] as bool? ?? false,
    );
  }
}

/// 成就统计摘要
class AchievementSummary {
  final int totalUnlocked;
  final int totalAvailable;
  final int bronzeCount;
  final int silverCount;
  final int goldCount;
  final int platinumCount;
  final int diamondCount;
  final List<UserAchievement> recentAchievements;

  const AchievementSummary({
    required this.totalUnlocked,
    required this.totalAvailable,
    this.bronzeCount = 0,
    this.silverCount = 0,
    this.goldCount = 0,
    this.platinumCount = 0,
    this.diamondCount = 0,
    this.recentAchievements = const [],
  });

  double get completionRate =>
      totalAvailable > 0 ? totalUnlocked / totalAvailable : 0;

  int get totalPoints =>
      bronzeCount * 10 +
      silverCount * 25 +
      goldCount * 50 +
      platinumCount * 100 +
      diamondCount * 200;
}
