import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../health_diary/data/datasources/diary_local_datasource.dart';
import '../../../symptom_tracker/data/datasources/symptom_local_datasource.dart';
import '../../../profile/data/datasources/profile_local_datasource.dart';
import '../../data/services/api_cloud_sync_service.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/services/backup_service.dart';
import '../../domain/services/sync_manager.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';

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
  SyncBloc? _syncBloc;

  List<BackupInfo> _localBackups = [];
  SyncSettings _settings = const SyncSettings();
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initServices();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    _backupService = BackupService(prefs);

    // 初始化云同步服务
    final apiClient = ApiClient();
    final tokenManager = TokenManager(prefs);
    apiClient.setTokenManager(tokenManager);
    final apiService = ApiService(apiClient.dio);

    final cloudService = ApiCloudSyncService(
      apiService: apiService,
      tokenManager: tokenManager,
      prefs: prefs,
    );

    final syncManager = SyncManager(
      cloudService: cloudService,
      diaryDataSource: DiaryLocalDataSourceImpl(),
      symptomDataSource: SymptomLocalDataSourceImpl(),
      profileDataSource: ProfileLocalDataSourceImpl(),
    );

    _syncBloc = SyncBloc(
      cloudService: cloudService,
      backupService: _backupService!,
      syncManager: syncManager,
    );

    _syncBloc!.add(const SyncInitialized());

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    if (_backupService != null) {
      final localBackups = await _backupService!.getLocalBackups();
      final settings = _backupService!.getSyncSettings();

      setState(() {
        _localBackups = localBackups;
        _settings = settings;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _syncBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_syncBloc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('备份与同步')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider.value(
      value: _syncBloc!,
      child: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state.error != null) {
            SnackBarHelper.showError(context, state.error!);
            _syncBloc!.add(const SyncErrorCleared());
          }

          if (state.status == SyncStateStatus.success) {
            _loadData();
          }
        },
        child: Scaffold(
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
        ),
      ),
    );
  }

  Widget _buildLocalBackupTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildQuickActionsCard(),
          const SizedBox(height: 16),
          _buildAutoBackupCard(),
          const SizedBox(height: 16),
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
                      '上次备份: ${DateFormatter.formatDateTime(_settings.lastBackupTime!)}',
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
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCloudAccountCard(state),
            const SizedBox(height: 16),
            if (state.isLoggedIn) ...[
              _buildCloudActionsCard(state),
              const SizedBox(height: 16),
              _buildCloudBackupListCard(state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCloudAccountCard(SyncState state) {
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
            if (state.isLoggedIn) ...[
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
                            state.userEmail ?? '用户',
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
                      onPressed: () => _syncBloc!.add(const SyncLogoutRequested()),
                      child: const Text('退出'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (state.status == SyncStateStatus.authenticating)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
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

  Widget _buildCloudActionsCard(SyncState state) {
    final isSyncing = state.status.isLoading;

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
            if (isSyncing && state.progressMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(state.progressMessage!),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSyncing
                        ? null
                        : () => _syncBloc!.add(const SyncUploadRequested()),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('上传到云端'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSyncing
                        ? null
                        : () => _syncBloc!.add(const SyncPerformRequested()),
                    icon: const Icon(Icons.sync),
                    label: const Text('双向同步'),
                  ),
                ),
              ],
            ),
            if (state.lastSyncTime != null) ...[
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
                      '上次同步: ${DateFormatter.formatDateTime(state.lastSyncTime!)}',
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

  Widget _buildCloudBackupListCard(SyncState state) {
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
                  '${state.cloudBackups.length}个备份',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (state.cloudBackups.isEmpty)
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
              itemCount: state.cloudBackups.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final backup = state.cloudBackups[index];
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () => _syncBloc!.add(
                          SyncDownloadRequested(backupId: backup.cloudId!),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteCloudBackup(backup),
                      ),
                    ],
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
        SnackBarHelper.showSuccess(context, '备份成功');
        await _loadData();
      } else {
        SnackBarHelper.showError(context, result.error ?? '备份失败');
      }
    }
  }

  Future<void> _importBackup() async {
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

    final backupPath = await _backupService!.exportBackup(backup.fileName);
    if (backupPath != null) {
      final result = await _backupService!.restoreFromFile(backupPath);

      setState(() => _isRestoring = false);

      if (mounted) {
        if (result.success) {
          SnackBarHelper.showSuccess(context, '恢复成功，共恢复 ${result.totalRestored} 条数据');
        } else {
          SnackBarHelper.showError(context, result.error ?? '恢复失败');
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
          SnackBarHelper.show(context, '已删除');
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
            onPressed: () {
              Navigator.pop(context);
              if (isSignUp) {
                _syncBloc!.add(SyncRegisterRequested(
                  email: emailController.text,
                  password: passwordController.text,
                ));
              } else {
                _syncBloc!.add(SyncLoginRequested(
                  email: emailController.text,
                  password: passwordController.text,
                ));
              }
            },
            child: Text(isSignUp ? '注册' : '登录'),
          ),
        ],
      ),
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
      _syncBloc!.add(SyncDeleteCloudBackup(backupId: backup.cloudId!));
    }
  }
}
