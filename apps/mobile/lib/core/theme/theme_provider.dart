import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// 主题状态管理
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  SharedPreferences? _prefs;

  ThemeProvider() {
    _loadTheme();
  }

  /// 当前主题模式
  AppThemeMode get themeMode => _themeMode;

  /// 是否为深色模式
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
    }
  }

  /// 获取当前主题
  ThemeData getTheme(BuildContext context) {
    switch (_themeMode) {
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
      case AppThemeMode.light:
        return AppTheme.lightTheme;
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
    }
  }

  /// 获取ThemeMode用于MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// 加载主题设置
  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final savedMode = _prefs?.getString(_themeKey);
    if (savedMode != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => AppThemeMode.system,
      );
      notifyListeners();
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs?.setString(_themeKey, mode.name);
    notifyListeners();
  }

  /// 切换到下一个主题模式
  Future<void> toggleTheme() async {
    final currentIndex = AppThemeMode.values.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    await setThemeMode(AppThemeMode.values[nextIndex]);
  }

  /// 快速切换深色/浅色模式
  Future<void> toggleDarkMode(BuildContext context) async {
    if (isDarkMode(context)) {
      await setThemeMode(AppThemeMode.light);
    } else {
      await setThemeMode(AppThemeMode.dark);
    }
  }
}

/// 主题继承小部件（用于方便访问主题状态）
class ThemeProviderWidget extends InheritedNotifier<ThemeProvider> {
  const ThemeProviderWidget({
    super.key,
    required ThemeProvider themeProvider,
    required super.child,
  }) : super(notifier: themeProvider);

  static ThemeProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProviderWidget>()!
        .notifier!;
  }

  static ThemeProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProviderWidget>()
        ?.notifier;
  }
}
