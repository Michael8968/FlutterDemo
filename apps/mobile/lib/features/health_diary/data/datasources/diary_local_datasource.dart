import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/diary_entry_model.dart';

/// 分页结果
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  }) : hasMore = page * pageSize < totalCount;
}

/// 日记本地数据源接口
abstract class DiaryLocalDataSource {
  Future<DiaryEntryModel> saveDiary(DiaryEntryModel entry);
  Future<void> deleteDiary(String id);
  Future<DiaryEntryModel?> getDiaryById(String id);
  Future<DiaryEntryModel?> getDiaryByDate(DateTime date);
  Future<List<DiaryEntryModel>> getDiariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<DiaryEntryModel>> getRecentDiaries({int limit = 7});
  Future<List<DateTime>> getDatesWithDiary(DateTime month);
  Future<List<DiaryEntryModel>> searchDiaries(String query);

  /// 分页获取所有日记
  Future<PaginatedResult<DiaryEntryModel>> getAllDiariesPaginated({
    int page = 1,
    int pageSize = 20,
  });

  /// 按心情筛选日记（分页）
  Future<PaginatedResult<DiaryEntryModel>> getDiariesByMoodPaginated(
    int moodValue, {
    int page = 1,
    int pageSize = 20,
  });

  /// 获取日记总数
  Future<int> getDiaryCount();
}

/// 日记本地数据源 Hive 实现
class DiaryLocalDataSourceImpl implements DiaryLocalDataSource {
  static const String boxName = 'diaries';

  Box<DiaryEntryModel>? _box;

  Future<Box<DiaryEntryModel>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<DiaryEntryModel>(boxName);
    return _box!;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<DiaryEntryModel> saveDiary(DiaryEntryModel entry) async {
    try {
      final diaryBox = await box;
      final key = _dateKey(entry.date);
      await diaryBox.put(key, entry);
      return entry;
    } catch (e) {
      throw CacheException('Failed to save diary: $e');
    }
  }

  @override
  Future<void> deleteDiary(String id) async {
    try {
      final diaryBox = await box;
      final entry = diaryBox.values.firstWhere(
        (e) => e.id == id,
        orElse: () => throw CacheException('Diary not found'),
      );
      final key = _dateKey(entry.date);
      await diaryBox.delete(key);
    } catch (e) {
      throw CacheException('Failed to delete diary: $e');
    }
  }

  @override
  Future<DiaryEntryModel?> getDiaryById(String id) async {
    try {
      final diaryBox = await box;
      return diaryBox.values.firstWhere(
        (e) => e.id == id,
        orElse: () => throw CacheException('Diary not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DiaryEntryModel?> getDiaryByDate(DateTime date) async {
    try {
      final diaryBox = await box;
      final key = _dateKey(date);
      return diaryBox.get(key);
    } catch (e) {
      throw CacheException('Failed to get diary by date: $e');
    }
  }

  @override
  Future<List<DiaryEntryModel>> getDiariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final diaryBox = await box;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      final results = diaryBox.values.where((entry) {
        final entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        return !entryDate.isBefore(start) && !entryDate.isAfter(end);
      }).toList();

      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    } catch (e) {
      throw CacheException('Failed to get diaries by date range: $e');
    }
  }

  @override
  Future<List<DiaryEntryModel>> getRecentDiaries({int limit = 7}) async {
    try {
      final diaryBox = await box;
      final allDiaries = diaryBox.values.toList();
      allDiaries.sort((a, b) => b.date.compareTo(a.date));
      return allDiaries.take(limit).toList();
    } catch (e) {
      throw CacheException('Failed to get recent diaries: $e');
    }
  }

  @override
  Future<List<DateTime>> getDatesWithDiary(DateTime month) async {
    try {
      final diaryBox = await box;
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      return diaryBox.values
          .where((entry) {
            final entryDate = DateTime(
              entry.date.year,
              entry.date.month,
              entry.date.day,
            );
            return !entryDate.isBefore(firstDay) && !entryDate.isAfter(lastDay);
          })
          .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get dates with diary: $e');
    }
  }

  @override
  Future<List<DiaryEntryModel>> searchDiaries(String query) async {
    try {
      final diaryBox = await box;
      final lowerQuery = query.toLowerCase();
      final results = diaryBox.values.where((entry) {
        return (entry.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
            entry.gratitudes.any((g) => g.toLowerCase().contains(lowerQuery)) ||
            entry.goals.any((g) => g.title.toLowerCase().contains(lowerQuery));
      }).toList();
      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    } catch (e) {
      throw CacheException('Failed to search diaries: $e');
    }
  }

  @override
  Future<PaginatedResult<DiaryEntryModel>> getAllDiariesPaginated({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final diaryBox = await box;
      final allDiaries = diaryBox.values.toList();
      allDiaries.sort((a, b) => b.date.compareTo(a.date));

      final totalCount = allDiaries.length;
      final startIndex = (page - 1) * pageSize;

      if (startIndex >= totalCount) {
        return PaginatedResult(
          items: [],
          totalCount: totalCount,
          page: page,
          pageSize: pageSize,
        );
      }

      final endIndex = (startIndex + pageSize).clamp(0, totalCount);
      final items = allDiaries.sublist(startIndex, endIndex);

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw CacheException('Failed to get paginated diaries: $e');
    }
  }

  @override
  Future<PaginatedResult<DiaryEntryModel>> getDiariesByMoodPaginated(
    int moodValue, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final diaryBox = await box;
      final filteredDiaries = diaryBox.values
          .where((entry) => entry.moodValue == moodValue)
          .toList();
      filteredDiaries.sort((a, b) => b.date.compareTo(a.date));

      final totalCount = filteredDiaries.length;
      final startIndex = (page - 1) * pageSize;

      if (startIndex >= totalCount) {
        return PaginatedResult(
          items: [],
          totalCount: totalCount,
          page: page,
          pageSize: pageSize,
        );
      }

      final endIndex = (startIndex + pageSize).clamp(0, totalCount);
      final items = filteredDiaries.sublist(startIndex, endIndex);

      return PaginatedResult(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw CacheException('Failed to get diaries by mood: $e');
    }
  }

  @override
  Future<int> getDiaryCount() async {
    try {
      final diaryBox = await box;
      return diaryBox.length;
    } catch (e) {
      throw CacheException('Failed to get diary count: $e');
    }
  }
}
