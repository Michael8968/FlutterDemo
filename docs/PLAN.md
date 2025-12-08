# 云同步功能实现计划

## 概述

实现真实的云同步功能，将 Mock 实现替换为实际的 API 调用。项目已有完善的网络层框架（Dio + Retrofit）和云同步接口定义，需要实现以下功能：

1. 用户认证（注册/登录/Token管理）
2. 数据同步（上传/下载/增量同步）
3. 离线支持和同步队列

## 技术方案

### 后端 API 设计

基础 URL: `https://api.example.com/api/v1`

```
认证接口:
POST   /auth/register     - 注册
POST   /auth/login        - 登录
POST   /auth/refresh      - 刷新Token
POST   /auth/logout       - 登出

同步接口:
POST   /sync/backup       - 上传完整备份
GET    /sync/backup/{id}  - 下载备份
GET    /sync/backups      - 获取备份列表
DELETE /sync/backup/{id}  - 删除备份
POST   /sync/incremental  - 增量同步
GET    /sync/changes      - 获取变更（since timestamp）
```

---

## 实现步骤

### 步骤 1: 扩展常量配置

**文件**: `lib/core/constants/app_constants.dart`

添加:
- API 版本
- 认证相关 Key
- 同步相关常量

### 步骤 2: 添加认证响应模型

**新文件**: `lib/core/network/models/auth_response.dart`

```dart
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final int expiresIn;
}
```

### 步骤 3: 添加同步 API 响应模型

**新文件**: `lib/core/network/models/sync_response.dart`

```dart
class ApiResponse<T> {
  final bool success;
  final int code;
  final String? message;
  final T? data;
}

class BackupResponse {
  final String id;
  final String fileName;
  final DateTime createdAt;
  final int fileSize;
}

class SyncChangesResponse {
  final List<Map<String, dynamic>> diaries;
  final List<Map<String, dynamic>> symptoms;
  final Map<String, dynamic>? profile;
  final DateTime serverTime;
}
```

### 步骤 4: 扩展 API Service

**文件**: `lib/core/network/api_service.dart`

添加接口:
```dart
// 认证
@POST('/auth/register')
Future<AuthResponse> register(@Body() Map<String, dynamic> body);

@POST('/auth/login')
Future<AuthResponse> login(@Body() Map<String, dynamic> body);

@POST('/auth/refresh')
Future<AuthResponse> refreshToken(@Body() Map<String, dynamic> body);

// 同步
@POST('/sync/backup')
Future<BackupResponse> uploadBackup(@Body() Map<String, dynamic> backup);

@GET('/sync/backup/{id}')
Future<Map<String, dynamic>> downloadBackup(@Path('id') String id);

@GET('/sync/backups')
Future<List<BackupResponse>> getBackups();

@DELETE('/sync/backup/{id}')
Future<void> deleteBackup(@Path('id') String id);

@POST('/sync/incremental')
Future<SyncChangesResponse> syncIncremental(@Body() Map<String, dynamic> changes);

@GET('/sync/changes')
Future<SyncChangesResponse> getChanges(@Query('since') String since);
```

### 步骤 5: 实现 Token 管理器

**新文件**: `lib/core/network/token_manager.dart`

功能:
- 安全存储 Token（SharedPreferences / flutter_secure_storage）
- Token 过期检查
- 自动刷新 Token
- 登录状态管理

```dart
class TokenManager {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  bool isTokenExpired();
  Future<bool> refreshTokenIfNeeded(ApiService apiService);
}
```

### 步骤 6: 增强 ApiClient 拦截器

**文件**: `lib/core/network/api_client.dart`

修改:
- 自动附加 Authorization Header
- 401 响应自动刷新 Token
- 失败重试机制

### 步骤 7: 实现真实的 CloudSyncService

**新文件**: `lib/features/backup/data/services/api_cloud_sync_service.dart`

实现 `CloudSyncService` 接口，调用实际 API:
- 登录/注册调用 `/auth/*` 接口
- 备份操作调用 `/sync/*` 接口
- 本地缓存同步状态

### 步骤 8: 实现增量同步逻辑

**新文件**: `lib/features/backup/domain/services/sync_manager.dart`

功能:
- 记录本地数据变更时间戳
- 比较本地和服务器时间戳
- 合并冲突数据（服务器优先/本地优先/手动选择）
- 同步队列管理

