import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/entities/health_goal.dart';
import '../entities/health_advice.dart';

/// 健康数据分析服务
class HealthAnalyzer {
  /// 分析健康数据并生成报告
  HealthReport analyzeHealth({
    required List<DiaryEntry> recentDiaries,
    required List<SymptomEntry> recentSymptoms,
    UserProfile? profile,
    List<HealthGoal>? goals,
  }) {
    final advices = <HealthAdvice>[];
    final highlights = <String>[];
    final concerns = <String>[];
    final categoryScores = <String, double>{};

    // 分析睡眠
    final sleepAnalysis = _analyzeSleep(recentDiaries);
    categoryScores['sleep'] = sleepAnalysis.score;
    advices.addAll(sleepAnalysis.advices);
    highlights.addAll(sleepAnalysis.highlights);
    concerns.addAll(sleepAnalysis.concerns);

    // 分析心情
    final moodAnalysis = _analyzeMood(recentDiaries);
    categoryScores['mood'] = moodAnalysis.score;
    advices.addAll(moodAnalysis.advices);
    highlights.addAll(moodAnalysis.highlights);
    concerns.addAll(moodAnalysis.concerns);

    // 分析压力
    final stressAnalysis = _analyzeStress(recentDiaries);
    categoryScores['stress'] = stressAnalysis.score;
    advices.addAll(stressAnalysis.advices);
    highlights.addAll(stressAnalysis.highlights);
    concerns.addAll(stressAnalysis.concerns);

    // 分析症状
    final symptomAnalysis = _analyzeSymptoms(recentSymptoms);
    categoryScores['symptoms'] = symptomAnalysis.score;
    advices.addAll(symptomAnalysis.advices);
    highlights.addAll(symptomAnalysis.highlights);
    concerns.addAll(symptomAnalysis.concerns);

    // 分析活动
    final activityAnalysis = _analyzeActivity(recentDiaries);
    categoryScores['activity'] = activityAnalysis.score;
    advices.addAll(activityAnalysis.advices);
    highlights.addAll(activityAnalysis.highlights);
    concerns.addAll(activityAnalysis.concerns);

    // 分析目标完成情况
    if (goals != null && goals.isNotEmpty) {
      final goalAnalysis = _analyzeGoals(goals);
      categoryScores['goals'] = goalAnalysis.score;
      advices.addAll(goalAnalysis.advices);
      highlights.addAll(goalAnalysis.highlights);
      concerns.addAll(goalAnalysis.concerns);
    }

    // 计算总分
    final overallScore = _calculateOverallScore(categoryScores);

    // 按优先级排序建议
    advices.sort((a, b) => b.priority.value.compareTo(a.priority.value));

    return HealthReport(
      overallScore: overallScore,
      categoryScores: categoryScores,
      advices: advices,
      highlights: highlights,
      concerns: concerns,
      analyzedAt: DateTime.now(),
    );
  }

