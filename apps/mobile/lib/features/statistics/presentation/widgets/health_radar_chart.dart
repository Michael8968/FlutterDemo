import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import 'period_selector.dart';

/// 健康雷达图
class HealthRadarChart extends StatelessWidget {
  final List<DiaryEntry> diaries;
  final List<SymptomEntry> symptoms;
  final StatsPeriod period;

  const HealthRadarChart({
    super.key,
    required this.diaries,
    required this.symptoms,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.radar, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '健康维度分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 雷达图
            SizedBox(
              height: 280,
              child: _buildRadarChart(context),
            ),
            const SizedBox(height: 12),
            // 维度详情
            _buildDimensionDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart(BuildContext context) {
    final scores = _calculateHealthScores();

    if (scores.isEmpty || diaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radar, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              '暂无足够数据生成健康雷达图',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final dataSets = [
      RadarDataSet(
        dataEntries: scores.values.map((v) => RadarEntry(value: v)).toList(),
        fillColor: Colors.blue.withOpacity(0.2),
        borderColor: Colors.blue,
        borderWidth: 2,
        entryRadius: 3,
      ),
    ];

    return RadarChart(
      RadarChartData(
        dataSets: dataSets,
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.grey, width: 1),
        tickBorderData: const BorderSide(color: Colors.grey, width: 0.5),
        gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
        tickCount: 5,
        ticksTextStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 10,
        ),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        getTitle: (index, angle) {
          final titles = scores.keys.toList();
          if (index < titles.length) {
            return RadarChartTitle(
              text: titles[index],
              angle: angle,
            );
          }
          return const RadarChartTitle(text: '');
        },
      ),
    );
  }

  Map<String, double> _calculateHealthScores() {
    if (diaries.isEmpty) return {};

    // 计算各维度得分 (0-10)
    final scores = <String, double>{};

    // 心情得分
    final moodValues = diaries.map((d) => d.mood.value).toList();
    scores['心情'] = _average(moodValues.map((v) => v * 2.0).toList());

    // 睡眠得分
    final sleepValues = diaries
        .where((d) => d.sleepHours != null)
        .map((d) => d.sleepHours!)
        .toList();
    if (sleepValues.isNotEmpty) {
      // 理想睡眠7-9小时，计算得分
      final avgSleep = _average(sleepValues);
      scores['睡眠'] = _sleepScore(avgSleep);
    } else {
      scores['睡眠'] = 5.0;
    }

    // 精力得分
    final energyValues = diaries
        .where((d) => d.energyLevel != null)
        .map((d) => d.energyLevel!.toDouble())
        .toList();
    scores['精力'] = energyValues.isNotEmpty ? _average(energyValues) : 5.0;

    // 压力得分（反转，压力越低得分越高）
    final stressValues = diaries
        .where((d) => d.stressLevel != null)
        .map((d) => (10 - d.stressLevel!).toDouble())
        .toList();
    scores['抗压'] = stressValues.isNotEmpty ? _average(stressValues) : 5.0;

    // 活动得分
    final activityCounts = diaries.map((d) => d.activities.length).toList();
    scores['运动'] = math.min(_average(activityCounts.map((c) => c * 2.0).toList()), 10);

    // 健康状况（症状越少得分越高）
    final symptomScore = _calculateSymptomScore();
    scores['身体'] = symptomScore;

    return scores;
  }

  double _sleepScore(double avgSleep) {
    if (avgSleep >= 7 && avgSleep <= 9) {
      return 10.0;
    } else if (avgSleep >= 6 && avgSleep < 7) {
      return 7.0;
    } else if (avgSleep > 9 && avgSleep <= 10) {
      return 7.0;
    } else if (avgSleep >= 5 && avgSleep < 6) {
      return 5.0;
    } else if (avgSleep > 10) {
      return 5.0;
    } else {
      return 3.0;
    }
  }

  double _calculateSymptomScore() {
    if (symptoms.isEmpty) return 10.0;

    // 根据症状数量和严重程度计算得分
    final avgSeverity = _average(
      symptoms.map((s) => s.severity.toDouble()).toList(),
    );

    // 症状越严重，得分越低
    return math.max(0, 10 - avgSeverity);
  }

  double _average(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildDimensionDetails() {
    final scores = _calculateHealthScores();
    if (scores.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: scores.entries.map((entry) {
        final color = _getScoreColor(entry.value);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                entry.value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.blue;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
}
