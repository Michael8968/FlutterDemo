import 'package:flutter/material.dart';
import '../../domain/entities/symptom_category.dart';

/// 严重程度滑块组件
class SeveritySlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const SeveritySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 5) return Colors.yellow.shade700;
    if (severity <= 8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final level = SeverityLevel.fromScore(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '严重程度',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getSeverityColor(value).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$value - ${level.displayName}',
                style: TextStyle(
                  color: _getSeverityColor(value),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _getSeverityColor(value),
            thumbColor: _getSeverityColor(value),
            overlayColor: _getSeverityColor(value).withOpacity(0.2),
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Text(
          level.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