  /// 分析睡眠
  _AnalysisResult _analyzeSleep(List<DiaryEntry> diaries) {
    final advices = <HealthAdvice>[];
    final highlights = <String>[];
    final concerns = <String>[];
    double score = 70;

    final sleepData = diaries.where((d) => d.sleepHours != null).toList();

    if (sleepData.isEmpty) {
      advices.add(_createAdvice(
        type: AdviceType.sleep,
        priority: AdvicePriority.medium,
        title: '开始记录睡眠',
        description: '记录睡眠时间有助于了解和改善睡眠质量',
        actionItems: ['每天记录睡眠时间', '记录入睡和起床时间'],
      ));
      return _AnalysisResult(score: 50, advices: advices);
    }

    final avgSleep =
        sleepData.map((d) => d.sleepHours!).reduce((a, b) => a + b) /
            sleepData.length;

    if (avgSleep < 6) {
      score = 30;
      concerns.add('睡眠时间严重不足');
      advices.add(_createAdvice(
        type: AdviceType.sleep,
        priority: AdvicePriority.high,
        title: '睡眠时间不足',
        description: '您近期平均睡眠${avgSleep.toStringAsFixed(1)}小时，低于推荐的7-9小时',
        actionItems: [
          '设定固定的就寝时间',
          '睡前1小时避免使用电子设备',
          '创造舒适的睡眠环境',
        ],
        reason: '充足的睡眠对免疫力、情绪和认知功能至关重要',
      ));
    } else if (avgSleep < 7) {
      score = 60;
      concerns.add('睡眠时间略有不足');
      advices.add(_createAdvice(
        type: AdviceType.sleep,
        priority: AdvicePriority.medium,
        title: '睡眠可以更充足',
        description: '您的平均睡眠时间${avgSleep.toStringAsFixed(1)}小时，建议增加到7-9小时',
        actionItems: ['尝试提前30分钟上床', '减少晚间咖啡因摄入'],
      ));
    } else if (avgSleep <= 9) {
      score = 90;
      highlights.add('睡眠时间充足');
    } else {
      score = 70;
      advices.add(_createAdvice(
        type: AdviceType.sleep,
        priority: AdvicePriority.low,
        title: '睡眠时间偏长',
        description: '过长的睡眠可能影响白天精力，建议保持7-9小时',
        actionItems: ['设置固定起床时间', '增加白天活动量'],
      ));
    }

    // 检查睡眠一致性
    if (sleepData.length >= 3) {
      final sleepHours = sleepData.map((d) => d.sleepHours!).toList();
      final variance = _calculateVariance(sleepHours);
      if (variance > 2) {
        score -= 10;
        advices.add(_createAdvice(
          type: AdviceType.sleep,
          priority: AdvicePriority.medium,
          title: '睡眠时间不规律',
          description: '您的睡眠时间波动较大，规律的作息有助于提高睡眠质量',
          actionItems: ['建立固定的作息时间', '周末也尽量保持规律'],
        ));
      }
    }

    return _AnalysisResult(
      score: score,
      advices: advices,
      highlights: highlights,
      concerns: concerns,
    );
  }

  /// 分析心情
  _AnalysisResult _analyzeMood(List<DiaryEntry> diaries) {
    final advices = <HealthAdvice>[];
    final highlights = <String>[];
    final concerns = <String>[];
    double score = 70;

    if (diaries.isEmpty) {
      advices.add(_createAdvice(
        type: AdviceType.mood,
        priority: AdvicePriority.medium,
        title: '记录心情变化',
        description: '定期记录心情有助于了解情绪模式',
        actionItems: ['每天记录心情状态', '记录影响心情的事件'],
      ));
      return _AnalysisResult(score: 50, advices: advices);
    }

    final moodValues = diaries.map((d) => d.mood.value).toList();
    final avgMood = moodValues.reduce((a, b) => a + b) / moodValues.length;

    if (avgMood <= 2) {
      score = 30;
      concerns.add('情绪状态较低');
      advices.add(_createAdvice(
        type: AdviceType.mood,
        priority: AdvicePriority.high,
        title: '关注情绪健康',
        description: '您近期情绪状态偏低，建议采取一些积极措施',
        actionItems: [
          '与亲友交流倾诉',
          '进行适当的户外活动',
          '尝试冥想或深呼吸练习',
          '如持续低落，建议寻求专业帮助',
        ],
        reason: '情绪健康与身体健康密切相关',
      ));
    } else if (avgMood <= 3) {
      score = 60;
      advices.add(_createAdvice(
        type: AdviceType.mood,
        priority: AdvicePriority.medium,
        title: '提升心情小贴士',
        description: '您的心情一般，尝试一些让自己开心的活动',
        actionItems: ['做自己喜欢的事', '听喜欢的音乐', '与朋友聊天'],
      ));
    } else if (avgMood >= 4) {
      score = 90;
      highlights.add('情绪状态良好');
    }

    // 检查情绪波动
    if (moodValues.length >= 3) {
      final variance = _calculateVariance(moodValues.map((v) => v.toDouble()).toList());
      if (variance > 1.5) {
        score -= 10;
        advices.add(_createAdvice(
          type: AdviceType.mood,
          priority: AdvicePriority.medium,
          title: '情绪波动较大',
          description: '您的情绪波动较大，建议关注可能的触发因素',
          actionItems: ['记录情绪变化的原因', '学习情绪调节技巧'],
        ));
      }
    }

    return _AnalysisResult(
      score: score,
      advices: advices,
      highlights: highlights,
      concerns: concerns,
    );
  }

