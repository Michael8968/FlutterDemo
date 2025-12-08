import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// 导出格式
enum ExportFormat {
  csv('CSV', 'csv'),
  json('JSON', 'json');

  final String displayName;
  final String extension;

  const ExportFormat(this.displayName, this.extension);
}

/// 导出数据类型
enum ExportDataType {
  diary('健康日记'),
  symptom('症状记录'),
  all('全部数据');

  final String displayName;

  const ExportDataType(this.displayName);
}

/// 导出结果
class ExportResult {
  final bool success;
  final String? filePath;
  final String? error;
  final int recordCount;

  const ExportResult({
    required this.success,
    this.filePath,
    this.error,
    this.recordCount = 0,
  });
}

/// 数据导出服务
class ExportService {
  /// 导出健康日记
  Future<ExportResult> exportDiaries({
    required List<DiaryEntry> diaries,
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 筛选日期范围
      var filteredDiaries = diaries;
      if (startDate != null) {
        filteredDiaries = filteredDiaries
            .where((d) => d.date.isAfter(startDate.subtract(const Duration(days: 1))))
            .toList();
      }
      if (endDate != null) {
        filteredDiaries = filteredDiaries
            .where((d) => d.date.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      }

      if (filteredDiaries.isEmpty) {
        return const ExportResult(
          success: false,
          error: '没有可导出的数据',
        );
      }

      String content;
      String fileName;

      switch (format) {
        case ExportFormat.csv:
          content = _diariesToCsv(filteredDiaries);
          fileName = 'health_diary_${_formatDateForFile(DateTime.now())}.csv';
          break;
        case ExportFormat.json:
          content = _diariesToJson(filteredDiaries);
          fileName = 'health_diary_${_formatDateForFile(DateTime.now())}.json';
          break;
      }

      final filePath = await _saveToFile(fileName, content);

      return ExportResult(
        success: true,
        filePath: filePath,
        recordCount: filteredDiaries.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: '导出失败: $e',
      );
    }
  }

  /// 导出症状记录
  Future<ExportResult> exportSymptoms({
    required List<SymptomEntry> symptoms,
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 筛选日期范围
      var filteredSymptoms = symptoms;
      if (startDate != null) {
        filteredSymptoms = filteredSymptoms
            .where((s) => s.timestamp.isAfter(startDate.subtract(const Duration(days: 1))))
            .toList();
      }
      if (endDate != null) {
        filteredSymptoms = filteredSymptoms
            .where((s) => s.timestamp.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      }

      if (filteredSymptoms.isEmpty) {
        return const ExportResult(
          success: false,
          error: '没有可导出的数据',
        );
      }

      String content;
      String fileName;

      switch (format) {
        case ExportFormat.csv:
          content = _symptomsToCsv(filteredSymptoms);
          fileName = 'symptoms_${_formatDateForFile(DateTime.now())}.csv';
          break;
        case ExportFormat.json:
          content = _symptomsToJson(filteredSymptoms);
          fileName = 'symptoms_${_formatDateForFile(DateTime.now())}.json';
          break;
      }

      final filePath = await _saveToFile(fileName, content);

      return ExportResult(
        success: true,
        filePath: filePath,
        recordCount: filteredSymptoms.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: '导出失败: $e',
      );
    }
  }

  /// 导出全部数据
  Future<ExportResult> exportAll({
    required List<DiaryEntry> diaries,
    required List<SymptomEntry> symptoms,
    UserProfile? profile,
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 筛选日期范围
      var filteredDiaries = diaries;
      var filteredSymptoms = symptoms;

      if (startDate != null) {
        filteredDiaries = filteredDiaries
            .where((d) => d.date.isAfter(startDate.subtract(const Duration(days: 1))))
            .toList();
        filteredSymptoms = filteredSymptoms
            .where((s) => s.timestamp.isAfter(startDate.subtract(const Duration(days: 1))))
            .toList();
      }
      if (endDate != null) {
        filteredDiaries = filteredDiaries
            .where((d) => d.date.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
        filteredSymptoms = filteredSymptoms
            .where((s) => s.timestamp.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      }

      if (filteredDiaries.isEmpty && filteredSymptoms.isEmpty) {
        return const ExportResult(
          success: false,
          error: '没有可导出的数据',
        );
      }

      String content;
      String fileName;

      switch (format) {
        case ExportFormat.csv:
          // CSV 格式导出为多个部分
          final buffer = StringBuffer();
          buffer.writeln('=== 健康日记 ===');
          buffer.writeln(_diariesToCsv(filteredDiaries));
          buffer.writeln();
          buffer.writeln('=== 症状记录 ===');
          buffer.writeln(_symptomsToCsv(filteredSymptoms));
          content = buffer.toString();
          fileName = 'health_data_${_formatDateForFile(DateTime.now())}.csv';
          break;
        case ExportFormat.json:
          content = _allDataToJson(
            diaries: filteredDiaries,
            symptoms: filteredSymptoms,
            profile: profile,
          );
          fileName = 'health_data_${_formatDateForFile(DateTime.now())}.json';
          break;
      }

      final filePath = await _saveToFile(fileName, content);

      return ExportResult(
        success: true,
        filePath: filePath,
        recordCount: filteredDiaries.length + filteredSymptoms.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: '导出失败: $e',
      );
    }
  }

  /// 将日记转换为 CSV
  String _diariesToCsv(List<DiaryEntry> diaries) {
    final buffer = StringBuffer();

    // 表头
    buffer.writeln(
      '日期,心情,睡眠时长(小时),睡眠质量,压力等级,精力等级,饮水量(杯),步数,体重(kg),活动,天气,备注',
    );

    // 数据行
    for (final diary in diaries) {
      buffer.writeln([
        _formatDate(diary.date),
        diary.mood.displayName,
        diary.sleepHours?.toString() ?? '',
        diary.sleepQuality?.displayName ?? '',
        diary.stressLevel?.toString() ?? '',
        diary.energyLevel?.toString() ?? '',
        diary.waterIntake?.toString() ?? '',
        diary.steps?.toString() ?? '',
        diary.weight?.toString() ?? '',
        diary.activities.map((a) => a.displayName).join(';'),
        diary.weather?.displayName ?? '',
        _escapeCsvField(diary.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// 将日记转换为 JSON
  String _diariesToJson(List<DiaryEntry> diaries) {
    final data = diaries.map((diary) => {
      'date': _formatDate(diary.date),
      'mood': diary.mood.displayName,
      'moodValue': diary.mood.value,
      'sleepHours': diary.sleepHours,
      'sleepQuality': diary.sleepQuality?.displayName,
      'stressLevel': diary.stressLevel,
      'energyLevel': diary.energyLevel,
      'waterIntake': diary.waterIntake,
      'steps': diary.steps,
      'weight': diary.weight,
      'activities': diary.activities.map((a) => a.displayName).toList(),
      'weather': diary.weather?.displayName,
      'notes': diary.notes,
      'gratitudes': diary.gratitudes,
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'exportType': 'health_diary',
      'exportDate': DateTime.now().toIso8601String(),
      'recordCount': diaries.length,
      'data': data,
    });
  }

  /// 将症状转换为 CSV
  String _symptomsToCsv(List<SymptomEntry> symptoms) {
    final buffer = StringBuffer();

    // 表头
    buffer.writeln(
      '时间,症状名称,类型,严重程度(1-10),部位,持续时间(分钟),触发因素,备注',
    );

    // 数据行
    for (final symptom in symptoms) {
      buffer.writeln([
        _formatDateTime(symptom.timestamp),
        symptom.symptomName,
        symptom.type.displayName,
        symptom.severity.toString(),
        symptom.bodyParts.join(';'),
        symptom.durationMinutes?.toString() ?? '',
        symptom.triggers.join(';'),
        _escapeCsvField(symptom.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// 将症状转换为 JSON
  String _symptomsToJson(List<SymptomEntry> symptoms) {
    final data = symptoms.map((symptom) => {
      'timestamp': symptom.timestamp.toIso8601String(),
      'symptomName': symptom.symptomName,
      'type': symptom.type.displayName,
      'severity': symptom.severity,
      'bodyParts': symptom.bodyParts,
      'durationMinutes': symptom.durationMinutes,
      'triggers': symptom.triggers,
      'notes': symptom.notes,
      'isOngoing': symptom.isOngoing,
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'exportType': 'symptoms',
      'exportDate': DateTime.now().toIso8601String(),
      'recordCount': symptoms.length,
      'data': data,
    });
  }

  /// 将全部数据转换为 JSON
  String _allDataToJson({
    required List<DiaryEntry> diaries,
    required List<SymptomEntry> symptoms,
    UserProfile? profile,
  }) {
    final diaryData = diaries.map((diary) => {
      'date': _formatDate(diary.date),
      'mood': diary.mood.displayName,
      'moodValue': diary.mood.value,
      'sleepHours': diary.sleepHours,
      'sleepQuality': diary.sleepQuality?.displayName,
      'stressLevel': diary.stressLevel,
      'energyLevel': diary.energyLevel,
      'waterIntake': diary.waterIntake,
      'steps': diary.steps,
      'weight': diary.weight,
      'activities': diary.activities.map((a) => a.displayName).toList(),
      'weather': diary.weather?.displayName,
      'notes': diary.notes,
    }).toList();

    final symptomData = symptoms.map((symptom) => {
      'timestamp': symptom.timestamp.toIso8601String(),
      'symptomName': symptom.symptomName,
      'type': symptom.type.displayName,
      'severity': symptom.severity,
      'bodyParts': symptom.bodyParts,
      'durationMinutes': symptom.durationMinutes,
      'triggers': symptom.triggers,
      'notes': symptom.notes,
    }).toList();

    Map<String, dynamic>? profileData;
    if (profile != null) {
      profileData = {
        'nickname': profile.nickname,
        'gender': profile.gender?.displayName,
        'birthday': profile.birthday?.toIso8601String(),
        'height': profile.height,
        'weight': profile.weight,
        'bloodType': profile.bloodType?.displayName,
        'allergies': profile.allergies,
        'chronicDiseases': profile.chronicDiseases,
        'medications': profile.medications,
      };
    }

    return const JsonEncoder.withIndent('  ').convert({
      'exportType': 'all_health_data',
      'exportDate': DateTime.now().toIso8601String(),
      'profile': profileData,
      'diaries': {
        'recordCount': diaries.length,
        'data': diaryData,
      },
      'symptoms': {
        'recordCount': symptoms.length,
        'data': symptomData,
      },
    });
  }

  /// 保存文件
  Future<String> _saveToFile(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File('${exportDir.path}/$fileName');
    await file.writeAsString(content, encoding: utf8);

    return file.path;
  }

  /// 获取导出目录中的所有文件
  Future<List<FileSystemEntity>> getExportedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      return [];
    }

    return exportDir.listSync()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  }

  /// 删除导出文件
  Future<bool> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化文件名日期
  String _formatDateForFile(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
  }

  /// 转义 CSV 字段
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
