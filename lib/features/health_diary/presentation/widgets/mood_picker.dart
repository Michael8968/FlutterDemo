import 'package:flutter/material.dart';
import '../../domain/entities/mood_level.dart';

/// 心情选择器组件
class MoodPicker extends StatelessWidget {
  final MoodLevel? selectedMood;
  final ValueChanged<MoodLevel> onMoodSelected;

  const MoodPicker({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今天心情如何？',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: MoodLevel.values.map((mood) {
            final isSelected = mood == selectedMood;
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(int.parse('0xFF${mood.colorHex}'))
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: Color(int.parse('0xFF${mood.colorHex}')),
                          width: 2,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Color(int.parse('0xFF${mood.colorHex}'))
                                .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      mood.emoji,
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// 紧凑版心情显示
class MoodDisplay extends StatelessWidget {
  final MoodLevel mood;
  final double size;

  const MoodDisplay({
    super.key,
    required this.mood,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(int.parse('0xFF${mood.colorHex}')).withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          mood.emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
