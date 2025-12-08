import 'package:json_annotation/json_annotation.dart';

part 'sync_response.g.dart';

/// 通用 API 响应包装
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final int code;
  final String? message;
  final T? data;
  final String? timestamp;

  const ApiResponse({
    required this.success,
    required this.code,
    this.message,
    this.data,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

/// 云端备份响应模型
@JsonSerializable()
class BackupResponse {
  final String id;

  @JsonKey(name: 'file_name')
  final String fileName;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'file_size')
  final int fileSize;

  @JsonKey(name: 'device_info')
  final String? deviceInfo;

  final String? version;

  const BackupResponse({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
    this.deviceInfo,
    this.version,
  });

  factory BackupResponse.fromJson(Map<String, dynamic> json) =>
      _$BackupResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BackupResponseToJson(this);
}

/// 同步变更响应模型
@JsonSerializable()
class SyncChangesResponse {
  final List<Map<String, dynamic>> diaries;
  final List<Map<String, dynamic>> symptoms;
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> achievements;
  final List<Map<String, dynamic>> reminders;
  final Map<String, dynamic>? settings;

  @JsonKey(name: 'server_time')
  final DateTime serverTime;

  @JsonKey(name: 'has_more')
  final bool hasMore;

  const SyncChangesResponse({
    this.diaries = const [],
    this.symptoms = const [],
    this.profile,
    this.achievements = const [],
    this.reminders = const [],
    this.settings,
    required this.serverTime,
    this.hasMore = false,
  });

  factory SyncChangesResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncChangesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncChangesResponseToJson(this);

  int get totalChanges =>
      diaries.length +
      symptoms.length +
      achievements.length +
      reminders.length +
      (profile != null ? 1 : 0);
}

/// 增量同步请求模型
@JsonSerializable()
class IncrementalSyncRequest {
  @JsonKey(name: 'last_sync_time')
  final DateTime? lastSyncTime;

  @JsonKey(name: 'local_changes')
  final LocalChanges localChanges;

  @JsonKey(name: 'device_id')
  final String deviceId;

  const IncrementalSyncRequest({
    this.lastSyncTime,
    required this.localChanges,
    required this.deviceId,
  });

  factory IncrementalSyncRequest.fromJson(Map<String, dynamic> json) =>
      _$IncrementalSyncRequestFromJson(json);

  Map<String, dynamic> toJson() => _$IncrementalSyncRequestToJson(this);
}

/// 本地变更数据
@JsonSerializable()
class LocalChanges {
  final List<Map<String, dynamic>> diaries;
  final List<Map<String, dynamic>> symptoms;
  final Map<String, dynamic>? profile;

  @JsonKey(name: 'deleted_ids')
  final List<String> deletedIds;

  const LocalChanges({
    this.diaries = const [],
    this.symptoms = const [],
    this.profile,
    this.deletedIds = const [],
  });

  factory LocalChanges.fromJson(Map<String, dynamic> json) =>
      _$LocalChangesFromJson(json);

  Map<String, dynamic> toJson() => _$LocalChangesToJson(this);

  bool get isEmpty =>
      diaries.isEmpty &&
      symptoms.isEmpty &&
      profile == null &&
      deletedIds.isEmpty;
}

/// 同步结果响应
@JsonSerializable()
class SyncResultResponse {
  final bool success;

  @JsonKey(name: 'synced_count')
  final int syncedCount;

  @JsonKey(name: 'conflict_count')
  final int conflictCount;

  final List<SyncConflictItem> conflicts;

  @JsonKey(name: 'server_time')
  final DateTime serverTime;

  const SyncResultResponse({
    required this.success,
    this.syncedCount = 0,
    this.conflictCount = 0,
    this.conflicts = const [],
    required this.serverTime,
  });

  factory SyncResultResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResultResponseToJson(this);
}

/// 同步冲突项
@JsonSerializable()
class SyncConflictItem {
  final String id;

  @JsonKey(name: 'data_type')
  final String dataType;

  @JsonKey(name: 'local_data')
  final Map<String, dynamic> localData;

  @JsonKey(name: 'server_data')
  final Map<String, dynamic> serverData;

  @JsonKey(name: 'local_modified_at')
  final DateTime localModifiedAt;

  @JsonKey(name: 'server_modified_at')
  final DateTime serverModifiedAt;

  const SyncConflictItem({
    required this.id,
    required this.dataType,
    required this.localData,
    required this.serverData,
    required this.localModifiedAt,
    required this.serverModifiedAt,
  });

  factory SyncConflictItem.fromJson(Map<String, dynamic> json) =>
      _$SyncConflictItemFromJson(json);

  Map<String, dynamic> toJson() => _$SyncConflictItemToJson(this);
}