  /// 分析压力
  _AnalysisResult _analyzeStress(List<DiaryEntry> diaries) {
    final advices = <HealthAdvice>[];
    final highlights = <String>[];
    final concerns = <String>[];
    double score = 70;

    final stressData = diaries.where((d) => d.stressLevel != null).toList();

    if (stressData.isEmpty) {
      return _AnalysisResult(score: 60, advices: advices);
    }

    final avgStress =
        stressData.map((d) => d.stressLevel!).reduce((a, b) => a + b) /
            stressData.length;

    if (avgStress >= 8) {
      score = 30;
      concerns.add('压力水平过高');
      advices.add(_createAdvice(
        type: AdviceType.stress,
        priority: AdvicePriority.high,
        title: '压力过大需要关注',
        description: '您近期压力水平较高，长期高压力可能影响健康',
        actionItems: [
          '尝试深呼吸或冥想练习',
          '适当运动释放压力',
          '合理安排工作和休息',
          '必要时寻求专业帮助',
        ],
        reason: '高压力会影响睡眠、免疫力和心血管健康',
      ));
    } else if (avgStress >= 6) {
      score = 50;
      advices.add(_createAdvice(
        type: AdviceType.stress,
        priority: AdvicePriority.medium,
        title: '注意压力管理',
        description: '您的压力水平中等偏高，建议采取措施预防',
        actionItems: ['每天安排放松时间', '尝试正念练习', '保持规律作息'],
      ));
    } else if (avgStress <= 3) {
      score = 95;
      highlights.add('压力管理良好');
    }

    return _AnalysisResult(
      score: score,
      advices: advices,
      highlights: highlights,
      concerns: concerns,
    );
  }

  /// 分析症状
  _AnalysisResult _analyzeSymptoms(List<SymptomEntry> symptoms) {
    final advices = <HealthAdvice>[];
    final highlights = <String>[];
    final concerns = <String>[];
    double score = 85;

    if (symptoms.isEmpty) {
      highlights.add('近期无不适症状');
      return _AnalysisResult(
        score: 95,
        advices: advices,
        highlights: highlights,
      );
    }

    // 统计症状频率
    final symptomCount = symptoms.length;
    final severeSymptoms = symptoms.where((s) => s.severity >= 7).toList();

    if (symptomCount >= 10) {
      score = 40;
      concerns.add('症状出现频繁');
      advices.add(_createAdvice(
        type: AdviceType.symptom,
        priority: AdvicePriority.high,
        title: '症状频繁需关注',
        description: '您近期记录了较多症状，建议关注身体状况',
        actionItems: [
          '观察症状规律和触发因素',
          '保持充足休息',
          '如症状持续请就医',
        ],
      ));
    } else if (symptomCount >= 5) {
      score = 60;
      advices.add(_createAdvice(
        type: AdviceType.symptom,
        priority: AdvicePriority.medium,
        title: '关注身体信号',
        description: '您近期有一些不适症状，注意休息和调理',
        actionItems: ['保证充足睡眠', '适当休息', '注意饮食'],
      ));
    }

    if (severeSymptoms.isNotEmpty) {
      score -= 20;
      concerns.add('有较严重的不适症状');
      advices.add(_createAdvice(
        type: AdviceType.symptom,
        priority: AdvicePriority.high,
        title: '严重症状需注意',
        description: '您记录了一些严重程度较高的症状',
        actionItems: [
          '密切关注症状变化',
          '如持续或加重请及时就医',
        ],
      ));
    }

    // 检查重复症状
    final symptomNames = symptoms.map((s) => s.symptomName).toList();
    final frequentSymptoms = _findFrequentItems(symptomNames, 3);
    if (frequentSymptoms.isNotEmpty) {
      advices.add(_createAdvice(
        type: AdviceType.symptom,
        priority: AdvicePriority.medium,
        title: '反复出现的症状',
        description: '「${frequentSymptoms.first}」等症状反复出现，建议关注',
        actionItems: ['记录触发因素', '避免已知诱因', '考虑就医检查'],
      ));
    }

    return _AnalysisResult(
      score: score,
      advices: advices,
      highlights: highlights,
      concerns: concerns,
    );
  }

