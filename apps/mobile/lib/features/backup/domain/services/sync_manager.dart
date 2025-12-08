import '../../../../core/network/models/sync_response.dart';
import '../../../health_diary/data/datasources/diary_local_datasource.dart';
import '../../../health_diary/data/models/diary_entry_model.dart';
import '../../../symptom_tracker/data/datasources/symptom_local_datasource.dart';
import '../../../profile/data/datasources/profile_local_datasource.dart';
import '../../data/services/api_cloud_sync_service.dart';
import '../entities/backup_data.dart';

/// 冲突解决策略
enum ConflictResolution {
  serverWins,  // 服务器数据优先
  localWins,   // 本地数据优先
  keepBoth,    // 保留两者
  manual,      // 手动选择
}

/// 同步结果
class SyncResult {
  final bool success;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictCount;
  final List<SyncConflict> conflicts;
  final String? error;
  final DateTime? syncTime;

  const SyncResult({
    required this.success,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictCount = 0,
    this.conflicts = const [],
    this.error,
    this.syncTime,
  });

  factory SyncResult.success({
    int uploaded = 0,
    int downloaded = 0,
    DateTime? syncTime,
  }) {
    return SyncResult(
      success: true,
      uploadedCount: uploaded,
      downloadedCount: downloaded,
      syncTime: syncTime ?? DateTime.now(),
    );
  }

  factory SyncResult.withConflicts(List<SyncConflict> conflicts) {
    return SyncResult(
      success: true,
      conflictCount: conflicts.length,
      conflicts: conflicts,
    );
  }

  factory SyncResult.failure(String error) {
    return SyncResult(success: false, error: error);
  }
}

/// 同步冲突
class SyncConflict {
  final String id;
  final String dataType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final DateTime localModifiedAt;
  final DateTime serverModifiedAt;
  ConflictResolution? resolution;

  SyncConflict({
    required this.id,
    required this.dataType,
    required this.localData,
    required this.serverData,
    required this.localModifiedAt,
    required this.serverModifiedAt,
    this.resolution,
  });

  factory SyncConflict.fromResponse(SyncConflictItem item) {
    return SyncConflict(
      id: item.id,
      dataType: item.dataType,
      localData: item.localData,
      serverData: item.serverData,
      localModifiedAt: item.localModifiedAt,
      serverModifiedAt: item.serverModifiedAt,
    );
  }
}

/// 数据变更记录
class DataChange {
  final String id;
  final String dataType;
  final ChangeType changeType;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const DataChange({
    required this.id,
    required this.dataType,
    required this.changeType,
    required this.data,
    required this.timestamp,
  });
}

enum ChangeType { create, update, delete }

/// 同步管理器
/// 负责协调本地数据和云端数据的同步
class SyncManager {
  final ApiCloudSyncService _cloudService;
  final DiaryLocalDataSource _diaryDataSource;
  final SymptomLocalDataSource _symptomDataSource;
  final ProfileLocalDataSource _profileDataSource;

  // 默认冲突解决策略
  ConflictResolution defaultResolution = ConflictResolution.serverWins;

  // 待处理的变更队列
  final List<DataChange> _pendingChanges = [];

  SyncManager({
    required ApiCloudSyncService cloudService,
    required DiaryLocalDataSource diaryDataSource,
    required SymptomLocalDataSource symptomDataSource,
    required ProfileLocalDataSource profileDataSource,
  })  : _cloudService = cloudService,
        _diaryDataSource = diaryDataSource,
        _symptomDataSource = symptomDataSource,
        _profileDataSource = profileDataSource;

  /// 执行完整同步
  Future<SyncResult> performSync() async {
    if (!_cloudService.isLoggedIn) {
      return SyncResult.failure('请先登录');
    }

    try {
      // 1. 收集本地变更
      final localChanges = await _collectLocalChanges();

      // 2. 上传本地变更并获取服务器变更
      final syncResult = await _cloudService.syncData(localChanges);

      if (!syncResult.success) {
        return SyncResult.failure(syncResult.error ?? '同步失败');
      }

      // 3. 处理服务器响应
      if (syncResult.data is SyncResultResponse) {
        final response = syncResult.data as SyncResultResponse;

        // 检查是否有冲突
        if (response.conflictCount > 0) {
          final conflicts = response.conflicts
              .map((c) => SyncConflict.fromResponse(c))
              .toList();

          // 自动解决冲突（根据默认策略）
          await _resolveConflictsAutomatically(conflicts);
        }

        // 4. 获取并应用服务器变更
        final changesResult = await _cloudService.getServerChanges();
        if (changesResult.success && changesResult.data != null) {
          await _applyServerChanges(changesResult.data!);
        }

        return SyncResult.success(
          uploaded: response.syncedCount,
          downloaded: changesResult.data?.totalChanges ?? 0,
          syncTime: response.serverTime,
        );
      }

      return SyncResult.success();
    } catch (e) {
      return SyncResult.failure('同步失败: $e');
    }
  }

  /// 收集本地变更
  Future<BackupContent> _collectLocalChanges() async {
    // 获取所有日记（分页获取全部）
    final diariesResult = await _diaryDataSource.getAllDiariesPaginated(
      page: 1,
      pageSize: 10000,
    );
    final symptoms = await _symptomDataSource.getAllSymptoms();
    final profile = await _profileDataSource.getProfile();

    return BackupContent(
      diaries: diariesResult.items.map((d) => _diaryToJson(d)).toList(),
      symptoms: symptoms.map((s) => s.toJson()).toList(),
      profile: profile != null ? _profileToJson(profile) : null,
    );
  }

