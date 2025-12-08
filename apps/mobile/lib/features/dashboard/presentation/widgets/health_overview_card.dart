import 'package:flutter/material.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';

/// 健康概览卡片
class HealthOverviewCard extends StatelessWidget {
  final DiaryEntry? todayDiary;
  final VoidCallback? onTap;

  const HealthOverviewCard({
    super.key,
    this.todayDiary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '今日状态',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (todayDiary == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '未记录',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (todayDiary != null) ...[
                _buildTodayStats(context, todayDiary!),
              ] else ...[
                _buildEmptyState(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStats(BuildContext context, DiaryEntry diary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          diary.mood.emoji,
          '心情',
          diary.mood.displayName,
          Color(int.parse('0xFF${diary.mood.colorHex}')),
        ),
        if (diary.sleepHours != null)
          _buildStatItem(
            context,
            '💤',
            '睡眠',
            '${diary.sleepHours!.toStringAsFixed(1)}h',
            Colors.indigo,
          ),
        if (diary.stressLevel != null)
          _buildStatItem(
            context,
            '🧠',
            '压力',
            '${diary.stressLevel}/10',
            _getStressColor(diary.stressLevel!),
          ),
        if (diary.energyLevel != null)
          _buildStatItem(
            context,
            '⚡',
            '精力',
            '${diary.energyLevel}/10',
            _getEnergyColor(diary.energyLevel!),
          ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_note,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '记录今天的状态',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '点击开始记录心情、睡眠等',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Color _getStressColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  Color _getEnergyColor(int level) {
    if (level <= 3) return Colors.red;
    if (level <= 6) return Colors.orange;
    return Colors.green;
  }
}
