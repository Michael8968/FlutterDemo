import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../entities/achievement.dart';

/// 成就追踪服务
class AchievementService {
  static const String _achievementsKey = 'user_achievements';

  final SharedPreferences _prefs;

  AchievementService(this._prefs);

  /// 获取所有用户成就
  Future<List<UserAchievement>> getAllAchievements() async {
    final json = _prefs.getString(_achievementsKey);
    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => UserAchievement.fromJson(e)).toList();
  }

  /// 保存成就
  Future<void> _saveAchievements(List<UserAchievement> achievements) async {
    final json = jsonEncode(achievements.map((e) => e.toJson()).toList());
    await _prefs.setString(_achievementsKey, json);
  }

  /// 检查并更新成就进度
  Future<List<UserAchievement>> checkAndUpdateAchievements({
    required List<DiaryEntry> diaries,
    UserProfile? profile,
  }) async {
    final existingAchievements = await getAllAchievements();
    final newlyUnlocked = <UserAchievement>[];

    // 按日期排序日记
    final sortedDiaries = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 计算各种统计数据
    final stats = _calculateStats(sortedDiaries, profile);

    // 检查每个成就定义
    for (final definition in AchievementDefinition.all) {
      final currentValue = _getValueForAchievement(definition, stats);
      final existing = existingAchievements
          .where((a) => a.definitionId == definition.id)
          .firstOrNull;

      if (existing != null) {
        // 更新进度
        if (currentValue > existing.currentValue) {
          final updated = existing.copyWith(
            currentValue: currentValue,
            isNew: currentValue >= definition.targetValue && !existing.isUnlocked,
            unlockedAt: currentValue >= definition.targetValue && !existing.isUnlocked
                ? DateTime.now()
                : existing.unlockedAt,
          );
          final index = existingAchievements.indexOf(existing);
          existingAchievements[index] = updated;

          if (updated.isUnlocked && !existing.isUnlocked) {
            newlyUnlocked.add(updated);
          }
        }
      } else {
        // 创建新的成就记录
        final achievement = UserAchievement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          definitionId: definition.id,
          unlockedAt: currentValue >= definition.targetValue
              ? DateTime.now()
              : DateTime(1970),
          currentValue: currentValue,
          isNew: currentValue >= definition.targetValue,
        );
        existingAchievements.add(achievement);

        if (achievement.isUnlocked) {
          newlyUnlocked.add(achievement);
        }
      }
    }

    await _saveAchievements(existingAchievements);
    return newlyUnlocked;
  }

  /// 计算统计数据
  Map<String, int> _calculateStats(
    List<DiaryEntry> diaries,
    UserProfile? profile,
  ) {
    final stats = <String, int>{};

    // 总日记数
    stats['total_diaries'] = diaries.length;

    // 连续打卡天数
    stats['current_streak'] = _calculateCurrentStreak(diaries);
    stats['max_streak'] = _calculateMaxStreak(diaries);

    // 心情统计
    stats['happy_streak'] = _calculateHappyStreak(diaries);
    stats['stable_mood_streak'] = _calculateStableMoodStreak(diaries);
    stats['total_mood_records'] = diaries.length;

    // 睡眠统计
    stats['good_sleep_streak'] = _calculateGoodSleepStreak(diaries);
    stats['early_bird_streak'] = _calculateEarlyBirdStreak(diaries);

    // 运动统计
    stats['total_activities'] = _calculateTotalActivities(diaries);
    stats['max_steps'] = _calculateMaxSteps(diaries);

    // 个人档案完整度
    stats['profile_complete'] = _isProfileComplete(profile) ? 1 : 0;

    // 健康目标
    stats['has_goal'] = (profile?.healthGoals.isNotEmpty ?? false) ? 1 : 0;
    stats['completed_goals'] =
        profile?.healthGoals.where((g) => g.currentValue >= g.targetValue).length ?? 0;

    return stats;
  }

  int _getValueForAchievement(
    AchievementDefinition definition,
    Map<String, int> stats,
  ) {
    switch (definition.id) {
      // 连续打卡系列
      case 'streak_3':
      case 'streak_7':
      case 'streak_30':
      case 'streak_100':
      case 'streak_365':
        return stats['current_streak'] ?? 0;

      // 心情系列
      case 'mood_happy_7':
        return stats['happy_streak'] ?? 0;
      case 'mood_stable_14':
        return stats['stable_mood_streak'] ?? 0;
      case 'mood_tracker_30':
        return stats['total_mood_records'] ?? 0;

      // 睡眠系列
      case 'sleep_quality_7':
      case 'sleep_quality_30':
        return stats['good_sleep_streak'] ?? 0;
      case 'early_bird_7':
        return stats['early_bird_streak'] ?? 0;

      // 运动系列
      case 'activity_10':
      case 'activity_50':
      case 'activity_100':
        return stats['total_activities'] ?? 0;
      case 'steps_10000':
        return stats['max_steps'] ?? 0;

      // 里程碑系列
      case 'first_diary':
        return stats['total_diaries'] ?? 0;
      case 'diary_50':
      case 'diary_100':
        return stats['total_diaries'] ?? 0;
      case 'complete_profile':
        return stats['profile_complete'] ?? 0;
      case 'first_goal':
        return stats['has_goal'] ?? 0;
      case 'goal_completed':
        return stats['completed_goals'] ?? 0;

      default:
        return 0;
    }
  }

  int _calculateCurrentStreak(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime expectedDate = todayDate;

    // 从最新日期开始往回数
    final sortedByDateDesc = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final diary in sortedByDateDesc) {
      final diaryDate = DateTime(diary.date.year, diary.date.month, diary.date.day);

      // 如果是预期日期或前一天（允许今天还没记录的情况）
      if (diaryDate == expectedDate ||
          (streak == 0 && diaryDate == expectedDate.subtract(const Duration(days: 1)))) {
        streak++;
        expectedDate = diaryDate.subtract(const Duration(days: 1));
      } else if (diaryDate.isBefore(expectedDate)) {
        break;
      }
    }

    return streak;
  }

  int _calculateMaxStreak(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 1;

    final sortedDiaries = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (int i = 1; i < sortedDiaries.length; i++) {
      final prevDate = DateTime(
        sortedDiaries[i - 1].date.year,
        sortedDiaries[i - 1].date.month,
        sortedDiaries[i - 1].date.day,
      );
      final currDate = DateTime(
        sortedDiaries[i].date.year,
        sortedDiaries[i].date.month,
        sortedDiaries[i].date.day,
      );

      if (currDate.difference(prevDate).inDays == 1) {
        currentStreak++;
      } else if (currDate.difference(prevDate).inDays > 1) {
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        currentStreak = 1;
      }
    }

    return maxStreak > currentStreak ? maxStreak : currentStreak;
  }

  int _calculateHappyStreak(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    final sortedDiaries = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final diary in sortedDiaries) {
      if (diary.mood.value >= 4) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }

  int _calculateStableMoodStreak(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    final sortedDiaries = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final diary in sortedDiaries) {
      if (diary.mood.value >= 3) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }

  int _calculateGoodSleepStreak(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    final sortedDiaries = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final diary in sortedDiaries) {
      final sleep = diary.sleepHours;
      if (sleep != null && sleep >= 7 && sleep <= 9) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }

  int _calculateEarlyBirdStreak(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;

    final sortedDiaries = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final diary in sortedDiaries) {
      final wakeTime = diary.wakeTime;
      if (wakeTime != null && wakeTime.hour < 7) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }

  int _calculateTotalActivities(List<DiaryEntry> diaries) {
    return diaries.fold(0, (sum, diary) => sum + diary.activities.length);
  }

  int _calculateMaxSteps(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) return 0;
    return diaries
        .where((d) => d.steps != null)
        .map((d) => d.steps!)
        .fold(0, (max, steps) => steps > max ? steps : max);
  }

  bool _isProfileComplete(UserProfile? profile) {
    if (profile == null) return false;
    return profile.nickname != null &&
        profile.gender != null &&
        profile.birthday != null &&
        profile.height != null &&
        profile.weight != null;
  }

  /// 获取成就统计摘要
  Future<AchievementSummary> getAchievementSummary() async {
    final achievements = await getAllAchievements();
    final unlocked = achievements.where((a) => a.isUnlocked).toList();

    int bronze = 0, silver = 0, gold = 0, platinum = 0, diamond = 0;

    for (final achievement in unlocked) {
      final def = achievement.definition;
      if (def == null) continue;

      switch (def.level) {
        case AchievementLevel.bronze:
          bronze++;
          break;
        case AchievementLevel.silver:
          silver++;
          break;
        case AchievementLevel.gold:
          gold++;
          break;
        case AchievementLevel.platinum:
          platinum++;
          break;
        case AchievementLevel.diamond:
          diamond++;
          break;
      }
    }

    // 获取最近解锁的成就
    final recent = unlocked
      ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));

    return AchievementSummary(
      totalUnlocked: unlocked.length,
      totalAvailable: AchievementDefinition.all.length,
      bronzeCount: bronze,
      silverCount: silver,
      goldCount: gold,
      platinumCount: platinum,
      diamondCount: diamond,
      recentAchievements: recent.take(5).toList(),
    );
  }

  /// 标记成就为已查看
  Future<void> markAsViewed(String achievementId) async {
    final achievements = await getAllAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);
    if (index >= 0) {
      achievements[index] = achievements[index].copyWith(isNew: false);
      await _saveAchievements(achievements);
    }
  }

  /// 标记所有成就为已查看
  Future<void> markAllAsViewed() async {
    final achievements = await getAllAchievements();
    final updated = achievements.map((a) => a.copyWith(isNew: false)).toList();
    await _saveAchievements(updated);
  }
}