```dart
class SyncManager {
  Future<SyncResult> performSync();
  Future<List<SyncConflict>> detectConflicts();
  Future<void> resolveConflict(SyncConflict conflict, ConflictResolution resolution);
  Future<void> queueChange(DataChange change);
}
```

### 步骤 9: 添加同步状态 BLoC

**新文件**: `lib/features/backup/presentation/bloc/sync_bloc.dart`

管理:
- 同步状态（idle/syncing/success/failed）
- 登录状态
- 错误处理
- UI 状态更新

### 步骤 10: 更新依赖注入

**文件**: `lib/core/di/module.dart`

注册:
- TokenManager
- ApiService
- ApiCloudSyncService
- SyncManager
- SyncBloc

### 步骤 11: 更新 BackupPage

**文件**: `lib/features/backup/presentation/pages/backup_page.dart`

修改:
- 使用 DI 获取服务
- 集成 SyncBloc
- 添加同步进度指示
- 显示冲突解决界面

---

## 文件清单

### 新建文件 (8个)

| 文件路径 | 说明 |
|---------|------|
| `lib/core/network/models/auth_response.dart` | 认证响应模型 |
| `lib/core/network/models/sync_response.dart` | 同步响应模型 |
| `lib/core/network/token_manager.dart` | Token 管理器 |
| `lib/features/backup/data/services/api_cloud_sync_service.dart` | API 云同步服务实现 |
| `lib/features/backup/domain/services/sync_manager.dart` | 增量同步管理器 |
| `lib/features/backup/presentation/bloc/sync_bloc.dart` | 同步状态 BLoC |
| `lib/features/backup/presentation/bloc/sync_event.dart` | 同步事件 |
| `lib/features/backup/presentation/bloc/sync_state.dart` | 同步状态 |

### 修改文件 (5个)

| 文件路径 | 修改内容 |
|---------|---------|
| `lib/core/constants/app_constants.dart` | 添加 API 和认证常量 |
| `lib/core/network/api_client.dart` | 增强拦截器，添加 Token 和重试 |
| `lib/core/network/api_service.dart` | 添加认证和同步接口 |
| `lib/core/di/module.dart` | 注册新服务 |
| `lib/features/backup/presentation/pages/backup_page.dart` | 集成 BLoC 和真实服务 |

---

## 数据流设计

```
用户操作 → SyncBloc → SyncManager → ApiCloudSyncService → ApiService → 后端API
                          ↓
                    本地数据层 (Hive/SharedPreferences)
```

### 同步流程

1. **上传同步**:
   ```
   收集本地数据 → 创建 BackupData → 调用 uploadBackup API → 更新本地同步时间
   ```

2. **下载同步**:
   ```
   调用 getChanges API → 比较时间戳 → 检测冲突 → 合并数据 → 更新本地存储
   ```

3. **增量同步**:
   ```
   获取本地变更 → 获取服务器变更 → 合并（处理冲突）→ 推送本地变更 → 拉取服务器变更
   ```

---

## 冲突解决策略

```dart
enum ConflictResolution {
  serverWins,    // 服务器数据优先
  localWins,     // 本地数据优先
  keepBoth,      // 保留两者（创建副本）
  manual,        // 手动选择
}
```

默认策略：`lastModified` 时间戳较新的数据优先

---

## 安全考虑

1. **Token 存储**: 使用 SharedPreferences（可升级为 flutter_secure_storage）
2. **HTTPS**: 强制使用 HTTPS 通信
3. **Token 刷新**: 自动刷新过期 Token
4. **数据加密**: 可选的端到端加密（后续扩展）

---

## 预计工作量

| 步骤 | 复杂度 |
|-----|-------|
| 步骤 1-3: 模型和常量 | 低 |
| 步骤 4: API Service | 中 |
| 步骤 5-6: Token 管理和拦截器 | 中 |
| 步骤 7: API 云同步服务 | 高 |
| 步骤 8: 增量同步逻辑 | 高 |
| 步骤 9: SyncBloc | 中 |
| 步骤 10-11: DI 和 UI | 低 |

---

## 后续扩展

1. 离线队列：网络恢复后自动同步待处理变更
2. 选择性同步：允许用户选择同步哪些数据类型
3. 同步历史：记录同步日志供用户查看
4. 多设备支持：设备标识和数据合并
