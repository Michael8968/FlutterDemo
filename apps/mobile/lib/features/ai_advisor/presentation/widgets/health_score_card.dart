import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 健康评分卡片
class HealthScoreCard extends StatelessWidget {
  final int score;
  final Map<String, double> categoryScores;
  final List<String> highlights;
  final List<String> concerns;

  const HealthScoreCard({
    super.key,
    required this.score,
    required this.categoryScores,
    this.highlights = const [],
    this.concerns = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 主评分
            Row(
              children: [
                // 圆形进度
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _ScoreCirclePainter(
                      score: score,
                      color: _getScoreColor(score),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score),
                            ),
                          ),
                          Text(
                            '健康分',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // 评分说明
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getScoreLabel(score),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(score),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getScoreDescription(score),
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
            const SizedBox(height: 20),
            // 分类评分
            if (categoryScores.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              _buildCategoryScores(),
            ],
            // 亮点和关注点
            if (highlights.isNotEmpty || concerns.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildHighlightsAndConcerns(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScores() {
    final categories = {
      'sleep': ('睡眠', Icons.bedtime),
      'mood': ('心情', Icons.mood),
      'stress': ('压力', Icons.psychology),
      'symptoms': ('症状', Icons.healing),
      'activity': ('活动', Icons.directions_run),
      'goals': ('目标', Icons.flag),
    };

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: categoryScores.entries.map((entry) {
        final category = categories[entry.key];
        if (category == null) return const SizedBox.shrink();

        final scoreValue = entry.value.round();
        return SizedBox(
          width: 80,
          child: Column(
            children: [
              Icon(
                category.$2,
                color: _getScoreColor(scoreValue),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                category.$1,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$scoreValue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(scoreValue),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHighlightsAndConcerns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (highlights.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: highlights.map((h) => _buildTag(h, Colors.green)).toList(),
          ),
          const SizedBox(height: 8),
        ],
        if (concerns.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: concerns.map((c) => _buildTag(c, Colors.orange)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color.shade700,
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return '非常健康';
    if (score >= 80) return '健康良好';
    if (score >= 70) return '基本健康';
    if (score >= 60) return '需要关注';
    if (score >= 40) return '亚健康';
    return '需要改善';
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return '继续保持良好的生活习惯';
    if (score >= 60) return '部分指标可以改善';
    if (score >= 40) return '建议关注健康建议';
    return '请重点关注健康问题';
  }
}

/// 评分圆环绘制器
class _ScoreCirclePainter extends CustomPainter {
  final int score;
  final Color color;

  _ScoreCirclePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // 背景圆环
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 进度圆环
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCirclePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
