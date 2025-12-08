import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

/// 语言状态管理
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  AppLanguage _language = AppLanguage.system;
  Locale? _locale;
  SharedPreferences? _prefs;

  LocaleProvider() {
    _loadLocale();
  }

  /// 当前语言设置
  AppLanguage get language => _language;

  /// 当前 Locale
  Locale? get locale => _locale;

  /// 加载语言设置
  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs?.getString(_localeKey);
    if (savedLang != null) {
      _language = AppLanguage.values.firstWhere(
        (lang) => lang.name == savedLang,
        orElse: () => AppLanguage.system,
      );
      _locale = _language.locale;
      notifyListeners();
    }
  }

  /// 设置语言
  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;

    _language = language;
    _locale = language.locale;
    await _prefs?.setString(_localeKey, language.name);
    notifyListeners();
  }

  /// 获取实际显示的 Locale
  Locale getDisplayLocale(BuildContext context) {
    if (_locale != null) {
      return _locale!;
    }
    // 如果是跟随系统，使用系统语言
    final systemLocale = View.of(context).platformDispatcher.locale;
    // 检查是否支持
    if (AppLocalizations.supportedLocales
        .any((l) => l.languageCode == systemLocale.languageCode)) {
      return systemLocale;
    }
    // 默认中文
    return const Locale('zh', 'CN');
  }

  /// 获取当前语言的显示名称
  String getDisplayName(BuildContext context) {
    if (_language == AppLanguage.system) {
      final systemLocale = View.of(context).platformDispatcher.locale;
      if (systemLocale.languageCode == 'zh') {
        return '跟随系统 (中文)';
      } else if (systemLocale.languageCode == 'en') {
        return 'Follow System (English)';
      }
      return '跟随系统';
    }
    return _language.displayName;
  }
}

/// Locale 继承小部件
class LocaleProviderWidget extends InheritedNotifier<LocaleProvider> {
  const LocaleProviderWidget({
    super.key,
    required LocaleProvider localeProvider,
    required super.child,
  }) : super(notifier: localeProvider);

  static LocaleProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleProviderWidget>()!
        .notifier!;
  }

  static LocaleProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleProviderWidget>()
        ?.notifier;
  }
}
