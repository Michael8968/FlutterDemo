import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';

/// 个人档案头部组件
class ProfileHeader extends StatelessWidget {
  final UserProfile? profile;
  final VoidCallback? onEditTap;

  const ProfileHeader({
    super.key,
    this.profile,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: profile?.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profile!.avatarUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
                const SizedBox(width: 16),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.nickname ?? '未设置昵称',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (profile != null) ...[
                        Text(
                          _buildSubtitle(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 编辑按钮
                IconButton(
                  onPressed: onEditTap,
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 档案完成度
            _buildCompletionProgress(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Text(
      profile?.gender?.emoji ?? '👤',
      style: const TextStyle(fontSize: 36),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (profile?.gender != null) {
      parts.add(profile!.gender!.displayName);
    }
    if (profile?.age != null) {
      parts.add('${profile!.age}岁');
    }
    if (profile?.bloodType != null &&
        profile!.bloodType != BloodType.unknown) {
      parts.add(profile!.bloodType!.displayName);
    }
    return parts.isEmpty ? '点击编辑完善资料' : parts.join(' · ');
  }

  Widget _buildCompletionProgress(BuildContext context) {
    final completion = profile?.completionRate ?? 0;
    final percentage = (completion * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_ind,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '档案完成度 $percentage%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: completion,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
