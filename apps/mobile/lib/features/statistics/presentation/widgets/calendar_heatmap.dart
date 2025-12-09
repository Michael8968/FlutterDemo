import 'package:flutter/material.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import 'period_selector.dart';

/// 热力图数据类型
enum HeatmapDataType {
  mood('心情', Icons.mood),
  sleep('睡眠', Icons.bedtime),
  energy('精力', Icons.battery_charging_full),
  stress('压力', Icons.psychology),
  activity('活动', Icons.directions_run);

  final String displayName;
  final IconData icon;

  const HeatmapDataType(this.displayName, this.icon);
}

/// 日历热力图
class CalendarHeatmap extends StatefulWidget {
  final List<DiaryEntry> diaries;
  final StatsPeriod period;

  const CalendarHeatmap({
    super.key,
    required this.diaries,
    required this.period,
  });

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  HeatmapDataType _selectedType = HeatmapDataType.mood;

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
                Icon(Icons.calendar_month, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  '日历热力图',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 数据类型选择
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: HeatmapDataType.values.map((type) {
                  final isSelected = type == _selectedType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        type.icon,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      label: Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = type);
                        }
                      },
                      selectedColor: Colors.teal,
                      checkmarkColor: Colors.white,
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // 热力图
            _buildHeatmap(),
            const SizedBox(height: 12),
            // 图例
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap() {
    final now = DateTime.now();
    final weeksToShow = _getWeeksToShow();
    final startDate = now.subtract(Duration(days: weeksToShow * 7 - 1));

    // 创建日期到数据的映射
    final diaryMap = <String, DiaryEntry>{};
    for (final diary in widget.diaries) {
      final key = _dateKey(diary.date);
      diaryMap[key] = diary;
    }

    return Column(
      children: [
        // 星期标题
        Row(
          children: [
            const SizedBox(width: 24),
            ...['一', '二', '三', '四', '五', '六', '日'].map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        // 热力图网格
        SizedBox(
          height: weeksToShow * 20.0,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weeksToShow,
            itemBuilder: (context, weekIndex) {
              final weekStart =
                  startDate.add(Duration(days: weekIndex * 7));
              return _buildWeekRow(weekStart, diaryMap, weekIndex == 0);
            },
          ),
        ),
      ],
    );
  }

  int _getWeeksToShow() {
    switch (widget.period) {
      case StatsPeriod.week:
        return 2;
      case StatsPeriod.month:
        return 5;
      case StatsPeriod.quarter:
        return 13;
      case StatsPeriod.year:
        return 12; // 只显示最近12周避免太长
    }
  }

  Widget _buildWeekRow(
    DateTime weekStart,
    Map<String, DiaryEntry> diaryMap,
    bool showMonth,
  ) {
    final now = DateTime.now();

    // 调整到周一
    final monday = weekStart.subtract(Duration(days: weekStart.weekday - 1));

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          // 月份标签
          SizedBox(
            width: 24,
            child: showMonth || monday.day <= 7
                ? Text(
                    '${monday.month}月',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                  )
                : null,
          ),
          // 一周的格子
          ...List.generate(7, (dayIndex) {
            final date = monday.add(Duration(days: dayIndex));
            final key = _dateKey(date);
            final diary = diaryMap[key];
            final isFuture = date.isAfter(now);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: GestureDetector(
                  onTap: diary != null ? () => _showDiaryDetail(diary) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isFuture
                          ? Colors.grey.shade100
                          : _getColorForDiary(diary),
                      borderRadius: BorderRadius.circular(3),
                      border: _isToday(date)
                          ? Border.all(color: Colors.teal, width: 2)
                          : null,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Color _getColorForDiary(DiaryEntry? diary) {
    if (diary == null) return Colors.grey.shade200;

    double? value;
    double maxValue = 5;

    switch (_selectedType) {
      case HeatmapDataType.mood:
        value = diary.mood.value.toDouble();
        maxValue = 5;
        break;
      case HeatmapDataType.sleep:
        value = diary.sleepHours;
        maxValue = 10;
        break;
      case HeatmapDataType.energy:
        value = diary.energyLevel?.toDouble();
        maxValue = 10;
        break;
      case HeatmapDataType.stress:
        // 压力越低越好，所以反转
        value = diary.stressLevel != null ? (10 - diary.stressLevel!).toDouble() : null;
        maxValue = 10;
        break;
      case HeatmapDataType.activity:
        value = diary.activities.length.toDouble();
        maxValue = 5;
        break;
    }

    if (value == null) return Colors.grey.shade200;

    // 计算颜色强度 (0-1)
    final intensity = (value / maxValue).clamp(0.0, 1.0);

    // 根据类型选择颜色
    final baseColor = _getBaseColor();
    return Color.lerp(
      baseColor.withOpacity(0.1),
      baseColor,
      intensity,
    )!;
  }

  Color _getBaseColor() {
    switch (_selectedType) {
      case HeatmapDataType.mood:
        return Colors.pink;
      case HeatmapDataType.sleep:
        return Colors.indigo;
      case HeatmapDataType.energy:
        return Colors.green;
      case HeatmapDataType.stress:
        return Colors.orange;
      case HeatmapDataType.activity:
        return Colors.blue;
    }
  }

  Widget _buildLegend() {
    final baseColor = _getBaseColor();
    final levels = [0.1, 0.3, 0.5, 0.7, 1.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '少',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 4),
        ...levels.map((level) => Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Color.lerp(
                  baseColor.withOpacity(0.1),
                  baseColor,
                  level,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            )),
        const SizedBox(width: 4),
        Text(
          '多',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '无数据',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _showDiaryDetail(DiaryEntry diary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${diary.date.month}月${diary.date.day}日',
          style: const TextStyle(fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('心情', diary.mood.displayName, Icons.mood),
            if (diary.sleepHours != null)
              _buildDetailRow(
                '睡眠',
                '${diary.sleepHours!.toStringAsFixed(1)}小时',
                Icons.bedtime,
              ),
            if (diary.energyLevel != null)
              _buildDetailRow(
                '精力',
                '${diary.energyLevel}/10',
                Icons.battery_charging_full,
              ),
            if (diary.stressLevel != null)
              _buildDetailRow(
                '压力',
                '${diary.stressLevel}/10',
                Icons.psychology,
              ),
            if (diary.activities.isNotEmpty)
              _buildDetailRow(
                '活动',
                diary.activities.map((a) => a.displayName).join(', '),
                Icons.directions_run,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
