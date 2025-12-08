import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../features/user/data/models/user_model.dart';
import 'models/auth_response.dart';
import 'models/sync_response.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // ============ 用户相关接口 ============

  @GET('/users/{id}')
  Future<UserModel> getUserById(@Path('id') String id);

  @GET('/users')
  Future<List<UserModel>> getAllUsers();

  @POST('/users')
  Future<UserModel> createUser(@Body() UserModel user);

  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') String id);

  // ============ 认证接口 ============

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/refresh')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  @POST('/auth/logout')
  Future<void> logout();

  @GET('/auth/verify')
  Future<void> verifyToken();

  // ============ 同步接口 ============

  /// 上传完整备份
  @POST('/sync/backup')
  Future<BackupResponse> uploadBackup(@Body() Map<String, dynamic> backup);

  /// 下载备份
  @GET('/sync/backup/{id}')
  Future<Map<String, dynamic>> downloadBackup(@Path('id') String id);

  /// 获取备份列表
  @GET('/sync/backups')
  Future<List<BackupResponse>> getBackups();

  /// 删除备份
  @DELETE('/sync/backup/{id}')
  Future<void> deleteBackup(@Path('id') String id);

  /// 增量同步
  @POST('/sync/incremental')
  Future<SyncResultResponse> syncIncremental(
    @Body() IncrementalSyncRequest request,
  );

  /// 获取服务器变更（自指定时间以来）
  @GET('/sync/changes')
  Future<SyncChangesResponse> getChanges(
    @Query('since') String since,
    @Query('limit') int? limit,
  );

  /// 获取同步状态
  @GET('/sync/status')
  Future<Map<String, dynamic>> getSyncStatus();
}
