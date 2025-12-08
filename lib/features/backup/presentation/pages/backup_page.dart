import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/services/backup_service.dart';
import '../../domain/services/cloud_sync_service.dart';

/// 备份与同步页面
class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BackupService? _backupService;
  final MockCloudSyncService _cloudService = MockCloudSyncService();

  List<BackupInfo> _localBackups = [];
  List<BackupInfo> _cloudBackups = [];
  SyncSettings _settings = const SyncSettings();
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    final prefs = await SharedPreferences.getInstance();
    _backupService = BackupService(prefs);
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    if (_backupService != null) {
      final localBackups = await _backupService!.getLocalBackups();
      final settings = _backupService!.getSyncSettings();
      final cloudBackups = await _cloudService.getCloudBackups();

      setState(() {
        _localBackups = localBackups;
        _cloudBackups = cloudBackups;
        _settings = settings;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备份与同步'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '本地备份'),
            Tab(text: '云端同步'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLocalBackupTab(),
                _buildCloudSyncTab(),
              ],
            ),
    );
  }

  Widget _buildLocalBackupTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 快速操作卡片
          _buildQuickActionsCard(),
          const SizedBox(height: 16),

          // 自动备份设置
          _buildAutoBackupCard(),
          const SizedBox(height: 16),

          // 本地备份列表
          _buildBackupListCard(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
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
                  '快速操作',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isBackingUp ? null : _createBackup,
                    icon: _isBackingUp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup),
                    label: Text(_isBackingUp ? '备份中...' : '立即备份'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRestoring ? null : _importBackup,
                    icon: _isRestoring
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_upload),
                    label: Text(_isRestoring ? '恢复中...' : '导入备份'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 最后备份时间
            if (_settings.lastBackupTime != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '上次备份: ${_formatDate(_settings.lastBackupTime!)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoBackupCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '自动备份',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('启用自动备份'),
              subtitle: Text(
                _settings.autoBackupEnabled
                    ? '每${_settings.autoBackupIntervalDays}天自动备份一次'
                    : '关闭自动备份',
              ),
              value: _settings.autoBackupEnabled,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(autoBackupEnabled: value);
                });
                _backupService?.saveSyncSettings(_settings);
              },
            ),
            if (_settings.autoBackupEnabled) ...[
              const Divider(),
              ListTile(
                title: const Text('备份频率'),
                trailing: DropdownButton<int>(
                  value: _settings.autoBackupIntervalDays,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('每天')),
                    DropdownMenuItem(value: 3, child: Text('每3天')),
                    DropdownMenuItem(value: 7, child: Text('每周')),
                    DropdownMenuItem(value: 14, child: Text('每两周')),
                    DropdownMenuItem(value: 30, child: Text('每月')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings = _settings.copyWith(autoBackupIntervalDays: value);
                      });
                      _backupService?.saveSyncSettings(_settings);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackupListCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.folder, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  '本地备份',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_localBackups.length}个备份',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_localBackups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      '暂无备份',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _localBackups.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final backup = _localBackups[index];
                return _buildBackupTile(backup);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBackupTile(BackupInfo backup) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backup.type == BackupType.auto
              ? Colors.blue.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          backup.type == BackupType.auto ? Icons.schedule : Icons.save,
          color: backup.type == BackupType.auto ? Colors.blue : Colors.green,
        ),
      ),
      title: Text(
        backup.fileName,
        style: const TextStyle(fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${backup.dateDisplay} · ${backup.fileSizeDisplay}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleBackupAction(value, backup),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'restore', child: Text('恢复')),
          const PopupMenuItem(value: 'share', child: Text('分享')),
          const PopupMenuItem(
            value: 'delete',
            child: Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 云端账户卡片
        _buildCloudAccountCard(),
        const SizedBox(height: 16),

        // 同步操作卡片
        if (_cloudService.isLoggedIn) ...[
          _buildCloudActionsCard(),
          const SizedBox(height: 16),
          _buildCloudBackupListCard(),
        ],
      ],
    );
  }

  Widget _buildCloudAccountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '云端账户',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_cloudService.isLoggedIn) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _cloudService.userEmail ?? '用户',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '已登录',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _signOut,
                      child: const Text('退出'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    const Text('登录后即可使用云端同步功能'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showLoginDialog(isSignUp: false),
                          child: const Text('登录'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => _showLoginDialog(isSignUp: true),
                          child: const Text('注册'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCloudActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sync, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '同步操作',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _uploadToCloud,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('上传到云端'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _syncFromCloud,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('从云端同步'),
                  ),
                ),
              ],
            ),
            if (_settings.lastSyncTime != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '上次同步: ${_formatDate(_settings.lastSyncTime!)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCloudBackupListCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.cloud_queue, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '云端备份',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_cloudBackups.length}个备份',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_cloudBackups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      '暂无云端备份',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cloudBackups.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final backup = _cloudBackups[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.cloud, color: Colors.blue),
                  ),
                  title: Text(
                    backup.fileName,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${backup.dateDisplay} · ${backup.fileSizeDisplay}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteCloudBackup(backup),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 操作方法
  Future<void> _createBackup() async {
    if (_backupService == null) return;

    setState(() => _isBackingUp = true);

    final result = await _backupService!.createBackup();

    setState(() => _isBackingUp = false);

    if (mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备份成功'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? '备份失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    // 显示提示对话框
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入备份'),
        content: const Text(
          '请将备份文件放置到应用备份目录中，然后在备份列表中选择恢复。\n\n'
          '或者您可以通过其他应用分享备份文件到此应用。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBackupAction(String action, BackupInfo backup) async {
    switch (action) {
      case 'restore':
        await _restoreBackup(backup);
        break;
      case 'share':
        await _backupService?.shareBackup(backup.fileName);
        break;
      case 'delete':
        await _deleteBackup(backup);
        break;
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    if (_backupService == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text(
          '恢复备份将覆盖当前数据，此操作不可撤销。确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('确认恢复'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);

    final backupDir = await _backupService!.exportBackup(backup.fileName);
    if (backupDir != null) {
      final result = await _backupService!.restoreFromFile(backupDir);

      setState(() => _isRestoring = false);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('恢复成功，共恢复 ${result.totalRestored} 条数据'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? '恢复失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除备份 "${backup.fileName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _backupService?.deleteBackup(backup.fileName);
      if (success == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已删除')),
          );
        }
      }
    }
  }

  void _showLoginDialog({required bool isSignUp}) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSignUp ? '注册账户' : '登录账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '邮箱',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = isSignUp
                  ? await _cloudService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                    )
                  : await _cloudService.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                    );

              if (mounted) {
                Navigator.pop(context);
                if (result.success) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSignUp ? '注册成功' : '登录成功'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.error ?? '操作失败'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isSignUp ? '注册' : '登录'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await _cloudService.signOut();
    setState(() {});
  }

  Future<void> _uploadToCloud() async {
    if (_backupService == null) return;

    // 先创建本地备份
    final localResult = await _backupService!.createBackup();
    if (!localResult.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localResult.error ?? '备份失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 上传到云端（模拟）
    final backup = BackupData(
      version: '1.0.0',
      createdAt: DateTime.now(),
      deviceInfo: 'Device',
      content: const BackupContent(),
    );

    final result = await _cloudService.uploadBackup(backup);

    if (mounted) {
      if (result.success) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('上传成功'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? '上传失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncFromCloud() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('同步功能开发中...')),
    );
  }

  Future<void> _deleteCloudBackup(BackupInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除此云端备份吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true && backup.cloudId != null) {
      await _cloudService.deleteCloudBackup(backup.cloudId!);
      await _loadData();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
