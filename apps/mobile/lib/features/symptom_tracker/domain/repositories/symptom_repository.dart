import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/symptom_entry.dart';
import '../entities/symptom_category.dart';

/// 症状仓库接口
abstract class SymptomRepository {
  /// 添加症状记录
  Future<Either<Failure, SymptomEntry>> addSymptom(SymptomEntry entry);

  /// 更新症状记录
  Future<Either<Failure, SymptomEntry>> updateSymptom(SymptomEntry entry);

  /// 删除症状记录
  Future<Either<Failure, void>> deleteSymptom(String id);

  /// 根据ID获取症状记录
  Future<Either<Failure, SymptomEntry>> getSymptomById(String id);

  /// 获取指定日期范围内的症状记录
  Future<Either<Failure, List<SymptomEntry>>> getSymptomsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// 获取指定日期的症状记录
  Future<Either<Failure, List<SymptomEntry>>> getSymptomsByDate(DateTime date);

  /// 获取所有症状记录（分页）
  Future<Either<Failure, List<SymptomEntry>>> getAllSymptoms({
    int page = 1,
    int pageSize = 20,
  });

  /// 按症状类型获取记录
  Future<Either<Failure, List<SymptomEntry>>> getSymptomsByType(
    SymptomType type, {
    int? limit,
  });

  /// 搜索症状记录
  Future<Either<Failure, List<SymptomEntry>>> searchSymptoms(String query);

  /// 获取症状统计分析
  Future<Either<Failure, SymptomAnalysis>> getSymptomAnalysis(
    DateTime startDate,
    DateTime endDate,
  );

  /// 获取最近的症状记录
  Future<Either<Failure, List<SymptomEntry>>> getRecentSymptoms({int limit = 10});

  /// 标记症状结束（设置持续时间）
  Future<Either<Failure, SymptomEntry>> markSymptomEnded(
    String id,
    int durationMinutes,
  );
}
