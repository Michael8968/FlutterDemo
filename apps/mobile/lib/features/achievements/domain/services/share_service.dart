import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../entities/achievement.dart';

/// 获取临时目录（带 Linux fallback）
Future<Directory> _getTempDirectory() async {
  // Linux 平台
  if (defaultTargetPlatform == TargetPlatform.linux) {
    try {
      return await getTemporaryDirectory();
    } catch (_) {
      return Directory('/tmp/flutter_demo');
    }
  }
  return await getTemporaryDirectory();
}

/// 分享内容类型
enum ShareContentType {
  achievement('成就'),
  healthReport('健康报告'),
  streak('打卡记录'),
  summary('健康摘要');

  final String displayName;

  const ShareContentType(this.displayName);
}

/// 健康报告数据
class HealthReportData {
  final int totalDiaries;
  final int currentStreak;
  final double avgMood;
  final double avgSleep;
  final int totalActivities;
  final AchievementSummary achievementSummary;
  final DateTime reportDate;

  const HealthReportData({
    required this.totalDiaries,
    required this.currentStreak,
    required this.avgMood,
    required this.avgSleep,
    required this.totalActivities,
    required this.achievementSummary,
    required this.reportDate,
  });
}

/// 分享服务
class ShareService {
  /// 分享成就
  Future<void> shareAchievement(UserAchievement achievement) async {
    final def = achievement.definition;
    if (def == null) return;

    final text = '''
🏆 我解锁了新成就！

${def.level.emoji} ${def.name}
${def.description}

类别：${def.category.displayName}
等级：${def.level.displayName}

#AI健康教练 #健康打卡 #${def.category.displayName}
''';

    await Share.share(text, subject: '我解锁了新成就：${def.name}');
  }

  /// 分享健康报告
  Future<void> shareHealthReport(HealthReportData report) async {
    final dateStr =
        '${report.reportDate.year}年${report.reportDate.month}月${report.reportDate.day}日';

    final text = '''
📊 我的健康报告 - $dateStr

📝 累计记录：${report.totalDiaries} 天
🔥 连续打卡：${report.currentStreak} 天
😊 平均心情：${report.avgMood.toStringAsFixed(1)}/5
😴 平均睡眠：${report.avgSleep.toStringAsFixed(1)} 小时
🏃 运动次数：${report.totalActivities} 次

🏆 成就统计
已解锁：${report.achievementSummary.totalUnlocked}/${report.achievementSummary.totalAvailable}
🥉 铜牌：${report.achievementSummary.bronzeCount}
🥈 银牌：${report.achievementSummary.silverCount}
🥇 金牌：${report.achievementSummary.goldCount}
💎 白金：${report.achievementSummary.platinumCount}
💠 钻石：${report.achievementSummary.diamondCount}

总积分：${report.achievementSummary.totalPoints}

#AI健康教练 #健康报告 #坚持打卡
''';

    await Share.share(text, subject: '我的健康报告');
  }

  /// 分享打卡记录
  Future<void> shareStreak(int streakDays) async {
    String emoji;
    String encouragement;

    if (streakDays >= 365) {
      emoji = '🏆💎';
      encouragement = '全年无休，您是真正的健康达人！';
    } else if (streakDays >= 100) {
      emoji = '🔥💪';
      encouragement = '百日坚持，太厉害了！';
    } else if (streakDays >= 30) {
      emoji = '🌟';
      encouragement = '一个月的坚持，习惯已养成！';
    } else if (streakDays >= 7) {
      emoji = '✨';
      encouragement = '一周打卡成功，继续加油！';
    } else {
      emoji = '🔥';
      encouragement = '坚持就是胜利！';
    }

    final text = '''
$emoji 打卡成功！

我已连续打卡 $streakDays 天！
$encouragement

#AI健康教练 #连续打卡$streakDays天 #健康生活
''';

    await Share.share(text, subject: '连续打卡 $streakDays 天');
  }

  /// 分享成就摘要
  Future<void> shareAchievementSummary(AchievementSummary summary) async {
    final completionPercent = (summary.completionRate * 100).toStringAsFixed(0);

    final text = '''
🏆 我的成就收集

已解锁 ${summary.totalUnlocked}/${summary.totalAvailable} ($completionPercent%)

🥉 铜牌：${summary.bronzeCount}
🥈 银牌：${summary.silverCount}
🥇 金牌：${summary.goldCount}
💎 白金：${summary.platinumCount}
💠 钻石：${summary.diamondCount}

总积分：${summary.totalPoints} 分

来和我一起收集健康成就吧！

#AI健康教练 #成就收集 #健康打卡
''';

    await Share.share(text, subject: '我的健康成就');
  }

  /// 将Widget转换为图片并分享
  Future<void> shareWidgetAsImage(
    GlobalKey repaintBoundaryKey,
    String subject,
  ) async {
    try {
      // 获取RenderRepaintBoundary
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      // 转换为图片
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      // 保存到临时文件
      final tempDir = await _getTempDirectory();
      final file = File('${tempDir.path}/share_image.png');
      await file.writeAsBytes(bytes);

      // 分享
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
      );
    } catch (e) {
      // 如果图片分享失败，回退到文本分享
      await Share.share('查看我的健康成就！ #AI健康教练', subject: subject);
    }
  }

  /// 生成分享文本
  String generateShareText({
    required ShareContentType type,
    Map<String, dynamic>? data,
  }) {
    switch (type) {
      case ShareContentType.achievement:
        final name = data?['name'] ?? '';
        final level = data?['level'] ?? '';
        return '🏆 我在AI健康教练中获得了「$name」$level成就！#健康打卡';
      case ShareContentType.healthReport:
        final days = data?['days'] ?? 0;
        return '📊 我已坚持健康记录$days天！#AI健康教练';
      case ShareContentType.streak:
        final streak = data?['streak'] ?? 0;
        return '🔥 连续打卡$streak天！#健康生活';
      case ShareContentType.summary:
        final unlocked = data?['unlocked'] ?? 0;
        final total = data?['total'] ?? 0;
        return '🏆 已收集$unlocked/$total个健康成就！#AI健康教练';
    }
  }
}
