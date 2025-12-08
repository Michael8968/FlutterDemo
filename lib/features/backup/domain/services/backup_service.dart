import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../entities/backup_data.dart';

/// 备份服务
class BackupService {
  static const String _backupVersion = '1.0.0';
  static const String _settingsKey = 'sync_settings';
  static const String _backupHistoryKey = 'backup_history';

  final SharedPreferences _prefs;

  BackupService(this._prefs);

  /// 获取备份目录
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// 创建完整备份
  Future<BackupResult> createBackup({
    BackupType type = BackupType.local,
    String? customName,
  }) async {
    try {
      // 收集所有数据
      final content = await _collectAllData();

      // 创建备份数据
      final backup = BackupData(
        version: _backupVersion,
        createdAt: DateTime.now(),
        deviceInfo: await _getDeviceInfo(),
        content: content,
      );

      // 生成文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = customName ?? 'backup_$timestamp.json';

      // 保存到文件
      final backupDir = await _getBackupDirectory();
      final file = File('${backupDir.path}/$fileName');
      final jsonStr = const JsonEncoder.withIndent('  ').convert(backup.toJson());
      await file.writeAsString(jsonStr, encoding: utf8);

      // 创建备份信息
      final info = BackupInfo(
        id: timestamp.toString(),
        fileName: fileName,
        createdAt: backup.createdAt,
        fileSize: await file.length(),
        type: type,
      );

      // 保存到历史记录
      await _addToBackupHistory(info);

      // 更新设置中的最后备份时间
      await _updateLastBackupTime();

      return BackupResult.success(filePath: file.path, info: info);
    } catch (e) {
      return BackupResult.failure('备份失败: $e');
    }
  }

  /// 收集所有数据
  Future<BackupContent> _collectAllData() async {
    // 获取所有SharedPreferences数据
    final keys = _prefs.getKeys();

    Map<String, dynamic>? profile;
    List<Map<String, dynamic>> diaries = [];
    List<Map<String, dynamic>> symptoms = [];
    List<Map<String, dynamic>> achievements = [];
    List<Map<String, dynamic>> reminders = [];
    Map<String, dynamic> settings = {};

    for (final key in keys) {
      final value = _prefs.get(key);

      if (key == 'user_profile' && value is String) {
        try {
          profile = jsonDecode(value) as Map<String, dynamic>;
        } catch (_) {}
      } else if (key == 'diary_entries' && value is String) {
        try {
          final list = jsonDecode(value) as List<dynamic>;
          diaries = list.map((e) => e as Map<String, dynamic>).toList();
        } catch (_) {}
      } else if (key == 'symptom_entries' && value is String) {
        try {
          final list = jsonDecode(value) as List<dynamic>;
          symptoms = list.map((e) => e as Map<String, dynamic>).toList();
        } catch (_) {}
      } else if (key == 'user_achievements' && value is String) {
        try {
          final list = jsonDecode(value) as List<dynamic>;
          achievements = list.map((e) => e as Map<String, dynamic>).toList();
        } catch (_) {}
      } else if (key == 'reminders' && value is String) {
        try {
          final list = jsonDecode(value) as List<dynamic>;
          reminders = list.map((e) => e as Map<String, dynamic>).toList();
        } catch (_) {}
      } else if (key.startsWith('settings_') || key.startsWith('pref_')) {
        settings[key] = value;
      }
    }

    return BackupContent(
      profile: profile,
      diaries: diaries,
      symptoms: symptoms,
      achievements: achievements,
      reminders: reminders,
      settings: settings.isNotEmpty ? settings : null,
    );
  }

