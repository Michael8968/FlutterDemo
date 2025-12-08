import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'models/auth_response.dart';

/// Token 管理器
/// 负责安全存储和管理认证 Token
class TokenManager {
  final SharedPreferences _prefs;

  // 内存缓存
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  String? _userId;
  String? _userEmail;

  TokenManager(this._prefs) {
    _loadFromStorage();
  }

  /// 从存储加载 Token
  void _loadFromStorage() {
    _accessToken = _prefs.getString(AppConstants.keyAccessToken);
    _refreshToken = _prefs.getString(AppConstants.keyRefreshToken);
    _userId = _prefs.getString(AppConstants.keyUserId);
    _userEmail = _prefs.getString(AppConstants.keyUserEmail);

    final expiryStr = _prefs.getString(AppConstants.keyTokenExpiry);
    if (expiryStr != null) {
      _tokenExpiry = DateTime.tryParse(expiryStr);
    }
  }

  /// 获取访问 Token
  String? get accessToken => _accessToken;

  /// 获取刷新 Token
  String? get refreshToken => _refreshToken;

  /// 获取用户 ID
  String? get userId => _userId;

  /// 获取用户邮箱
  String? get userEmail => _userEmail;

  /// 检查是否已登录
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  /// 检查 Token 是否过期
  bool get isTokenExpired {
    if (_tokenExpiry == null) return true;
    // 提前 5 分钟认为过期，以便有时间刷新
    return DateTime.now().isAfter(
      _tokenExpiry!.subtract(const Duration(minutes: 5)),
    );
  }

  /// 检查 Token 是否需要刷新
  bool get needsRefresh {
    if (!isLoggedIn) return false;
    return isTokenExpired && _refreshToken != null;
  }

  /// 保存认证信息
  Future<void> saveAuthResponse(AuthResponse response) async {
    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken;
    _userId = response.userId;
    _userEmail = response.email;
    _tokenExpiry = response.expiryTime;

    await Future.wait([
      _prefs.setString(AppConstants.keyAccessToken, response.accessToken),
      _prefs.setString(AppConstants.keyRefreshToken, response.refreshToken),
      _prefs.setString(AppConstants.keyUserId, response.userId),
      _prefs.setString(AppConstants.keyUserEmail, response.email),
      _prefs.setString(
        AppConstants.keyTokenExpiry,
        response.expiryTime.toIso8601String(),
      ),
    ]);
  }

  /// 更新 Token（刷新后调用）
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    await Future.wait([
      _prefs.setString(AppConstants.keyAccessToken, accessToken),
      _prefs.setString(AppConstants.keyRefreshToken, refreshToken),
      _prefs.setString(
        AppConstants.keyTokenExpiry,
        _tokenExpiry!.toIso8601String(),
      ),
    ]);
  }

  /// 清除所有认证信息
  Future<void> clearAll() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _userId = null;
    _userEmail = null;

    await Future.wait([
      _prefs.remove(AppConstants.keyAccessToken),
      _prefs.remove(AppConstants.keyRefreshToken),
      _prefs.remove(AppConstants.keyTokenExpiry),
      _prefs.remove(AppConstants.keyUserId),
      _prefs.remove(AppConstants.keyUserEmail),
    ]);
  }

  /// 获取 Authorization Header 值
  String? getAuthorizationHeader() {
    if (_accessToken == null || _accessToken!.isEmpty) return null;
    return 'Bearer $_accessToken';
  }
}
