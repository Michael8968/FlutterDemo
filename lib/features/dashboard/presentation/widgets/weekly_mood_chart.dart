import 'package:flutter/material.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';

/// 周心情趋势图
class WeeklyMoodChart extends StatelessWidget {
  final List<DiaryEntry> weekDiaries;

  const WeeklyMoodChart({
    super.key,
    required this.weekDiaries,
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
                Icon(Icons.show_chart, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '本周心情',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: _buildChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        final diary = _findDiaryForDate(date);
        final isToday = date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
        final isFuture = date.isAfter(now);

        return _buildDayColumn(
          context,
          day: ['一', '二', '三', '四', '五', '六', '日'][index],
          diary: diary,
          isToday: isToday,
          isFuture: isFuture,
        );
      }),
    );
  }

  DiaryEntry? _findDiaryForDate(DateTime date) {
    try {
      return weekDiaries.firstWhere((d) =>
          d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  Widget _buildDayColumn(
    BuildContext context, {
    required String day,
    DiaryEntry? diary,
    required bool isToday,
    required bool isFuture,
  }) {
    final moodValue = diary?.mood.value ?? 0;
    const maxHeight = 60.0;
    final barHeight = diary != null ? (moodValue / 5) * maxHeight : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (diary != null) ...[
          Text(
            diary.mood.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: barHeight,
          decoration: BoxDecoration(
            color: diary != null
                ? Color(int.parse('0xFF${diary.mood.colorHex}'))
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isToday
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday
                  ? Colors.white
                  : isFuture
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

/// 健康提示卡片
class HealthTipCard extends StatelessWidget {
  final String tip;
  final IconData icon;
  final Color color;

  const HealthTipCard({
    super.key,
    required this.tip,
    this.icon = Icons.lightbulb_outline,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: TextStyle(
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
