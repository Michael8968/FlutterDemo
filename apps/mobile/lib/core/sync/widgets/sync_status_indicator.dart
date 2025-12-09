import 'package:flutter/material.dart';
import '../sync_manager.dart';

/// 同步状态指示器 Widget
/// 显示当前同步状态，包括同步中、成功、失败、离线等状态
class SyncStatusIndicator extends StatelessWidget {
  final SyncManager syncManager;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    required this.syncManager,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: syncManager,
      builder: (context, _) {
        return GestureDetector(
          onTap: onTap ?? () => _showSyncDetails(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(),
                const SizedBox(width: 6),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTextColor(context),
                  ),
                ),
                if (syncManager.pendingCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${syncManager.pendingCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon() {
    switch (syncManager.state) {
      case SyncState.syncing:
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      case SyncState.success:
        return const Icon(Icons.cloud_done, size: 16, color: Colors.green);
      case SyncState.failed:
        return const Icon(Icons.cloud_off, size: 16, color: Colors.red);
      case SyncState.offline:
        return const Icon(Icons.wifi_off, size: 16, color: Colors.grey);
      case SyncState.notLoggedIn:
        return const Icon(Icons.person_off, size: 16, color: Colors.orange);
      case SyncState.idle:
      default:
        if (syncManager.pendingCount > 0) {
          return const Icon(Icons.cloud_upload, size: 16, color: Colors.blue);
        }
        return const Icon(Icons.cloud_done, size: 16, color: Colors.green);
    }
  }

  String _getStatusText() {
    switch (syncManager.state) {
      case SyncState.syncing:
        return '同步中...';
      case SyncState.success:
        return '已同步';
      case SyncState.failed:
        return '同步失败';
      case SyncState.offline:
        return '离线';
      case SyncState.notLoggedIn:
        return '未登录';
      case SyncState.idle:
      default:
        if (syncManager.pendingCount > 0) {
          return '待同步';
        }
        return '已同步';
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (syncManager.state) {
      case SyncState.syncing:
        return colorScheme.primaryContainer.withOpacity(0.5);
      case SyncState.success:
        return Colors.green.withOpacity(0.1);
      case SyncState.failed:
        return Colors.red.withOpacity(0.1);
      case SyncState.offline:
        return Colors.grey.withOpacity(0.1);
      case SyncState.notLoggedIn:
        return Colors.orange.withOpacity(0.1);
      case SyncState.idle:
      default:
        if (syncManager.pendingCount > 0) {
          return colorScheme.primaryContainer.withOpacity(0.3);
        }
        return Colors.green.withOpacity(0.1);
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (syncManager.state) {
      case SyncState.syncing:
        return Theme.of(context).colorScheme.primary;
      case SyncState.success:
        return Colors.green;
      case SyncState.failed:
        return Colors.red;
      case SyncState.offline:
        return Colors.grey;
      case SyncState.notLoggedIn:
        return Colors.orange;
      case SyncState.idle:
      default:
        if (syncManager.pendingCount > 0) {
          return Theme.of(context).colorScheme.primary;
        }
        return Colors.green;
    }
  }

  void _showSyncDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SyncDetailsSheet(syncManager: syncManager),
    );
  }
}

/// 同步详情 Sheet
class _SyncDetailsSheet extends StatelessWidget {
  final SyncManager syncManager;

  const _SyncDetailsSheet({required this.syncManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: syncManager,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_sync, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '云同步状态',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context,
                  '登录状态',
                  syncManager.isLoggedIn ? '已登录' : '未登录',
                  syncManager.isLoggedIn ? Colors.green : Colors.orange,
                ),
                _buildInfoRow(
                  context,
                  '网络状态',
                  syncManager.isOnline ? '在线' : '离线',
                  syncManager.isOnline ? Colors.green : Colors.grey,
                ),
                _buildInfoRow(
                  context,
                  '待同步数量',
                  '${syncManager.pendingCount} 项',
                  syncManager.pendingCount > 0 ? Colors.blue : Colors.green,
                ),
                if (syncManager.lastSyncTime != null)
                  _buildInfoRow(
                    context,
                    '上次同步',
                    _formatTime(syncManager.lastSyncTime!),
                    Colors.grey,
                  ),
                if (syncManager.lastError != null)
                  _buildInfoRow(
                    context,
                    '错误信息',
                    syncManager.lastError!,
                    Colors.red,
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: syncManager.canSync
                        ? () {
                            syncManager.syncNow();
                            Navigator.pop(context);
                          }
                        : null,
                    icon: const Icon(Icons.sync),
                    label: const Text('立即同步'),
                  ),
                ),
                if (!syncManager.isLoggedIn) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: 导航到登录页面
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('登录账号'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} 小时前';
    } else {
      return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
