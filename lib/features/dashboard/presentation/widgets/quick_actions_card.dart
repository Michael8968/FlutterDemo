import 'package:flutter/material.dart';

/// 快捷操作卡片
class QuickActionsCard extends StatelessWidget {
  final VoidCallback? onRecordMood;
  final VoidCallback? onRecordSymptom;
  final VoidCallback? onViewDiary;
  final VoidCallback? onViewStats;
  final VoidCallback? onViewAiAdvisor;

  const QuickActionsCard({
    super.key,
    this.onRecordMood,
    this.onRecordSymptom,
    this.onViewDiary,
    this.onViewStats,
    this.onViewAiAdvisor,
  });

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
                Icon(Icons.flash_on, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '快捷操作',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.mood,
                  label: '记心情',
                  color: Colors.pink,
                  onTap: onRecordMood,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.healing,
                  label: '记症状',
                  color: Colors.red,
                  onTap: onRecordSymptom,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.book,
                  label: '写日记',
                  color: Colors.blue,
                  onTap: onViewDiary,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.analytics,
                  label: '看统计',
                  color: Colors.purple,
                  onTap: onViewStats,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.smart_toy,
                  label: 'AI顾问',
                  color: Colors.teal,
                  onTap: onViewAiAdvisor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
