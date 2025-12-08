import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/symptom_entry_model.dart';

/// 症状本地数据源接口
abstract class SymptomLocalDataSource {
  Future<SymptomEntryModel> addSymptom(SymptomEntryModel entry);
  Future<SymptomEntryModel> updateSymptom(SymptomEntryModel entry);
  Future<void> deleteSymptom(String id);
  Future<SymptomEntryModel?> getSymptomById(String id);
  Future<List<SymptomEntryModel>> getSymptomsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<SymptomEntryModel>> getAllSymptoms({int page = 1, int pageSize = 20});
  Future<List<SymptomEntryModel>> getRecentSymptoms({int limit = 10});
  Future<List<SymptomEntryModel>> searchSymptoms(String query);
}

/// 症状本地数据源 Hive 实现
class SymptomLocalDataSourceImpl implements SymptomLocalDataSource {
  static const String boxName = 'symptoms';

  Box<SymptomEntryModel>? _box;

  Future<Box<SymptomEntryModel>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<SymptomEntryModel>(boxName);
    return _box!;
  }

  @override
  Future<SymptomEntryModel> addSymptom(SymptomEntryModel entry) async {
    try {
      final symptomsBox = await box;
      await symptomsBox.put(entry.id, entry);
      return entry;
    } catch (e) {
      throw CacheException('Failed to add symptom: $e');
    }
  }

  @override
  Future<SymptomEntryModel> updateSymptom(SymptomEntryModel entry) async {
    try {
      final symptomsBox = await box;
      if (!symptomsBox.containsKey(entry.id)) {
        throw CacheException('Symptom not found: ${entry.id}');
      }
      await symptomsBox.put(entry.id, entry);
      return entry;
    } catch (e) {
      throw CacheException('Failed to update symptom: $e');
    }
  }

  @override
  Future<void> deleteSymptom(String id) async {
    try {
      final symptomsBox = await box;
      await symptomsBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete symptom: $e');
    }
  }

  @override
  Future<SymptomEntryModel?> getSymptomById(String id) async {
    try {
      final symptomsBox = await box;
      return symptomsBox.get(id);
    } catch (e) {
      throw CacheException('Failed to get symptom: $e');
    }
  }

  @override
  Future<List<SymptomEntryModel>> getSymptomsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final symptomsBox = await box;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final results = symptomsBox.values.where((entry) {
        return entry.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
            entry.timestamp.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();

      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    } catch (e) {
      throw CacheException('Failed to get symptoms by date range: $e');
    }
  }

  @override
  Future<List<SymptomEntryModel>> getAllSymptoms({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final symptomsBox = await box;
      final allSymptoms = symptomsBox.values.toList();
      allSymptoms.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final startIndex = (page - 1) * pageSize;
      if (startIndex >= allSymptoms.length) {
        return [];
      }

      final endIndex = startIndex + pageSize;
      return allSymptoms.sublist(
        startIndex,
        endIndex > allSymptoms.length ? allSymptoms.length : endIndex,
      );
    } catch (e) {
      throw CacheException('Failed to get all symptoms: $e');
    }
  }

  @override
  Future<List<SymptomEntryModel>> getRecentSymptoms({int limit = 10}) async {
    try {
      final symptomsBox = await box;
      final allSymptoms = symptomsBox.values.toList();
      allSymptoms.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allSymptoms.take(limit).toList();
    } catch (e) {
      throw CacheException('Failed to get recent symptoms: $e');
    }
  }

  @override
  Future<List<SymptomEntryModel>> searchSymptoms(String query) async {
    try {
      final symptomsBox = await box;
      final lowerQuery = query.toLowerCase();
      final results = symptomsBox.values.where((entry) {
        return entry.symptomName.toLowerCase().contains(lowerQuery) ||
            (entry.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
            entry.triggers.any((t) => t.toLowerCase().contains(lowerQuery));
      }).toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    } catch (e) {
      throw CacheException('Failed to search symptoms: $e');
    }
  }
}
