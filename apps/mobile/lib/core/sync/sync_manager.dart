import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_service.dart';
import '../network/token_manager.dart';
import '../network/models/sync_response.dart';
import '../constants/app_constants.dart';

/// 同步状态枚举
enum SyncState {
  idle,        // 空闲
  syncing,     // 同步中
  success,     // 同步成功
  failed,      // 同步失败
  offline,     // 离线状态
  notLoggedIn, // 未登录
}

/// 待同步的变更类型
enum ChangeType { create, update, delete }

/// 待同步的变更记录
class PendingChange {
  final String id;
  final String dataType; // 'diary', 'symptom', 'profile'
  final ChangeType changeType;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  PendingChange({
    required this.id,
    required this.dataType,
    required this.changeType,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'dataType': dataType,
        'changeType': changeType.name,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PendingChange.fromJson(Map<String, dynamic> json) => PendingChange(
        id: json['id'] as String,
        dataType: json['dataType'] as String,
        changeType: ChangeType.values.byName(json['changeType'] as String),
        data: json['data'] as Map<String, dynamic>?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// 同步管理器 - 实现离线优先 + 自动同步
class SyncManager extends ChangeNotifier {
  final ApiService _apiService;
  final TokenManager _tokenManager;
  final SharedPreferences _prefs;

  SyncState _state = SyncState.idle;
  DateTime? _lastSyncTime;
  String? _lastError;
  int _pendingCount = 0;
  bool _isOnline = true;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _autoSyncTimer;

  // 待同步队列
  final List<PendingChange> _pendingChanges = [];

  // 防抖定时器
  Timer? _debounceTimer;

  SyncManager({
    required ApiService apiService,
    required TokenManager tokenManager,
    required SharedPreferences prefs,
  })  : _apiService = apiService,
        _tokenManager = tokenManager,
        _prefs = prefs {
    _init();
  }

  // ============ Getters ============

  SyncState get state => _state;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastError => _lastError;
  int get pendingCount => _pendingCount;
  bool get isOnline => _isOnline;
  bool get isLoggedIn => _tokenManager.isLoggedIn;
  bool get canSync => _isOnline && isLoggedIn;

  // ============ 初始化 ============

  Future<void> _init() async {
    // 加载上次同步时间
    _loadLastSyncTime();

    // 加载待同步队列
    await _loadPendingChanges();

    // 监听网络状态
    _startConnectivityMonitoring();

    // 启动自动同步定时器 (每5分钟)
    _startAutoSyncTimer();

    // 初始检查网络状态
    await _checkConnectivity();

    // 如果在线且已登录，尝试同步
    if (canSync && _pendingChanges.isNotEmpty) {
      _scheduleSyncWithDebounce();
    }
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

  // ============ 网络监听 ============

  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _onConnectivityChanged(result);
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOffline = !_isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (_isOnline) {
      if (_state == SyncState.offline) {
        _state = SyncState.idle;
      }
      // 网络恢复时自动同步
      if (wasOffline && canSync && _pendingChanges.isNotEmpty) {
        _scheduleSyncWithDebounce();
      }
    } else {
      _state = SyncState.offline;
    }

    notifyListeners();
  }

  void _startAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        if (canSync && _pendingChanges.isNotEmpty) {
          syncNow();
        }
      },
    );
  }

  // ============ 待同步队列管理 ============

  Future<void> _loadPendingChanges() async {
    final jsonList = _prefs.getStringList('pending_sync_changes') ?? [];
    _pendingChanges.clear();

    for (final jsonStr in jsonList) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        _pendingChanges.add(PendingChange.fromJson(json));
      } catch (e) {
        debugPrint('Failed to parse pending change: $e');
      }
    }

    _pendingCount = _pendingChanges.length;
  }

  Future<void> _savePendingChanges() async {
    final jsonList = _pendingChanges
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await _prefs.setStringList('pending_sync_changes', jsonList);
    _pendingCount = _pendingChanges.length;
    notifyListeners();
  }

  /// 添加待同步变更
  Future<void> addPendingChange(PendingChange change) async {
    // 移除同一项的旧变更（合并）
    _pendingChanges.removeWhere(
      (c) => c.id == change.id && c.dataType == change.dataType,
    );

    // 添加新变更
    _pendingChanges.add(change);

    await _savePendingChanges();

    // 触发自动同步（带防抖）
    if (canSync) {
      _scheduleSyncWithDebounce();
    }
  }

  void _scheduleSyncWithDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (canSync && _pendingChanges.isNotEmpty) {
        syncNow();
      }
    });
  }

  // ============ 同步操作 ============

  /// 立即同步
  Future<bool> syncNow() async {
    if (!canSync) {
      if (!_isOnline) {
        _state = SyncState.offline;
      } else if (!isLoggedIn) {
        _state = SyncState.notLoggedIn;
      }
      notifyListeners();
      return false;
    }

    if (_state == SyncState.syncing) {
      return false; // 已在同步中
    }

    _state = SyncState.syncing;
    _lastError = null;
    notifyListeners();

    try {
      // 1. 上传本地变更
      if (_pendingChanges.isNotEmpty) {
        await _uploadChanges();
      }

      // 2. 下载服务器变更
      await _downloadChanges();

      _state = SyncState.success;
      await _saveLastSyncTime(DateTime.now());

      // 清空已同步的队列
      _pendingChanges.clear();
      await _savePendingChanges();

      notifyListeners();
      return true;
    } catch (e) {
      _state = SyncState.failed;
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _uploadChanges() async {
    // 按类型分组变更
    final diaries = <Map<String, dynamic>>[];
    final symptoms = <Map<String, dynamic>>[];
    Map<String, dynamic>? profile;
    final deletedIds = <String>[];

    for (final change in _pendingChanges) {
      if (change.changeType == ChangeType.delete) {
        deletedIds.add('${change.dataType}:${change.id}');
      } else if (change.data != null) {
        switch (change.dataType) {
          case 'diary':
            diaries.add(change.data!);
            break;
          case 'symptom':
            symptoms.add(change.data!);
            break;
          case 'profile':
            profile = change.data;
            break;
        }
      }
    }

    final request = IncrementalSyncRequest(
      lastSyncTime: _lastSyncTime,
      localChanges: LocalChanges(
        diaries: diaries,
        symptoms: symptoms,
        profile: profile,
        deletedIds: deletedIds,
      ),
      deviceId: await _getDeviceId(),
    );

    await _apiService.syncIncremental(request);
  }

  Future<void> _downloadChanges() async {
    final since = _lastSyncTime?.toIso8601String() ??
        DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

    final response = await _apiService.getChanges(since, null);

    // 通知监听者处理服务器变更
    if (response.totalChanges > 0) {
      _onServerChangesReceived?.call(response);
    }
  }

  // 服务器变更回调
  void Function(SyncChangesResponse)? _onServerChangesReceived;

  void setOnServerChangesReceived(void Function(SyncChangesResponse) callback) {
    _onServerChangesReceived = callback;
  }

  Future<String> _getDeviceId() async {
    var deviceId = _prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  // ============ 清理 ============

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _autoSyncTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
