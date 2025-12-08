import 'package:flutter/material.dart';
import '../../domain/entities/health_advice.dart';

/// 健康建议卡片
class AdviceCard extends StatelessWidget {
  final HealthAdvice advice;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AdviceCard({
    super.key,
    required this.advice,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getTypeColor(advice.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(advice.type),
                      color: _getTypeColor(advice.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 标题和描述
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                advice.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildPriorityBadge(advice.priority),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advice.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 行动项
              if (advice.actionItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                ...advice.actionItems.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: _getTypeColor(advice.type),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              // 原因说明
              if (advice.reason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          advice.reason!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // 底部操作
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    advice.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  if (onDismiss != null)
                    TextButton(
                      onPressed: onDismiss,
                      child: const Text('忽略'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(AdvicePriority priority) {
    Color color;
    String text;

    switch (priority) {
      case AdvicePriority.high:
        color = Colors.red;
        text = '重要';
        break;
      case AdvicePriority.medium:
        color = Colors.orange;
        text = '建议';
        break;
      case AdvicePriority.low:
        color = Colors.blue;
        text = '提示';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  IconData _getTypeIcon(AdviceType type) {
    switch (type) {
      case AdviceType.sleep:
        return Icons.bedtime;
      case AdviceType.mood:
        return Icons.mood;
      case AdviceType.exercise:
        return Icons.fitness_center;
      case AdviceType.nutrition:
        return Icons.restaurant;
      case AdviceType.stress:
        return Icons.self_improvement;
      case AdviceType.symptom:
        return Icons.healing;
      case AdviceType.hydration:
        return Icons.water_drop;
      case AdviceType.general:
        return Icons.tips_and_updates;
    }
  }

  Color _getTypeColor(AdviceType type) {
    switch (type) {
      case AdviceType.sleep:
        return Colors.indigo;
      case AdviceType.mood:
        return Colors.amber.shade700;
      case AdviceType.exercise:
        return Colors.orange;
      case AdviceType.nutrition:
        return Colors.green;
      case AdviceType.stress:
        return Colors.purple;
      case AdviceType.symptom:
        return Colors.red;
      case AdviceType.hydration:
        return Colors.blue;
      case AdviceType.general:
        return Colors.teal;
    }
  }
}
