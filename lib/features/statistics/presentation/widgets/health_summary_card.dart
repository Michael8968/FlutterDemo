import 'package:flutter/material.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import 'period_selector.dart';

/// 健康概览卡片
class HealthSummaryCard extends StatelessWidget {
  final List<DiaryEntry> diaries;
  final List<SymptomEntry> symptoms;
  final StatsPeriod period;

  const HealthSummaryCard({
    super.key,
    required this.diaries,
    required this.symptoms,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final healthScore = _calculateHealthScore();
    final scoreColor = _getScoreColor(healthScore);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // 健康评分圆环
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: healthScore / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${healthScore.toInt()}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                          Text(
                            '健康分',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // 统计数据
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(
                        icon: Icons.book,
                        label: '日记记录',
                        value: '${diaries.length}篇',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.healing,
                        label: '症状记录',
                        value: '${symptoms.length}次',
                        color: symptoms.isEmpty ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.calendar_today,
                        label: '记录天数',
                        value: '${_getRecordDays()}天',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 健康等级说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(_getScoreIcon(healthScore), color: scoreColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getScoreDescription(healthScore),
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _calculateHealthScore() {
    double score = 50; // 基础分

    // 记录频率加分 (最多+20)
    final recordDays = _getRecordDays();
    final expectedDays = period.days;
    final recordRate = recordDays / expectedDays;
    score += recordRate * 20;

    // 心情加分 (最多+15)
    if (diaries.isNotEmpty) {
      final avgMood =
          diaries.map((d) => d.mood.value).reduce((a, b) => a + b) / diaries.length;
      score += (avgMood / 5) * 15;
    }

    // 睡眠加分 (最多+10)
    final sleepDiaries = diaries.where((d) => d.sleepHours != null).toList();
    if (sleepDiaries.isNotEmpty) {
      final avgSleep =
          sleepDiaries.map((d) => d.sleepHours!).reduce((a, b) => a + b) /
              sleepDiaries.length;
      if (avgSleep >= 7 && avgSleep <= 9) {
        score += 10;
      } else if (avgSleep >= 6 && avgSleep <= 10) {
        score += 5;
      }
    }

    // 症状减分 (最多-15)
    if (symptoms.isNotEmpty) {
      final avgSeverity =
          symptoms.map((s) => s.severity).reduce((a, b) => a + b) / symptoms.length;
      score -= (avgSeverity / 10) * 15;
    } else {
      score += 5; // 无症状加分
    }

    return score.clamp(0, 100);
  }

  int _getRecordDays() {
    final dates = <String>{};
    for (final diary in diaries) {
      dates.add('${diary.date.year}-${diary.date.month}-${diary.date.day}');
    }
    return dates.length;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    if (score >= 40) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return '健康状况良好，继续保持！';
    if (score >= 60) return '健康状况不错，还有提升空间';
    if (score >= 40) return '健康状况一般，建议多关注身体';
    return '健康状况需要关注，建议咨询医生';
  }
}
