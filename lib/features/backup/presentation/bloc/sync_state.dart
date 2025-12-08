import 'package:equatable/equatable.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/services/sync_manager.dart';

/// 同步状态
class SyncState extends Equatable {
  // 认证状态
  final bool isLoggedIn;
  final String? userId;
  final String? userEmail;

  // 同步状态
  final SyncStateStatus status;
  final DateTime? lastSyncTime;

  // 备份列表
  final List<BackupInfo> cloudBackups;

  // 冲突列表
  final List<SyncConflict> conflicts;

  // 同步结果
  final SyncResult? lastSyncResult;

  // 错误信息
  final String? error;

  // 进度信息
  final double? progress;
  final String? progressMessage;

  const SyncState({
    this.isLoggedIn = false,
    this.userId,
    this.userEmail,
    this.status = SyncStateStatus.initial,
    this.lastSyncTime,
    this.cloudBackups = const [],
    this.conflicts = const [],
    this.lastSyncResult,
    this.error,
    this.progress,
    this.progressMessage,
  });

  /// 初始状态
  factory SyncState.initial() => const SyncState();

  /// 复制状态
  SyncState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? userEmail,
    SyncStateStatus? status,
    DateTime? lastSyncTime,
    List<BackupInfo>? cloudBackups,
    List<SyncConflict>? conflicts,
    SyncResult? lastSyncResult,
    String? error,
    double? progress,
    String? progressMessage,
    bool clearError = false,
    bool clearProgress = false,
  }) {
    return SyncState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      cloudBackups: cloudBackups ?? this.cloudBackups,
      conflicts: conflicts ?? this.conflicts,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      error: clearError ? null : (error ?? this.error),
      progress: clearProgress ? null : (progress ?? this.progress),
      progressMessage: clearProgress ? null : (progressMessage ?? this.progressMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoggedIn,
        userId,
        userEmail,
        status,
        lastSyncTime,
        cloudBackups,
        conflicts,
        lastSyncResult,
        error,
        progress,
        progressMessage,
      ];
}

/// 同步状态枚举
enum SyncStateStatus {
  initial,       // 初始状态
  loading,       // 加载中
  authenticating, // 认证中
  syncing,       // 同步中
  uploading,     // 上传中
  downloading,   // 下载中
  success,       // 成功
  failure,       // 失败
  conflict,      // 存在冲突
}

extension SyncStateStatusX on SyncStateStatus {
  bool get isLoading =>
      this == SyncStateStatus.loading ||
      this == SyncStateStatus.authenticating ||
      this == SyncStateStatus.syncing ||
      this == SyncStateStatus.uploading ||
      this == SyncStateStatus.downloading;

  String get displayName {
    switch (this) {
      case SyncStateStatus.initial:
        return '就绪';
      case SyncStateStatus.loading:
        return '加载中';
      case SyncStateStatus.authenticating:
        return '认证中';
      case SyncStateStatus.syncing:
        return '同步中';
      case SyncStateStatus.uploading:
        return '上传中';
      case SyncStateStatus.downloading:
        return '下载中';
      case SyncStateStatus.success:
        return '成功';
      case SyncStateStatus.failure:
        return '失败';
      case SyncStateStatus.conflict:
        return '存在冲突';
    }
  }
}
