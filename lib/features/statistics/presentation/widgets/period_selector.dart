import 'package:flutter/material.dart';

/// 统计周期枚举
enum StatsPeriod {
  week('本周', 7),
  month('本月', 30),
  quarter('季度', 90),
  year('全年', 365);

  final String displayName;
  final int days;

  const StatsPeriod(this.displayName, this.days);
}

/// 周期选择器
class PeriodSelector extends StatelessWidget {
  final StatsPeriod selectedPeriod;
  final ValueChanged<StatsPeriod> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StatsPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onPeriodChanged(period);
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
