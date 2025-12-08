import 'package:flutter/material.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import 'period_selector.dart';

/// 心情趋势图
class MoodTrendChart extends StatelessWidget {
  final List<DiaryEntry> diaries;
  final StatsPeriod period;

  const MoodTrendChart({
    super.key,
    required this.diaries,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (diaries.isEmpty) {
      return _buildEmptyState();
    }

    // 按日期排序
    final sortedDiaries = List<DiaryEntry>.from(diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 计算心情统计
    final moodStats = _calculateMoodStats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mood, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '心情趋势',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 心情分布
            _buildMoodDistribution(moodStats),
            const SizedBox(height: 16),

            // 简易趋势图
            SizedBox(
              height: 120,
              child: _buildTrendChart(context, sortedDiaries),
            ),
            const SizedBox(height: 12),

            // 平均心情
            _buildAverageMood(),
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
            Icon(Icons.mood, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              '心情趋势',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '暂无心情数据',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, int> _calculateMoodStats() {
    final stats = <int, int>{};
    for (final diary in diaries) {
      final moodValue = diary.mood.value;
      stats[moodValue] = (stats[moodValue] ?? 0) + 1;
    }
    return stats;
  }

  Widget _buildMoodDistribution(Map<int, int> stats) {
    final total = diaries.length;
    final moodLabels = ['很差', '较差', '一般', '较好', '很好'];
    final moodColors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        final value = index + 1;
        final count = stats[value] ?? 0;
        final percentage = total > 0 ? (count / total * 100) : 0.0;

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: moodColors[index].withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: moodColors[index],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              moodLabels[index],
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTrendChart(BuildContext context, List<DiaryEntry> sortedDiaries) {
    if (sortedDiaries.length < 2) {
      return Center(
        child: Text(
          '需要更多数据才能显示趋势',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return CustomPaint(
      painter: _MoodChartPainter(
        diaries: sortedDiaries,
        primaryColor: Theme.of(context).primaryColor,
      ),
      size: const Size(double.infinity, 120),
    );
  }

  Widget _buildAverageMood() {
    if (diaries.isEmpty) return const SizedBox.shrink();

    final avgMood =
        diaries.map((d) => d.mood.value).reduce((a, b) => a + b) / diaries.length;
    final moodText = avgMood >= 4
        ? '心情不错'
        : avgMood >= 3
            ? '心情一般'
            : '心情欠佳';
    final moodColor = avgMood >= 4
        ? Colors.green
        : avgMood >= 3
            ? Colors.amber
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: moodColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '平均心情: ${avgMood.toStringAsFixed(1)}/5',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: moodColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($moodText)',
            style: TextStyle(
              color: moodColor,
            ),
          ),
          const Spacer(),
          Text(
            '共${diaries.length}条记录',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 心情趋势图绘制
class _MoodChartPainter extends CustomPainter {
  final List<DiaryEntry> diaries;
  final Color primaryColor;

  _MoodChartPainter({
    required this.diaries,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (diaries.length < 2) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (diaries.length - 1);
    final maxY = size.height - 20;

    for (int i = 0; i < diaries.length; i++) {
      final x = i * stepX;
      final y = maxY - (diaries[i].mood.value / 5) * (maxY - 10);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, maxY);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // 绘制数据点
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // 完成填充路径
    fillPath.lineTo(size.width, maxY);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
