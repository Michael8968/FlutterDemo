import 'package:flutter/material.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import '../../../symptom_tracker/domain/entities/symptom_category.dart';
import 'period_selector.dart';

/// 症状统计卡片
class SymptomStatsCard extends StatelessWidget {
  final List<SymptomEntry> symptoms;
  final StatsPeriod period;

  const SymptomStatsCard({
    super.key,
    required this.symptoms,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (symptoms.isEmpty) {
      return _buildEmptyState();
    }

    // 按类型统计
    final typeStats = _calculateTypeStats();
    // 按严重程度统计
    final severityStats = _calculateSeverityStats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.healing, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  '症状分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '共${symptoms.length}次',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 症状类型分布
            const Text(
              '症状类型分布',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildTypeDistribution(typeStats),
            const SizedBox(height: 16),

            // 严重程度分布
            const Text(
              '严重程度分布',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildSeverityDistribution(severityStats),
            const SizedBox(height: 12),

            // 健康建议
            _buildHealthAdvice(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.health_and_safety, size: 48, color: Colors.green.shade300),
            const SizedBox(height: 12),
            const Text(
              '症状分析',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '太棒了！这段时间没有症状记录',
              style: TextStyle(color: Colors.green.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Map<SymptomType, int> _calculateTypeStats() {
    final stats = <SymptomType, int>{};
    for (final symptom in symptoms) {
      stats[symptom.type] = (stats[symptom.type] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> _calculateSeverityStats() {
    final stats = <String, int>{
      '轻微': 0,
      '中等': 0,
      '严重': 0,
    };

    for (final symptom in symptoms) {
      if (symptom.severity <= 3) {
        stats['轻微'] = stats['轻微']! + 1;
      } else if (symptom.severity <= 6) {
        stats['中等'] = stats['中等']! + 1;
      } else {
        stats['严重'] = stats['严重']! + 1;
      }
    }
    return stats;
  }

  Widget _buildTypeDistribution(Map<SymptomType, int> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    // 按数量排序
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 只显示前5个
    final topEntries = sortedEntries.take(5).toList();
    final total = symptoms.length;

    return Column(
      children: topEntries.map((entry) {
        final percentage = entry.value / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  entry.key.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  entry.key.displayName,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTypeColor(entry.key),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${entry.value}次',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeverityDistribution(Map<String, int> stats) {
    final total = symptoms.length;
    final colors = {
      '轻微': Colors.green,
      '中等': Colors.orange,
      '严重': Colors.red,
    };

    return Row(
      children: stats.entries.map((entry) {
        final percentage = total > 0 ? entry.value / total : 0.0;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors[entry.key]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors[entry.key],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors[entry.key],
                  ),
                ),
                Text(
                  '${entry.value}次',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthAdvice() {
    final severityStats = _calculateSeverityStats();
    final severeCount = severityStats['严重'] ?? 0;
    final totalCount = symptoms.length;

    String advice;
    IconData icon;
    Color color;

    if (totalCount == 0) {
      advice = '保持良好的生活习惯';
      icon = Icons.thumb_up;
      color = Colors.green;
    } else if (severeCount > totalCount * 0.3) {
      advice = '严重症状较多，建议及时就医';
      icon = Icons.local_hospital;
      color = Colors.red;
    } else if (totalCount > 10) {
      advice = '症状频繁，注意观察身体状况';
      icon = Icons.warning;
      color = Colors.orange;
    } else {
      advice = '症状较少，继续保持健康生活';
      icon = Icons.favorite;
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(SymptomType type) {
    switch (type) {
      case SymptomType.pain:
        return Colors.red;
      case SymptomType.discomfort:
        return Colors.orange;
      case SymptomType.fatigue:
        return Colors.amber;
      case SymptomType.digestive:
        return Colors.green;
      case SymptomType.respiratory:
        return Colors.blue;
      case SymptomType.skin:
        return Colors.purple;
      case SymptomType.mental:
        return Colors.teal;
      case SymptomType.fever:
        return Colors.red.shade700;
      case SymptomType.other:
        return Colors.grey;
    }
  }
}
