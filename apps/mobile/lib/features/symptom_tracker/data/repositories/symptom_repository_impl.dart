import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/symptom_entry.dart';
import '../../domain/entities/symptom_category.dart';
import '../../domain/repositories/symptom_repository.dart';
import '../datasources/symptom_local_datasource.dart';
import '../models/symptom_entry_model.dart';

/// 症状仓库实现
class SymptomRepositoryImpl implements SymptomRepository {
  final SymptomLocalDataSource localDataSource;

  SymptomRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, SymptomEntry>> addSymptom(SymptomEntry entry) async {
    try {
      final model = SymptomEntryModel.fromEntity(entry);
      final result = await localDataSource.addSymptom(model);
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SymptomEntry>> updateSymptom(SymptomEntry entry) async {
    try {
      final model = SymptomEntryModel.fromEntity(entry);
      final result = await localDataSource.updateSymptom(model);
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSymptom(String id) async {
    try {
      await localDataSource.deleteSymptom(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SymptomEntry>> getSymptomById(String id) async {
    try {
      final result = await localDataSource.getSymptomById(id);
      if (result == null) {
        return const Left(CacheFailure('Symptom not found'));
      }
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SymptomEntry>>> getSymptomsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final results = await localDataSource.getSymptomsByDateRange(startDate, endDate);
      return Right(results.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SymptomEntry>>> getSymptomsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getSymptomsByDateRange(startOfDay, endOfDay);
  }

  @override
  Future<Either<Failure, List<SymptomEntry>>> getAllSymptoms({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final results = await localDataSource.getAllSymptoms(
        page: page,
        pageSize: pageSize,
      );
      return Right(results.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SymptomEntry>>> getSymptomsByType(
    SymptomType type, {
    int? limit,
  }) async {
    try {
      final allResults = await localDataSource.getAllSymptoms(
        page: 1,
        pageSize: 1000,
      );
      var filtered = allResults
          .where((m) => m.typeIndex == type.index)
          .map((m) => m.toEntity())
          .toList();
      if (limit != null && filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }
      return Right(filtered);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SymptomEntry>>> searchSymptoms(String query) async {
    try {
      final results = await localDataSource.searchSymptoms(query);
      return Right(results.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SymptomAnalysis>> getSymptomAnalysis(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final results = await localDataSource.getSymptomsByDateRange(startDate, endDate);
      final entries = results.map((m) => m.toEntity()).toList();

      // 按症状类型统计
      final countByType = <SymptomType, int>{};
      for (final entry in entries) {
        countByType[entry.type] = (countByType[entry.type] ?? 0) + 1;
      }

      // 按症状名称分组统计
      final byName = <String, List<SymptomEntry>>{};
      for (final entry in entries) {
        byName.putIfAbsent(entry.symptomName, () => []).add(entry);
      }

      final summaries = byName.entries.map((e) {
        final list = e.value;
        final avgSeverity = list.map((s) => s.severity).reduce((a, b) => a + b) / list.length;

        // 统计常见诱因
        final triggerCounts = <String, int>{};
        for (final entry in list) {
          for (final trigger in entry.triggers) {
            triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
          }
        }
        final sortedTriggers = triggerCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // 统计常见部位
        final partCounts = <String, int>{};
        for (final entry in list) {
          for (final part in entry.bodyParts) {
            partCounts[part] = (partCounts[part] ?? 0) + 1;
          }
        }
        final sortedParts = partCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SymptomSummary(
          symptomName: e.key,
          count: list.length,
          averageSeverity: avgSeverity,
          lastOccurrence: list.map((s) => s.timestamp).reduce(
                (a, b) => a.isAfter(b) ? a : b,
              ),
          commonTriggers: sortedTriggers.take(3).map((e) => e.key).toList(),
          commonBodyParts: sortedParts.take(3).map((e) => e.key).toList(),
        );
      }).toList();

      summaries.sort((a, b) => b.count.compareTo(a.count));

      // 获取最常见的症状和诱因
      final topSymptoms = summaries.take(5).map((s) => s.symptomName).toList();

      final allTriggers = <String, int>{};
      for (final entry in entries) {
        for (final trigger in entry.triggers) {
          allTriggers[trigger] = (allTriggers[trigger] ?? 0) + 1;
        }
      }
      final sortedAllTriggers = allTriggers.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topTriggers = sortedAllTriggers.take(5).map((e) => e.key).toList();

      return Right(SymptomAnalysis(
        startDate: startDate,
        endDate: endDate,
        totalEntries: entries.length,
        countByType: countByType,
        summaries: summaries,
        topSymptoms: topSymptoms,
        topTriggers: topTriggers,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SymptomEntry>>> getRecentSymptoms({
    int limit = 10,
  }) async {
    try {
      final results = await localDataSource.getRecentSymptoms(limit: limit);
      return Right(results.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SymptomEntry>> markSymptomEnded(
    String id,
    int durationMinutes,
  ) async {
    try {
      final existing = await localDataSource.getSymptomById(id);
      if (existing == null) {
        return const Left(CacheFailure('Symptom not found'));
      }

      final updated = SymptomEntryModel(
        id: existing.id,
        timestamp: existing.timestamp,
        symptomName: existing.symptomName,
        templateId: existing.templateId,
        typeIndex: existing.typeIndex,
        severity: existing.severity,
        bodyParts: existing.bodyParts,
        durationMinutes: durationMinutes,
        triggers: existing.triggers,
        notes: existing.notes,
        isOngoing: false,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await localDataSource.updateSymptom(updated);
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
