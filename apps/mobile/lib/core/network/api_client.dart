import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'token_manager.dart';
import 'models/auth_response.dart';

/// API 客户端
/// 配置 Dio 实例，包含拦截器、Token 管理和错误处理
class ApiClient {
  late Dio _dio;
  TokenManager? _tokenManager;
  bool _isRefreshing = false;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// 设置 Token 管理器
  void setTokenManager(TokenManager tokenManager) {
    _tokenManager = tokenManager;
  }

  /// 配置拦截器
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // 添加日志拦截器（仅调试模式）
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
      return true;
    }());
  }

  /// 请求拦截器
  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // 添加认证 Token
    if (_tokenManager != null) {
      final authHeader = _tokenManager!.getAuthorizationHeader();
      if (authHeader != null) {
        options.headers['Authorization'] = authHeader;
      }
    }

    handler.next(options);
  }

  /// 响应拦截器
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // 解包 API 响应，提取 data 字段
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      response.data = data['data'];
    }
    handler.next(response);
  }

  /// 错误拦截器
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // 处理 401 未授权错误 - 尝试刷新 Token
    if (error.response?.statusCode == 401 && !_isRefreshing) {
      if (_tokenManager != null && _tokenManager!.needsRefresh) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          // Token 刷新成功，重试原请求
          try {
            final retryResponse = await _retryRequest(error.requestOptions);
            return handler.resolve(retryResponse);
          } catch (e) {
            // 重试失败
          }
        }
      }

      // Token 刷新失败或无法刷新，清除认证信息
      await _tokenManager?.clearAll();
      return handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          error: AppConstants.errorUnauthorized,
          type: DioExceptionType.badResponse,
          response: error.response,
        ),
      );
    }

    // 处理其他错误
    final exception = _mapErrorToException(error);
    handler.reject(
      DioException(
        requestOptions: error.requestOptions,
        error: exception,
        type: error.type,
        response: error.response,
      ),
    );
  }

  /// 尝试刷新 Token
  Future<bool> _tryRefreshToken() async {
    if (_tokenManager == null || _tokenManager!.refreshToken == null) {
      return false;
    }

    _isRefreshing = true;

    try {
      // 创建新的 Dio 实例避免拦截器循环
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': _tokenManager!.refreshToken},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _tokenManager!.updateTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          expiresIn: authResponse.expiresIn,
        );
        return true;
      }
    } catch (e) {
      // 刷新失败
    } finally {
      _isRefreshing = false;
    }

    return false;
  }

  /// 重试请求
  Future<Response> _retryRequest(RequestOptions options) async {
    final newOptions = Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': _tokenManager!.getAuthorizationHeader(),
      },
    );

    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: newOptions,
    );
  }

  /// 将 Dio 错误映射为应用异常
  Exception _mapErrorToException(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = AppConstants.errorServer;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'] as String;
      }

      switch (statusCode) {
        case 400:
          return ValidationException(message);
        case 401:
          return ServerException(AppConstants.errorUnauthorized);
        case 403:
          return ServerException('没有权限访问');
        case 404:
          return ServerException('资源不存在');
        case 500:
        case 502:
        case 503:
          return ServerException(AppConstants.errorServer);
        default:
          return ServerException(message);
      }
    }

    // 网络错误
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('连接超时，请检查网络');
      case DioExceptionType.connectionError:
        return NetworkException(AppConstants.errorNetwork);
      case DioExceptionType.cancel:
        return NetworkException('请求已取消');
      default:
        return NetworkException(AppConstants.errorUnknown);
    }
  }

  Dio get dio => _dio;
}
