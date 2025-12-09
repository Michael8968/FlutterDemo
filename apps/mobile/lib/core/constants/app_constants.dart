class AppConstants {
  // API 配置
  static const String baseUrl = 'http://localhost:3000';
  static const String apiVersion = '/api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 本地存储 Key - 认证
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyTokenExpiry = 'token_expiry';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';

  // 本地存储 Key - 设置
  static const String keyTheme = 'theme_mode';
  static const String keySyncSettings = 'sync_settings';
  static const String keyLastSyncTime = 'last_sync_time';

  // 同步配置
  static const int defaultSyncIntervalDays = 7;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // 错误消息
  static const String errorNetwork = '网络连接失败，请检查网络设置';
  static const String errorServer = '服务器错误，请稍后重试';
  static const String errorUnknown = '未知错误';
  static const String errorUnauthorized = '登录已过期，请重新登录';
  static const String errorSyncFailed = '同步失败，请稍后重试';
}

