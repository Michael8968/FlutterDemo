/// 备份数据模型
class BackupData {
  final String version;
  final DateTime createdAt;
  final String deviceInfo;
  final BackupContent content;

  const BackupData({
    required this.version,
    required this.createdAt,
    required this.deviceInfo,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'deviceInfo': deviceInfo,
      'content': content.toJson(),
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deviceInfo: json['deviceInfo'] as String,
      content: BackupContent.fromJson(json['content'] as Map<String, dynamic>),
    );
  }
}

/// 备份内容
class BackupContent {
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> diaries;
  final List<Map<String, dynamic>> symptoms;
  final List<Map<String, dynamic>> achievements;
  final List<Map<String, dynamic>> reminders;
  final Map<String, dynamic>? settings;

  const BackupContent({
    this.profile,
    this.diaries = const [],
    this.symptoms = const [],
    this.achievements = const [],
    this.reminders = const [],
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'profile': profile,
      'diaries': diaries,
      'symptoms': symptoms,
      'achievements': achievements,
      'reminders': reminders,
      'settings': settings,
    };
  }

  factory BackupContent.fromJson(Map<String, dynamic> json) {
    return BackupContent(
      profile: json['profile'] as Map<String, dynamic>?,
      diaries: (json['diaries'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  int get totalRecords =>
      diaries.length + symptoms.length + achievements.length + reminders.length;
}

/// 备份信息（不含内容，用于列表展示）
class BackupInfo {
  final String id;
  final String fileName;
  final DateTime createdAt;
  final int fileSize;
  final BackupType type;
  final String? cloudId;

  const BackupInfo({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
    required this.type,
    this.cloudId,
  });

  String get fileSizeDisplay {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get dateDisplay {
    return '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')} '
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

/// 备份类型
enum BackupType {
  local('本地备份'),
  cloud('云端备份'),
  auto('自动备份');

  final String displayName;

  const BackupType(this.displayName);
}

/// 备份结果
class BackupResult {
  final bool success;
  final String? filePath;
  final String? error;
  final BackupInfo? info;

  const BackupResult({
    required this.success,
    this.filePath,
    this.error,
    this.info,
  });

  factory BackupResult.success({
    required String filePath,
    required BackupInfo info,
  }) {
    return BackupResult(
      success: true,
      filePath: filePath,
      info: info,
    );
  }

  factory BackupResult.failure(String error) {
    return BackupResult(
      success: false,
      error: error,
    );
  }
}

/// 恢复结果
class RestoreResult {
  final bool success;
  final String? error;
  final int diariesRestored;
  final int symptomsRestored;
  final int achievementsRestored;
  final int remindersRestored;
  final bool profileRestored;

  const RestoreResult({
    required this.success,
    this.error,
    this.diariesRestored = 0,
    this.symptomsRestored = 0,
    this.achievementsRestored = 0,
    this.remindersRestored = 0,
    this.profileRestored = false,
  });

  int get totalRestored =>
      diariesRestored + symptomsRestored + achievementsRestored + remindersRestored;

  factory RestoreResult.success({
    required int diaries,
    required int symptoms,
    required int achievements,
    required int reminders,
    required bool profile,
  }) {
    return RestoreResult(
      success: true,
      diariesRestored: diaries,
      symptomsRestored: symptoms,
      achievementsRestored: achievements,
      remindersRestored: reminders,
      profileRestored: profile,
    );
  }

  factory RestoreResult.failure(String error) {
    return RestoreResult(
      success: false,
      error: error,
    );
  }
}

/// 同步状态
enum SyncStatus {
  idle('空闲'),
  syncing('同步中'),
  success('同步成功'),
  failed('同步失败'),
  conflict('存在冲突');

  final String displayName;

  const SyncStatus(this.displayName);
}

/// 同步配置
class SyncSettings {
  final bool autoBackupEnabled;
  final int autoBackupIntervalDays;
  final bool wifiOnly;
  final bool includePhotos;
  final DateTime? lastBackupTime;
  final DateTime? lastSyncTime;

  const SyncSettings({
    this.autoBackupEnabled = false,
    this.autoBackupIntervalDays = 7,
    this.wifiOnly = true,
    this.includePhotos = false,
    this.lastBackupTime,
    this.lastSyncTime,
  });

  SyncSettings copyWith({
    bool? autoBackupEnabled,
    int? autoBackupIntervalDays,
    bool? wifiOnly,
    bool? includePhotos,
    DateTime? lastBackupTime,
    DateTime? lastSyncTime,
  }) {
    return SyncSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupIntervalDays: autoBackupIntervalDays ?? this.autoBackupIntervalDays,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      includePhotos: includePhotos ?? this.includePhotos,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoBackupEnabled': autoBackupEnabled,
      'autoBackupIntervalDays': autoBackupIntervalDays,
      'wifiOnly': wifiOnly,
      'includePhotos': includePhotos,
      'lastBackupTime': lastBackupTime?.toIso8601String(),
      'lastSyncTime': lastSyncTime?.toIso8601String(),
    };
  }

  factory SyncSettings.fromJson(Map<String, dynamic> json) {
    return SyncSettings(
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? false,
      autoBackupIntervalDays: json['autoBackupIntervalDays'] as int? ?? 7,
      wifiOnly: json['wifiOnly'] as bool? ?? true,
      includePhotos: json['includePhotos'] as bool? ?? false,
      lastBackupTime: json['lastBackupTime'] != null
          ? DateTime.parse(json['lastBackupTime'] as String)
          : null,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
    );
  }
}