  /// 分析活动
  _AnalysisResult _analyzeActivity(List<DiaryEntry> diaries) {
    final advices = <HealthAdvice>[];
    final highlights = <String>[];
    final concerns = <String>[];
    double score = 60;

    final activityData = diaries.where((d) => d.activities.isNotEmpty).toList();

    if (activityData.isEmpty) {
      advices.add(_createAdvice(
        type: AdviceType.exercise,
        priority: AdvicePriority.medium,
        title: '增加运动记录',
        description: '记录日常活动有助于保持健康生活方式',
        actionItems: ['记录每天的运动', '设定运动目标'],
      ));
      return _AnalysisResult(score: 50, advices: advices);
    }

    // 计算运动天数比例
    final activeDays = activityData.length;
    final totalDays = diaries.length > 0 ? diaries.length : 1;
    final activeRatio = activeDays / totalDays;

    if (activeRatio >= 0.7) {
      score = 90;
      highlights.add('运动习惯良好');
    } else if (activeRatio >= 0.4) {
      score = 70;
      advices.add(_createAdvice(
        type: AdviceType.exercise,
        priority: AdvicePriority.low,
        title: '保持运动习惯',
        description: '您有一定的运动习惯，继续保持',
        actionItems: ['尝试每周运动3-5天', '增加运动多样性'],
      ));
    } else {
      score = 40;
      concerns.add('运动量不足');
      advices.add(_createAdvice(
        type: AdviceType.exercise,
        priority: AdvicePriority.high,
        title: '增加日常运动',
        description: '适度运动对身心健康都有益处',
        actionItems: [
          '每天步行30分钟',
          '尝试简单的拉伸运动',
          '选择喜欢的运动方式',
        ],
        reason: '规律运动可以改善情绪、增强体质、提高睡眠质量',
      ));
    }

    return _AnalysisResult(
      score: score,
      advices: advices,
      highlights: highlights,
      concerns: concerns,
    );
  }

  /// 分析目标完成情况
  _AnalysisResult _analyzeGoals(List<HealthGoal> goals) {
    final advices = <HealthAdvice>[];
    final highlights = <String>[];
    final concerns = <String>[];
    double score = 70;

    final completedGoals = goals.where((g) => g.isCompleted).toList();
    final inProgressGoals = goals.where((g) => !g.isCompleted).toList();
    final completionRate = goals.isNotEmpty
        ? completedGoals.length / goals.length
        : 0.0;

    if (completionRate >= 0.8) {
      score = 95;
      highlights.add('目标完成率高');
    } else if (completionRate >= 0.5) {
      score = 75;
      highlights.add('保持目标进度');
    } else {
      score = 50;
      if (inProgressGoals.isNotEmpty) {
        advices.add(_createAdvice(
          type: AdviceType.general,
          priority: AdvicePriority.medium,
          title: '继续完成目标',
          description: '您还有${inProgressGoals.length}个目标待完成',
          actionItems: ['每天关注目标进度', '从最容易的目标开始'],
        ));
      }
    }

    // 检查连续打卡
    final streakGoals = goals.where((g) => g.streakDays >= 7).toList();
    if (streakGoals.isNotEmpty) {
      highlights.add('${streakGoals.first.type.displayName}连续打卡${streakGoals.first.streakDays}天');
    }

    return _AnalysisResult(
      score: score,
      advices: advices,
      highlights: highlights,
      concerns: concerns,
    );
  }

  /// 计算总分
  int _calculateOverallScore(Map<String, double> categoryScores) {
    if (categoryScores.isEmpty) return 60;
    final sum = categoryScores.values.reduce((a, b) => a + b);
    return (sum / categoryScores.length).round();
  }

  /// 创建建议
  HealthAdvice _createAdvice({
    required AdviceType type,
    required AdvicePriority priority,
    required String title,
    required String description,
    List<String> actionItems = const [],
    String? reason,
  }) {
    return HealthAdvice(
      id: '${DateTime.now().millisecondsSinceEpoch}_${type.name}',
      type: type,
      priority: priority,
      title: title,
      description: description,
      actionItems: actionItems,
      reason: reason,
      generatedAt: DateTime.now(),
    );
  }

  /// 计算方差
  double _calculateVariance(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  /// 找出频繁出现的项目
  List<String> _findFrequentItems(List<String> items, int minCount) {
    final counts = <String, int>{};
    for (final item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    return counts.entries
        .where((e) => e.value >= minCount)
        .map((e) => e.key)
        .toList();
  }
}

/// 分析结果
class _AnalysisResult {
  final double score;
  final List<HealthAdvice> advices;
  final List<String> highlights;
  final List<String> concerns;

  _AnalysisResult({
    required this.score,
    this.advices = const [],
    this.highlights = const [],
    this.concerns = const [],
  });
}
