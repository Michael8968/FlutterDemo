import 'package:flutter/material.dart';
import '../../domain/entities/mood_level.dart';

/// 活动选择器组件
class ActivityPicker extends StatelessWidget {
  final List<ActivityType> selectedActivities;
  final ValueChanged<ActivityType> onActivityToggled;

  const ActivityPicker({
    super.key,
    required this.selectedActivities,
    required this.onActivityToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日活动',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ActivityType.values.map((activity) {
            final isSelected = selectedActivities.contains(activity);
            return GestureDetector(
              onTap: () => onActivityToggled(activity),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activity.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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

/// 天气选择器
class WeatherPicker extends StatelessWidget {
  final WeatherType? selectedWeather;
  final ValueChanged<WeatherType> onWeatherSelected;

  const WeatherPicker({
    super.key,
    this.selectedWeather,
    required this.onWeatherSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日天气',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WeatherType.values.map((weather) {
            final isSelected = weather == selectedWeather;
            return GestureDetector(
              onTap: () => onWeatherSelected(weather),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      weather.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue : Colors.grey.shade700,
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
