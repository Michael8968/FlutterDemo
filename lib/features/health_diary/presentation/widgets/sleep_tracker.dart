import 'package:flutter/material.dart';
import '../../domain/entities/mood_level.dart';

/// 睡眠追踪组件
class SleepTracker extends StatelessWidget {
  final double? sleepHours;
  final SleepQuality? sleepQuality;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<SleepQuality> onQualityChanged;

  const SleepTracker({
    super.key,
    this.sleepHours,
    this.sleepQuality,
    required this.onHoursChanged,
    required this.onQualityChanged,
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
                const Icon(Icons.bedtime, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  '睡眠记录',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 睡眠时长
            Row(
              children: [
                const Text('睡眠时长'),
                const Spacer(),
                Text(
                  sleepHours != null
                      ? '${sleepHours!.toStringAsFixed(1)} 小时'
                      : '未记录',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: sleepHours != null
                        ? _getSleepColor(sleepHours!)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            Slider(
              value: sleepHours ?? 7,
              min: 0,
              max: 14,
              divisions: 28,
              activeColor: sleepHours != null
                  ? _getSleepColor(sleepHours!)
                  : Colors.grey,
              onChanged: onHoursChanged,
            ),

            const SizedBox(height: 8),

            // 睡眠质量
            const Text('睡眠质量'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: SleepQuality.values.map((quality) {
                final isSelected = quality == sleepQuality;
                return GestureDetector(
                  onTap: () => onQualityChanged(quality),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.indigo
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _getQualityEmoji(quality),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quality.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.indigo : Colors.grey,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSleepColor(double hours) {
    if (hours < 5) return Colors.red;
    if (hours < 6) return Colors.orange;
    if (hours < 7) return Colors.yellow.shade700;
    if (hours <= 9) return Colors.green;
    return Colors.orange;
  }

  String _getQualityEmoji(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.veryPoor:
        return '😫';
      case SleepQuality.poor:
        return '😴';
      case SleepQuality.fair:
        return '😐';
      case SleepQuality.good:
        return '😊';
      case SleepQuality.excellent:
        return '😴💤';
    }
  }
}

/// 睡眠时长显示条
class SleepBar extends StatelessWidget {
  final double hours;
  final double maxHours;

  const SleepBar({
    super.key,
    required this.hours,
    this.maxHours = 10,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (hours / maxHours).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('睡眠'),
            Text(
              '${hours.toStringAsFixed(1)}h',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: _getColor(hours),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(double hours) {
    if (hours < 5) return Colors.red;
    if (hours < 6) return Colors.orange;
    if (hours < 7) return Colors.yellow.shade700;
    if (hours <= 9) return Colors.green;
    return Colors.orange;
  }
}
