import 'package:flutter/material.dart';
import '../../domain/entities/health_goal.dart';

/// 添加健康目标页面
class AddGoalPage extends StatefulWidget {
  final List<HealthGoal> existingGoals;

  const AddGoalPage({super.key, this.existingGoals = const []});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  GoalType? _selectedType;
  double _targetValue = 0;

  @override
  Widget build(BuildContext context) {
    // 过滤已有的目标类型
    final existingTypes = widget.existingGoals.map((g) => g.type).toSet();
    final availableTypes =
        GoalType.values.where((t) => !existingTypes.contains(t)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加健康目标'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '选择目标类型',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (availableTypes.isEmpty)
                  _buildAllGoalsAdded()
                else
                  ...availableTypes.map((type) => _buildGoalTypeCard(type)),
                if (_selectedType != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '设置目标值',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTargetValueInput(),
                ],
              ],
            ),
          ),
          // 底部按钮
          if (_selectedType != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _targetValue > 0 ? _createGoal : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('创建目标'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllGoalsAdded() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            '所有目标类型都已添加',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '你可以在个人中心管理已有的目标',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTypeCard(GoalType type) {
    final isSelected = _selectedType == type;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            _targetValue = _getDefaultTarget(type);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    type.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '单位: ${type.unit}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetValueInput() {
    if (_selectedType == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  _selectedType!.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedType!.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '目标: ${_targetValue.toStringAsFixed(_getDecimalPlaces())} ${_selectedType!.unit}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 滑块
            Slider(
              value: _targetValue,
              min: _getMinTarget(),
              max: _getMaxTarget(),
              divisions: _getDivisions(),
              label: _targetValue.toStringAsFixed(_getDecimalPlaces()),
              onChanged: (value) {
                setState(() => _targetValue = value);
              },
            ),
            // 快捷按钮
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _getQuickValues().map((value) {
                final isSelected = _targetValue == value;
                return ChoiceChip(
                  label: Text('$value'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _targetValue = value);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _createGoal() {
    if (_selectedType == null || _targetValue <= 0) return;

    final now = DateTime.now();
    final goal = HealthGoal(
      id: '',
      type: _selectedType!,
      targetValue: _targetValue,
      startDate: now,
      createdAt: now,
      updatedAt: now,
    );

    Navigator.pop(context, goal);
  }

  double _getDefaultTarget(GoalType type) {
    switch (type) {
      case GoalType.sleep:
        return 8;
      case GoalType.exercise:
        return 30;
      case GoalType.water:
        return 8;
      case GoalType.steps:
        return 8000;
      case GoalType.weight:
        return 65;
      case GoalType.meditation:
        return 15;
      case GoalType.reading:
        return 30;
      case GoalType.noPhone:
        return 2;
    }
  }

  double _getMinTarget() {
    switch (_selectedType) {
      case GoalType.sleep:
        return 4;
      case GoalType.exercise:
        return 10;
      case GoalType.water:
        return 4;
      case GoalType.steps:
        return 2000;
      case GoalType.weight:
        return 40;
      case GoalType.meditation:
        return 5;
      case GoalType.reading:
        return 10;
      case GoalType.noPhone:
        return 0.5;
      default:
        return 0;
    }
  }

  double _getMaxTarget() {
    switch (_selectedType) {
      case GoalType.sleep:
        return 12;
      case GoalType.exercise:
        return 120;
      case GoalType.water:
        return 16;
      case GoalType.steps:
        return 20000;
      case GoalType.weight:
        return 150;
      case GoalType.meditation:
        return 60;
      case GoalType.reading:
        return 120;
      case GoalType.noPhone:
        return 8;
      default:
        return 100;
    }
  }

  int _getDivisions() {
    switch (_selectedType) {
      case GoalType.sleep:
        return 16;
      case GoalType.exercise:
        return 22;
      case GoalType.water:
        return 12;
      case GoalType.steps:
        return 18;
      case GoalType.weight:
        return 110;
      case GoalType.meditation:
        return 11;
      case GoalType.reading:
        return 11;
      case GoalType.noPhone:
        return 15;
      default:
        return 10;
    }
  }

  int _getDecimalPlaces() {
    switch (_selectedType) {
      case GoalType.sleep:
      case GoalType.noPhone:
      case GoalType.weight:
        return 1;
      default:
        return 0;
    }
  }

  List<double> _getQuickValues() {
    switch (_selectedType) {
      case GoalType.sleep:
        return [6, 7, 8, 9];
      case GoalType.exercise:
        return [20, 30, 45, 60];
      case GoalType.water:
        return [6, 8, 10, 12];
      case GoalType.steps:
        return [5000, 8000, 10000, 15000];
      case GoalType.weight:
        return [55, 60, 65, 70];
      case GoalType.meditation:
        return [10, 15, 20, 30];
      case GoalType.reading:
        return [15, 30, 45, 60];
      case GoalType.noPhone:
        return [1, 2, 3, 4];
      default:
        return [];
    }
  }

  Color _getTypeColor(GoalType type) {
    switch (type) {
      case GoalType.sleep:
        return Colors.indigo;
      case GoalType.exercise:
        return Colors.orange;
      case GoalType.water:
        return Colors.blue;
      case GoalType.steps:
        return Colors.green;
      case GoalType.weight:
        return Colors.purple;
      case GoalType.meditation:
        return Colors.teal;
      case GoalType.reading:
        return Colors.brown;
      case GoalType.noPhone:
        return Colors.red;
    }
  }
}
