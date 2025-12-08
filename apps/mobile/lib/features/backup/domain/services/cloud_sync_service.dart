import '../entities/backup_data.dart';

/// 云同步服务接口
/// 可以通过实现此接口来对接不同的云服务（Firebase, AWS, 自建服务器等）
abstract class CloudSyncService {
  /// 检查是否已登录
  bool get isLoggedIn;

  /// 获取用户ID
  String? get userId;

  /// 获取用户邮箱
  String? get userEmail;

  /// 登录
  Future<CloudAuthResult> signIn({
    required String email,
    required String password,
  });

  /// 注册
  Future<CloudAuthResult> signUp({
    required String email,
    required String password,
  });

  /// 退出登录
  Future<void> signOut();

  /// 上传备份到云端
  Future<CloudSyncResult> uploadBackup(BackupData backup);

  /// 从云端下载备份
  Future<CloudSyncResult<BackupData>> downloadBackup(String backupId);

  /// 获取云端备份列表
  Future<List<BackupInfo>> getCloudBackups();

  /// 删除云端备份
  Future<bool> deleteCloudBackup(String backupId);

  /// 同步数据（双向合并）
  Future<CloudSyncResult> syncData(BackupContent localData);

  /// 获取同步状态
  SyncStatus get syncStatus;

  /// 获取最后同步时间
  DateTime? get lastSyncTime;
}

/// 云认证结果
class CloudAuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? error;

  const CloudAuthResult({
    required this.success,
    this.userId,
    this.email,
    this.error,
  });

  factory CloudAuthResult.success({
    required String userId,
    required String email,
  }) {
    return CloudAuthResult(
      success: true,
      userId: userId,
      email: email,
    );
  }

  factory CloudAuthResult.failure(String error) {
    return CloudAuthResult(
      success: false,
      error: error,
    );
  }
}

/// 云同步结果
class CloudSyncResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final SyncStatus status;

  const CloudSyncResult({
    required this.success,
    this.data,
    this.error,
    this.status = SyncStatus.idle,
  });

  factory CloudSyncResult.success({T? data}) {
    return CloudSyncResult(
      success: true,
      data: data,
      status: SyncStatus.success,
    );
  }

  factory CloudSyncResult.failure(String error) {
    return CloudSyncResult(
      success: false,
      error: error,
      status: SyncStatus.failed,
    );
  }
}

/// 模拟云同步服务（用于演示）
class MockCloudSyncService implements CloudSyncService {
  bool _isLoggedIn = false;
  String? _userId;
  String? _userEmail;
  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  final List<BackupInfo> _mockBackups = [];

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  String? get userId => _userId;

  @override
  String? get userEmail => _userEmail;

  @override
  SyncStatus get syncStatus => _syncStatus;

  @override
  DateTime? get lastSyncTime => _lastSyncTime;

  @override
  Future<CloudAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 模拟登录验证
    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = email;
      return CloudAuthResult.success(
        userId: _userId!,
        email: email,
      );
    }

    return CloudAuthResult.failure('邮箱或密码错误');
  }

  @override
  Future<CloudAuthResult> signUp({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!email.contains('@')) {
      return CloudAuthResult.failure('请输入有效的邮箱地址');
    }
    if (password.length < 6) {
      return CloudAuthResult.failure('密码长度至少6位');
    }

    _isLoggedIn = true;
    _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = email;
    return CloudAuthResult.success(
      userId: _userId!,
      email: email,
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = false;
    _userId = null;
    _userEmail = null;
  }

  @override
  Future<CloudSyncResult> uploadBackup(BackupData backup) async {
    if (!_isLoggedIn) {
      return CloudSyncResult.failure('请先登录');
    }

    _syncStatus = SyncStatus.syncing;
    await Future.delayed(const Duration(seconds: 2));

    // 模拟上传
    final info = BackupInfo(
      id: 'cloud_${DateTime.now().millisecondsSinceEpoch}',
      fileName: 'cloud_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      createdAt: DateTime.now(),
      fileSize: 1024 * (10 + DateTime.now().millisecond % 100),
      type: BackupType.cloud,
      cloudId: 'cloud_${DateTime.now().millisecondsSinceEpoch}',
    );
    _mockBackups.insert(0, info);

    _syncStatus = SyncStatus.success;
    _lastSyncTime = DateTime.now();
    return CloudSyncResult.success();
  }

  @override
  Future<CloudSyncResult<BackupData>> downloadBackup(String backupId) async {
    if (!_isLoggedIn) {
      return CloudSyncResult.failure('请先登录');
    }

    _syncStatus = SyncStatus.syncing;
    await Future.delayed(const Duration(seconds: 2));

    // 模拟下载 - 返回空数据
    final backup = BackupData(
      version: '1.0.0',
      createdAt: DateTime.now(),
      deviceInfo: 'Cloud Backup',
      content: const BackupContent(),
    );

    _syncStatus = SyncStatus.success;
    return CloudSyncResult.success(data: backup);
  }

  @override
  Future<List<BackupInfo>> getCloudBackups() async {
    if (!_isLoggedIn) return [];

    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockBackups);
  }

  @override
  Future<bool> deleteCloudBackup(String backupId) async {
    if (!_isLoggedIn) return false;

    await Future.delayed(const Duration(milliseconds: 500));
    _mockBackups.removeWhere((b) => b.cloudId == backupId);
    return true;
  }

  @override
  Future<CloudSyncResult> syncData(BackupContent localData) async {
    if (!_isLoggedIn) {
      return CloudSyncResult.failure('请先登录');
    }

    _syncStatus = SyncStatus.syncing;
    await Future.delayed(const Duration(seconds: 2));

    _syncStatus = SyncStatus.success;
    _lastSyncTime = DateTime.now();
    return CloudSyncResult.success();
  }
}
