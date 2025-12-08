import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../core/network/models/auth_response.dart';
import '../../../../core/network/models/sync_response.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/services/cloud_sync_service.dart';

/// API 云同步服务实现
/// 实现 CloudSyncService 接口，调用实际的后端 API
class ApiCloudSyncService implements CloudSyncService {
  final ApiService _apiService;
  final TokenManager _tokenManager;
  final SharedPreferences _prefs;

  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;

  ApiCloudSyncService({
    required ApiService apiService,
    required TokenManager tokenManager,
    required SharedPreferences prefs,
  })  : _apiService = apiService,
        _tokenManager = tokenManager,
        _prefs = prefs {
    _loadLastSyncTime();
  }

  void _loadLastSyncTime() {
    final timeStr = _prefs.getString(AppConstants.keyLastSyncTime);
    if (timeStr != null) {
      _lastSyncTime = DateTime.tryParse(timeStr);
    }
  }

  Future<void> _saveLastSyncTime(DateTime time) async {
    _lastSyncTime = time;
    await _prefs.setString(AppConstants.keyLastSyncTime, time.toIso8601String());
  }

  // ============ 认证相关 ============

  @override
  bool get isLoggedIn => _tokenManager.isLoggedIn;

  @override
  String? get userId => _tokenManager.userId;

  @override
  String? get userEmail => _tokenManager.userEmail;

  @override
  SyncStatus get syncStatus => _syncStatus;

  @override
  DateTime? get lastSyncTime => _lastSyncTime;

  @override
  Future<CloudAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      await _tokenManager.saveAuthResponse(response);

      return CloudAuthResult.success(
        userId: response.userId,
        email: response.email,
      );
    } catch (e) {
      return CloudAuthResult.failure(_getErrorMessage(e));
    }
  }

  @override
  Future<CloudAuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequest(email: email, password: password);
      final response = await _apiService.register(request);

      await _tokenManager.saveAuthResponse(response);

      return CloudAuthResult.success(
        userId: response.userId,
        email: response.email,
      );
    } catch (e) {
      return CloudAuthResult.failure(_getErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _apiService.logout();
    } catch (_) {
      // 即使服务端登出失败，也清除本地 Token
    } finally {
      await _tokenManager.clearAll();
      _syncStatus = SyncStatus.idle;
    }
  }

  // ============ 备份操作 ============

  @override
  Future<CloudSyncResult> uploadBackup(BackupData backup) async {
    if (!isLoggedIn) {
      return CloudSyncResult.failure('请先登录');
    }

    _syncStatus = SyncStatus.syncing;

    try {
      final backupJson = backup.toJson();
      final response = await _apiService.uploadBackup(backupJson);

      _syncStatus = SyncStatus.success;
      await _saveLastSyncTime(DateTime.now());

      return CloudSyncResult.success(data: response);
    } catch (e) {
      _syncStatus = SyncStatus.failed;
      return CloudSyncResult.failure(_getErrorMessage(e));
    }
  }

  @override
  Future<CloudSyncResult<BackupData>> downloadBackup(String backupId) async {
    if (!isLoggedIn) {
      return CloudSyncResult.failure('请先登录');
    }

    _syncStatus = SyncStatus.syncing;

    try {
      final response = await _apiService.downloadBackup(backupId);
      final backup = BackupData.fromJson(response.toJson());

      _syncStatus = SyncStatus.success;

      return CloudSyncResult.success(data: backup);
    } catch (e) {
      _syncStatus = SyncStatus.failed;
      return CloudSyncResult.failure(_getErrorMessage(e));
    }
  }

  @override
  Future<List<BackupInfo>> getCloudBackups() async {
    if (!isLoggedIn) return [];

    try {
      final responses = await _apiService.getBackups();

      return responses.map((r) => BackupInfo(
        id: r.id,
        fileName: r.fileName,
        createdAt: r.createdAt,
        fileSize: r.fileSize,
        type: BackupType.cloud,
        cloudId: r.id,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> deleteCloudBackup(String backupId) async {
    if (!isLoggedIn) return false;

    try {
      await _apiService.deleteBackup(backupId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ 数据同步 ============

  @override
  Future<CloudSyncResult> syncData(BackupContent localData) async {
    if (!isLoggedIn) {
      return CloudSyncResult.failure('请先登录');
    }

    _syncStatus = SyncStatus.syncing;

    try {
      // 构建增量同步请求
      final request = IncrementalSyncRequest(
        lastSyncTime: _lastSyncTime,
        localChanges: LocalChanges(
          diaries: localData.diaries,
          symptoms: localData.symptoms,
          profile: localData.profile,
        ),
        deviceId: await _getDeviceId(),
      );

      final response = await _apiService.syncIncremental(request);

      if (response.conflictCount > 0) {
        _syncStatus = SyncStatus.conflict;
        return CloudSyncResult(
          success: true,
          status: SyncStatus.conflict,
          data: response,
        );
      }

      _syncStatus = SyncStatus.success;
      await _saveLastSyncTime(response.serverTime);

      return CloudSyncResult.success(data: response);
    } catch (e) {
      _syncStatus = SyncStatus.failed;
      return CloudSyncResult.failure(_getErrorMessage(e));
    }
  }

  /// 获取服务器端变更
  Future<CloudSyncResult<SyncChangesResponse>> getServerChanges() async {
    if (!isLoggedIn) {
      return CloudSyncResult.failure('请先登录');
    }

    try {
      final since = _lastSyncTime?.toIso8601String() ??
          DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

      final response = await _apiService.getChanges(since, null);

      return CloudSyncResult.success(data: response);
    } catch (e) {
      return CloudSyncResult.failure(_getErrorMessage(e));
    }
  }

  /// 获取设备标识
  Future<String> _getDeviceId() async {
    var deviceId = _prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  /// 提取错误消息
  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
