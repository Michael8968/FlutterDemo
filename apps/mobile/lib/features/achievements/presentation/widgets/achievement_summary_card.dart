import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

/// 成就摘要卡片
class AchievementSummaryCard extends StatelessWidget {
  final AchievementSummary summary;
  final VoidCallback? onShareTap;

  const AchievementSummaryCard({
    super.key,
    required this.summary,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题栏
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '成就收集',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 分享按钮
              if (onShareTap != null)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: onShareTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 进度圆环
          Row(
            children: [
              // 进度圆环
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: summary.completionRate,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${summary.totalUnlocked}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/${summary.totalAvailable}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // 勋章统计
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMedalRow('🥉', '铜牌', summary.bronzeCount),
                    _buildMedalRow('🥈', '银牌', summary.silverCount),
                    _buildMedalRow('🥇', '金牌', summary.goldCount),
                    _buildMedalRow('💎', '白金', summary.platinumCount),
                    _buildMedalRow('💠', '钻石', summary.diamondCount),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 总积分
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '总积分：${summary.totalPoints}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalRow(String emoji, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            'x$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 成就解锁弹窗
class AchievementUnlockedDialog extends StatelessWidget {
  final UserAchievement achievement;
  final VoidCallback? onShare;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final definition = achievement.definition;
    if (definition == null) return const SizedBox.shrink();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 庆祝动画
            const Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              '恭喜解锁新成就！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // 成就图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: definition.category.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    definition.category.icon,
                    size: 40,
                    color: definition.category.color,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Text(
                      definition.level.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 成就名称
            Text(
              definition.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // 成就描述
            Text(
              definition.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            // 等级徽章
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: definition.category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${definition.level.displayName} • ${definition.category.displayName}',
                style: TextStyle(
                  color: definition.category.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onShare?.call();
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('分享'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
