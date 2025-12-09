import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User 模块
import '../../features/user/data/datasources/user_local_datasource.dart';
import '../../features/user/data/datasources/user_remote_datasource.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/user/domain/usecases/get_user_by_id.dart';
import '../../features/user/domain/usecases/get_all_users.dart';

// Symptom 模块
import '../../features/symptom_tracker/data/datasources/symptom_local_datasource.dart';
import '../../features/symptom_tracker/data/repositories/symptom_repository_impl.dart';
import '../../features/symptom_tracker/domain/repositories/symptom_repository.dart';
import '../../features/symptom_tracker/presentation/bloc/symptom_bloc.dart';

// Diary 模块
import '../../features/health_diary/data/datasources/diary_local_datasource.dart';
import '../../features/health_diary/data/repositories/diary_repository_impl.dart';
import '../../features/health_diary/domain/repositories/diary_repository.dart';
import '../../features/health_diary/presentation/bloc/diary_bloc.dart';

// Profile 模块
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// AI Advisor 模块
import '../../features/ai_advisor/presentation/bloc/advisor_bloc.dart';

// Theme & Locale
import '../theme/theme_provider.dart';
import '../l10n/locale_provider.dart';

// Network & Sync
import '../network/api_client.dart';
import '../network/api_service.dart';
import '../network/token_manager.dart';
import '../sync/sync_manager.dart';

// ============ 数据源注册 ============
@module
abstract class DataSourceModule {
  // User
  @lazySingleton
  UserRemoteDataSource get userRemoteDataSource => UserRemoteDataSourceImpl();

  @lazySingleton
  UserLocalDataSource get userLocalDataSource => UserLocalDataSourceImpl();

  // Symptom
  @lazySingleton
  SymptomLocalDataSource get symptomLocalDataSource =>
      SymptomLocalDataSourceImpl();

  // Diary
  @lazySingleton
  DiaryLocalDataSource get diaryLocalDataSource => DiaryLocalDataSourceImpl();

  // Profile
  @lazySingleton
  ProfileLocalDataSource get profileLocalDataSource =>
      ProfileLocalDataSourceImpl();
}

// ============ 仓库注册 ============
@module
abstract class RepositoryModule {
  // User
  @lazySingleton
  UserRepository userRepository(
    UserRemoteDataSource remoteDataSource,
    UserLocalDataSource localDataSource,
  ) =>
      UserRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      );

  // Symptom - 注入 SyncManager
  @lazySingleton
  SymptomRepository symptomRepository(
    SymptomLocalDataSource localDataSource,
    SyncManager syncManager,
  ) =>
      SymptomRepositoryImpl(
        localDataSource: localDataSource,
        syncManager: syncManager,
      );

  // Diary - 注入 SyncManager
  @lazySingleton
  DiaryRepository diaryRepository(
    DiaryLocalDataSource localDataSource,
    SyncManager syncManager,
  ) =>
      DiaryRepositoryImpl(
        localDataSource: localDataSource,
        syncManager: syncManager,
      );

  // Profile - 注入 SyncManager
  @lazySingleton
  ProfileRepository profileRepository(
    ProfileLocalDataSource localDataSource,
    SyncManager syncManager,
  ) =>
      ProfileRepositoryImpl(
        localDataSource: localDataSource,
        syncManager: syncManager,
      );
}

// ============ UseCase 注册 ============
@module
abstract class UseCaseModule {
  @lazySingleton
  GetUserById getUserById(UserRepository repository) =>
      GetUserById(repository);

  @lazySingleton
  GetAllUsers getAllUsers(UserRepository repository) =>
      GetAllUsers(repository);
}

// ============ BLoC 注册 ============
@module
abstract class BlocModule {
  @lazySingleton
  SymptomBloc symptomBloc(SymptomRepository repository) =>
      SymptomBloc(repository: repository);

  @lazySingleton
  DiaryBloc diaryBloc(DiaryRepository repository) =>
      DiaryBloc(repository: repository);

  @lazySingleton
  ProfileBloc profileBloc(ProfileRepository repository) =>
      ProfileBloc(repository: repository);

  @lazySingleton
  AdvisorBloc advisorBloc(
    DiaryRepository diaryRepository,
    SymptomRepository symptomRepository,
    ProfileRepository profileRepository,
  ) =>
      AdvisorBloc(
        diaryRepository: diaryRepository,
        symptomRepository: symptomRepository,
        profileRepository: profileRepository,
      );
}

// ============ 全局提供者注册 ============
@module
abstract class ProviderModule {
  @lazySingleton
  ThemeProvider get themeProvider => ThemeProvider();

  @lazySingleton
  LocaleProvider get localeProvider => LocaleProvider();
}

// ============ 网络与同步模块注册 ============
@module
abstract class NetworkModule {
  @lazySingleton
  ApiClient get apiClient => ApiClient();

  @lazySingleton
  TokenManager tokenManager(SharedPreferences prefs) => TokenManager(prefs);

  @lazySingleton
  ApiService apiService(ApiClient apiClient, TokenManager tokenManager) {
    apiClient.setTokenManager(tokenManager);
    return ApiService(apiClient.dio);
  }

  @lazySingleton
  SyncManager syncManager(
    ApiService apiService,
    TokenManager tokenManager,
    SharedPreferences prefs,
  ) =>
      SyncManager(
        apiService: apiService,
        tokenManager: tokenManager,
        prefs: prefs,
      );
}
