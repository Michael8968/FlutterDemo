import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

/// 成就卡片
class AchievementCard extends StatelessWidget {
  final AchievementDefinition definition;
  final UserAchievement? userAchievement;
  final VoidCallback? onShare;
  final bool showUnlockTime;

  const AchievementCard({
    super.key,
    required this.definition,
    this.userAchievement,
    this.onShare,
    this.showUnlockTime = false,
  });

  bool get isUnlocked => userAchievement?.isUnlocked ?? false;
  double get progress => userAchievement?.progress ?? 0;
  int get currentValue => userAchievement?.currentValue ?? 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 2 : 0,
      color: isUnlocked ? null : Colors.grey.shade100,
      child: InkWell(
        onTap: isUnlocked ? onShare : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 成就图标
              _buildIcon(),
              const SizedBox(width: 12),
              // 成就信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 等级徽章
                        _buildLevelBadge(),
                        const SizedBox(width: 8),
                        // 名称
                        Expanded(
                          child: Text(
                            definition.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? null : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        // 分享按钮
                        if (isUnlocked && onShare != null)
                          IconButton(
                            icon: const Icon(Icons.share, size: 18),
                            onPressed: onShare,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 描述
                    Text(
                      definition.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 进度条或解锁时间
                    if (showUnlockTime && isUnlocked)
                      _buildUnlockTime()
                    else
                      _buildProgressBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isUnlocked
            ? definition.category.color.withOpacity(0.15)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            definition.category.icon,
            size: 28,
            color: isUnlocked ? definition.category.color : Colors.grey.shade400,
          ),
          if (isUnlocked)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  definition.level.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    final colors = _getLevelColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(colors: colors)
            : null,
        color: isUnlocked ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        definition.level.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isUnlocked ? Colors.white : Colors.grey.shade500,
        ),
      ),
    );
  }

  List<Color> _getLevelColors() {
    switch (definition.level) {
      case AchievementLevel.bronze:
        return [const Color(0xFFCD7F32), const Color(0xFFB87333)];
      case AchievementLevel.silver:
        return [const Color(0xFFC0C0C0), const Color(0xFFA8A8A8)];
      case AchievementLevel.gold:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case AchievementLevel.platinum:
        return [const Color(0xFF00CED1), const Color(0xFF20B2AA)];
      case AchievementLevel.diamond:
        return [const Color(0xFF9400D3), const Color(0xFF4B0082)];
    }
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentValue / ${definition.targetValue} ${definition.unit}',
              style: TextStyle(
                fontSize: 11,
                color: isUnlocked ? definition.category.color : Colors.grey.shade500,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                color: isUnlocked ? definition.category.color : Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isUnlocked ? definition.category.color : Colors.grey.shade400,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockTime() {
    final unlockDate = userAchievement!.unlockedAt;
    final dateStr =
        '${unlockDate.year}/${unlockDate.month}/${unlockDate.day}';

    return Row(
      children: [
        Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
        const SizedBox(width: 4),
        Text(
          '解锁于 $dateStr',
          style: TextStyle(
            fontSize: 11,
            color: Colors.green.shade600,
          ),
        ),
      ],
    );
  }
}
