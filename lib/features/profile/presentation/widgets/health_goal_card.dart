import 'package:flutter/material.dart';
import '../../domain/entities/health_goal.dart';

/// 健康目标卡片
class HealthGoalCard extends StatelessWidget {
  final HealthGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(double)? onProgressUpdate;

  const HealthGoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onDelete,
    this.onProgressUpdate,
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
                  // 图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getGoalColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        goal.type.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 标题和进度
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.type.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          goal.progressDescription,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 完成状态
                  if (goal.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '完成',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      '${goal.completionPercentage.toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getGoalColor(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.completionPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getGoalColor()),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              // 快捷操作按钮
              Row(
                children: [
                  if (goal.streakDays > 0) ...[
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '连续${goal.streakDays}天',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  // 增加按钮
                  _buildQuickButton(
                    context,
                    icon: Icons.remove,
                    onTap: () => _updateProgress(-_getStep()),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickButton(
                    context,
                    icon: Icons.add,
                    onTap: () => _updateProgress(_getStep()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  void _updateProgress(double delta) {
    final newValue = goal.currentValue + delta;
    if (newValue >= 0 && onProgressUpdate != null) {
      onProgressUpdate!(newValue);
    }
  }

  double _getStep() {
    switch (goal.type) {
      case GoalType.sleep:
        return 0.5;
      case GoalType.exercise:
        return 10;
      case GoalType.water:
        return 1;
      case GoalType.steps:
        return 1000;
      case GoalType.weight:
        return 0.5;
      case GoalType.meditation:
        return 5;
      case GoalType.reading:
        return 10;
      case GoalType.noPhone:
        return 0.5;
    }
  }

  Color _getGoalColor() {
    switch (goal.type) {
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

/// 添加目标卡片
class AddGoalCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AddGoalCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '添加健康目标',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