  /// 将 DiaryEntryModel 转换为 JSON
  Map<String, dynamic> _diaryToJson(DiaryEntryModel diary) {
    return {
      'id': diary.id,
      'date': diary.date.toIso8601String(),
      'moodValue': diary.moodValue,
      'sleepHours': diary.sleepHours,
      'sleepQualityValue': diary.sleepQualityValue,
      'bedTime': diary.bedTime?.toIso8601String(),
      'wakeTime': diary.wakeTime?.toIso8601String(),
      'stressLevel': diary.stressLevel,
      'energyLevel': diary.energyLevel,
      'waterIntake': diary.waterIntake,
      'steps': diary.steps,
      'weight': diary.weight,
      'activityIndices': diary.activityIndices,
      'weatherIndex': diary.weatherIndex,
      'notes': diary.notes,
      'gratitudes': diary.gratitudes,
      'goals': diary.goals.map((g) => {
        'title': g.title,
        'completed': g.completed,
        'note': g.note,
      }).toList(),
      'symptomIds': diary.symptomIds,
      'photoPaths': diary.photoPaths,
      'createdAt': diary.createdAt.toIso8601String(),
      'updatedAt': diary.updatedAt?.toIso8601String(),
    };
  }

  /// 将 UserProfileModel 转换为 JSON
  Map<String, dynamic> _profileToJson(dynamic profile) {
    return {
      'id': profile.id,
      'nickname': profile.nickname,
      'avatarUrl': profile.avatarUrl,
      'genderIndex': profile.genderIndex,
      'birthday': profile.birthday?.toIso8601String(),
      'height': profile.height,
      'weight': profile.weight,
      'bloodTypeIndex': profile.bloodTypeIndex,
      'allergies': List<String>.from(profile.allergies ?? []),
      'chronicDiseases': List<String>.from(profile.chronicDiseases ?? []),
      'medications': List<String>.from(profile.medications ?? []),
      'emergencyContact': profile.emergencyContact,
      'emergencyPhone': profile.emergencyPhone,
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
  }

  /// 自动解决冲突
  Future<void> _resolveConflictsAutomatically(List<SyncConflict> conflicts) async {
    for (final conflict in conflicts) {
      await resolveConflict(conflict, defaultResolution);
    }
  }

  /// 解决单个冲突
  Future<void> resolveConflict(
    SyncConflict conflict,
    ConflictResolution resolution,
  ) async {
    conflict.resolution = resolution;

    switch (resolution) {
      case ConflictResolution.serverWins:
        // 使用服务器数据覆盖本地
        await _applyData(conflict.dataType, conflict.serverData);
        break;

      case ConflictResolution.localWins:
        // 保留本地数据，将在下次同步时上传
        _queueChange(DataChange(
          id: conflict.id,
          dataType: conflict.dataType,
          changeType: ChangeType.update,
          data: conflict.localData,
          timestamp: DateTime.now(),
        ));
        break;

      case ConflictResolution.keepBoth:
        // 保留两者，为本地数据创建新 ID
        final newLocalData = Map<String, dynamic>.from(conflict.localData);
        newLocalData['id'] = '${conflict.id}_local_${DateTime.now().millisecondsSinceEpoch}';
        await _applyData(conflict.dataType, conflict.serverData);
        await _applyData(conflict.dataType, newLocalData);
        break;

      case ConflictResolution.manual:
        // 不自动处理，等待用户选择
        break;
    }
  }

  /// 应用服务器变更到本地
  Future<void> _applyServerChanges(SyncChangesResponse changes) async {
    // 应用日记变更
    for (final diaryJson in changes.diaries) {
      await _applyData('diary', diaryJson);
    }

    // 应用症状变更
    for (final symptomJson in changes.symptoms) {
      await _applyData('symptom', symptomJson);
    }

    // 应用档案变更
    if (changes.profile != null) {
      await _applyData('profile', changes.profile!);
    }
  }

  /// 应用单条数据到本地存储
  Future<void> _applyData(String dataType, Map<String, dynamic> data) async {
    switch (dataType) {
      case 'diary':
        // 将 JSON 转换为模型并保存
        // 这里需要根据实际的 DataSource 接口来实现
        break;

      case 'symptom':
        // 将 JSON 转换为模型并保存
        break;

      case 'profile':
        // 将 JSON 转换为模型并保存
        break;
    }
  }

  /// 添加变更到队列
  void _queueChange(DataChange change) {
    _pendingChanges.add(change);
  }

  /// 获取待处理变更数量
  int get pendingChangesCount => _pendingChanges.length;

  /// 清空待处理变更
  void clearPendingChanges() {
    _pendingChanges.clear();
  }

  /// 检测冲突
  Future<List<SyncConflict>> detectConflicts(
    BackupContent localData,
    SyncChangesResponse serverData,
  ) async {
    final conflicts = <SyncConflict>[];

    // 检测日记冲突
    for (final serverDiary in serverData.diaries) {
      final serverId = serverDiary['id'] as String;
      final localDiary = localData.diaries.firstWhere(
        (d) => d['id'] == serverId,
        orElse: () => {},
      );

      if (localDiary.isNotEmpty) {
        final localModified = DateTime.parse(localDiary['updatedAt'] as String);
        final serverModified = DateTime.parse(serverDiary['updatedAt'] as String);

        // 如果本地和服务器都有修改，且修改时间不同，则为冲突
        if (localModified != serverModified) {
          conflicts.add(SyncConflict(
            id: serverId,
            dataType: 'diary',
            localData: localDiary,
            serverData: serverDiary,
            localModifiedAt: localModified,
            serverModifiedAt: serverModified,
          ));
        }
      }
    }

    // 类似地检测症状冲突...

    return conflicts;
  }
}