  /// 从文件恢复
  Future<RestoreResult> restoreFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return RestoreResult.failure('备份文件不存在');
      }

      final jsonStr = await file.readAsString(encoding: utf8);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final backup = BackupData.fromJson(json);

      return await _restoreContent(backup.content);
    } catch (e) {
      return RestoreResult.failure('恢复失败: $e');
    }
  }

  /// 从JSON字符串恢复
  Future<RestoreResult> restoreFromJson(String jsonStr) async {
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final backup = BackupData.fromJson(json);
      return await _restoreContent(backup.content);
    } catch (e) {
      return RestoreResult.failure('恢复失败: $e');
    }
  }

  /// 恢复内容
  Future<RestoreResult> _restoreContent(BackupContent content) async {
    try {
      int diaries = 0, symptoms = 0, achievements = 0, reminders = 0;
      bool profile = false;

      // 恢复个人资料
      if (content.profile != null) {
        await _prefs.setString('user_profile', jsonEncode(content.profile));
        profile = true;
      }

      // 恢复日记
      if (content.diaries.isNotEmpty) {
        await _prefs.setString('diary_entries', jsonEncode(content.diaries));
        diaries = content.diaries.length;
      }

      // 恢复症状
      if (content.symptoms.isNotEmpty) {
        await _prefs.setString('symptom_entries', jsonEncode(content.symptoms));
        symptoms = content.symptoms.length;
      }

      // 恢复成就
      if (content.achievements.isNotEmpty) {
        await _prefs.setString('user_achievements', jsonEncode(content.achievements));
        achievements = content.achievements.length;
      }

      // 恢复提醒
      if (content.reminders.isNotEmpty) {
        await _prefs.setString('reminders', jsonEncode(content.reminders));
        reminders = content.reminders.length;
      }

      // 恢复设置
      if (content.settings != null) {
        for (final entry in content.settings!.entries) {
          final value = entry.value;
          if (value is String) {
            await _prefs.setString(entry.key, value);
          } else if (value is int) {
            await _prefs.setInt(entry.key, value);
          } else if (value is double) {
            await _prefs.setDouble(entry.key, value);
          } else if (value is bool) {
            await _prefs.setBool(entry.key, value);
          } else if (value is List<String>) {
            await _prefs.setStringList(entry.key, value);
          }
        }
      }

      return RestoreResult.success(
        diaries: diaries,
        symptoms: symptoms,
        achievements: achievements,
        reminders: reminders,
        profile: profile,
      );
    } catch (e) {
      return RestoreResult.failure('恢复数据失败: $e');
    }
  }

  /// 获取设备信息
  Future<String> _getDeviceInfo() async {
    return 'Flutter App ${DateTime.now().toIso8601String()}';
  }

  /// 获取所有本地备份
  Future<List<BackupInfo>> getLocalBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      final files = await backupDir
          .list()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      final backups = <BackupInfo>[];

      for (final file in files) {
        if (file is File) {
          try {
            final stat = await file.stat();
            final name = file.path.split('/').last;

            backups.add(BackupInfo(
              id: stat.modified.millisecondsSinceEpoch.toString(),
              fileName: name,
              createdAt: stat.modified,
              fileSize: stat.size,
              type: name.startsWith('auto_') ? BackupType.auto : BackupType.local,
            ));
          } catch (_) {}
        }
      }

      // 按时间倒序排列
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return backups;
    } catch (e) {
      return [];
    }
  }

  /// 删除备份
  Future<bool> deleteBackup(String fileName) async {
    try {
      final backupDir = await _getBackupDirectory();
      final file = File('${backupDir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 分享备份文件
  Future<void> shareBackup(String fileName) async {
    try {
      final backupDir = await _getBackupDirectory();
      final file = File('${backupDir.path}/$fileName');
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: '健康数据备份',
        );
      }
    } catch (_) {}
  }

  /// 导出备份到指定位置
  Future<String?> exportBackup(String fileName) async {
    try {
      final backupDir = await _getBackupDirectory();
      final file = File('${backupDir.path}/$fileName');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取同步设置
  SyncSettings getSyncSettings() {
    final json = _prefs.getString(_settingsKey);
    if (json != null) {
      try {
        return SyncSettings.fromJson(jsonDecode(json));
      } catch (_) {}
    }
    return const SyncSettings();
  }

  /// 保存同步设置
  Future<void> saveSyncSettings(SyncSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// 更新最后备份时间
  Future<void> _updateLastBackupTime() async {
    final settings = getSyncSettings();
    await saveSyncSettings(
      settings.copyWith(lastBackupTime: DateTime.now()),
    );
  }

  /// 添加到备份历史
  Future<void> _addToBackupHistory(BackupInfo info) async {
    final historyJson = _prefs.getString(_backupHistoryKey);
    List<Map<String, dynamic>> history = [];

    if (historyJson != null) {
      try {
        history = (jsonDecode(historyJson) as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      } catch (_) {}
    }

    history.insert(0, {
      'id': info.id,
      'fileName': info.fileName,
      'createdAt': info.createdAt.toIso8601String(),
      'fileSize': info.fileSize,
      'type': info.type.name,
    });

    // 只保留最近50条记录
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    await _prefs.setString(_backupHistoryKey, jsonEncode(history));
  }

  /// 检查是否需要自动备份
  Future<bool> shouldAutoBackup() async {
    final settings = getSyncSettings();
    if (!settings.autoBackupEnabled) return false;

    final lastBackup = settings.lastBackupTime;
    if (lastBackup == null) return true;

    final daysSinceLastBackup = DateTime.now().difference(lastBackup).inDays;
    return daysSinceLastBackup >= settings.autoBackupIntervalDays;
  }

  /// 执行自动备份
  Future<BackupResult> performAutoBackup() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return createBackup(
      type: BackupType.auto,
      customName: 'auto_backup_$timestamp.json',
    );
  }

  /// 获取备份统计信息
  Future<Map<String, dynamic>> getBackupStats() async {
    final backups = await getLocalBackups();
    final settings = getSyncSettings();

    int totalSize = 0;
    for (final backup in backups) {
      totalSize += backup.fileSize;
    }

    return {
      'totalBackups': backups.length,
      'totalSize': totalSize,
      'lastBackup': settings.lastBackupTime,
      'autoBackupEnabled': settings.autoBackupEnabled,
    };
  }
}
