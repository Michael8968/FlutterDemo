import 'package:flutter/material.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';

/// 最近症状卡片
class RecentSymptomsCard extends StatelessWidget {
  final List<SymptomEntry> symptoms;
  final VoidCallback? onViewAll;
  final VoidCallback? onAddSymptom;

  const RecentSymptomsCard({
    super.key,
    required this.symptoms,
    this.onViewAll,
    this.onAddSymptom,
  });

  @override
  Widget build(BuildContext context) {
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
                  '最近症状',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (symptoms.isNotEmpty)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('查看全部'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (symptoms.isEmpty)
              _buildEmptyState(context)
            else
              _buildSymptomList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return InkWell(
      onTap: onAddSymptom,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近没有症状记录',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    '保持健康！有不适时点击记录',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
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

  Widget _buildSymptomList(BuildContext context) {
    final displaySymptoms = symptoms.take(3).toList();

    return Column(
      children: displaySymptoms.map((symptom) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildSymptomTile(context, symptom),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomTile(BuildContext context, SymptomEntry symptom) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getSeverityColor(symptom.severity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                symptom.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.symptomName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatTime(symptom.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getSeverityColor(symptom.severity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${symptom.severity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getSeverityColor(symptom.severity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} 小时前';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 5) return Colors.yellow.shade700;
    if (severity <= 8) return Colors.orange;
    return Colors.red;
  }
}
