import 'package:equatable/equatable.dart';
import '../../domain/services/sync_manager.dart';

/// 同步事件基类
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化事件
class SyncInitialized extends SyncEvent {
  const SyncInitialized();
}

/// 登录事件
class SyncLoginRequested extends SyncEvent {
  final String email;
  final String password;

  const SyncLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// 注册事件
class SyncRegisterRequested extends SyncEvent {
  final String email;
  final String password;

  const SyncRegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// 登出事件
class SyncLogoutRequested extends SyncEvent {
  const SyncLogoutRequested();
}

/// 上传备份事件
class SyncUploadRequested extends SyncEvent {
  const SyncUploadRequested();
}

/// 下载备份事件
class SyncDownloadRequested extends SyncEvent {
  final String backupId;

  const SyncDownloadRequested({required this.backupId});

  @override
  List<Object?> get props => [backupId];
}

/// 执行同步事件
class SyncPerformRequested extends SyncEvent {
  const SyncPerformRequested();
}

/// 获取云端备份列表事件
class SyncLoadCloudBackups extends SyncEvent {
  const SyncLoadCloudBackups();
}

/// 删除云端备份事件
class SyncDeleteCloudBackup extends SyncEvent {
  final String backupId;

  const SyncDeleteCloudBackup({required this.backupId});

  @override
  List<Object?> get props => [backupId];
}

/// 解决冲突事件
class SyncResolveConflict extends SyncEvent {
  final SyncConflict conflict;
  final ConflictResolution resolution;

  const SyncResolveConflict({
    required this.conflict,
    required this.resolution,
  });

  @override
  List<Object?> get props => [conflict, resolution];
}

/// 清除错误事件
class SyncErrorCleared extends SyncEvent {
  const SyncErrorCleared();
}
