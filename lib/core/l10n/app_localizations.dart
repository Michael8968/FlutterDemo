import 'package:flutter/material.dart';

/// 支持的语言
enum AppLanguage {
  system('跟随系统', 'System', null),
  zhCN('简体中文', 'Chinese (Simplified)', Locale('zh', 'CN')),
  en('English', 'English', Locale('en', 'US'));

  final String displayName;
  final String englishName;
  final Locale? locale;

  const AppLanguage(this.displayName, this.englishName, this.locale);

  static AppLanguage fromLocale(Locale? locale) {
    if (locale == null) return AppLanguage.system;

    for (final lang in AppLanguage.values) {
      if (lang.locale?.languageCode == locale.languageCode) {
        return lang;
      }
    }
    return AppLanguage.system;
  }
}

/// 应用本地化
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  /// 判断是否为中文
  bool get isZhCN => locale.languageCode == 'zh';

  /// 所有翻译文本
  Map<String, String> get _localizedStrings {
    if (isZhCN) {
      return _zhCN;
    }
    return _en;
  }

  /// 获取翻译文本
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // ============ 通用 ============
  String get appName => translate('app_name');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get confirm => translate('confirm');
  String get close => translate('close');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get noData => translate('no_data');
  String get retry => translate('retry');

  // ============ 导航 ============
  String get navHome => translate('nav_home');
  String get navDiary => translate('nav_diary');
  String get navSymptom => translate('nav_symptom');
  String get navProfile => translate('nav_profile');

  // ============ 首页 ============
  String get greeting => translate('greeting');
  String get healthTip => translate('health_tip');
  String get todayOverview => translate('today_overview');
  String get quickActions => translate('quick_actions');
  String get recentSymptoms => translate('recent_symptoms');
  String get weeklyMood => translate('weekly_mood');

  // ============ 日记 ============
  String get healthDiary => translate('health_diary');
  String get recordMood => translate('record_mood');
  String get mood => translate('mood');
  String get sleep => translate('sleep');
  String get sleepHours => translate('sleep_hours');
  String get sleepQuality => translate('sleep_quality');
  String get stress => translate('stress');
  String get energy => translate('energy');
  String get water => translate('water');
  String get steps => translate('steps');
  String get weight => translate('weight');
  String get activities => translate('activities');
  String get weather => translate('weather');
  String get notes => translate('notes');
  String get gratitude => translate('gratitude');

  // ============ 症状 ============
  String get symptomTracker => translate('symptom_tracker');
  String get recordSymptom => translate('record_symptom');
  String get symptomName => translate('symptom_name');
  String get severity => translate('severity');
  String get bodyParts => translate('body_parts');
  String get duration => translate('duration');
  String get triggers => translate('triggers');

  // ============ 个人中心 ============
  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get healthGoals => translate('health_goals');
  String get healthRecord => translate('health_record');
  String get achievements => translate('achievements');
  String get reminders => translate('reminders');
  String get dataExport => translate('data_export');
  String get backupSync => translate('backup_sync');
  String get darkMode => translate('dark_mode');
  String get language => translate('language');
  String get about => translate('about');

  // ============ 设置 ============
  String get settings => translate('settings');
  String get general => translate('general');
  String get appearance => translate('appearance');
  String get followSystem => translate('follow_system');
  String get lightMode => translate('light_mode');
  String get selectTheme => translate('select_theme');
  String get selectLanguage => translate('select_language');

  // ============ 统计 ============
  String get statistics => translate('statistics');
  String get moodTrend => translate('mood_trend');
  String get sleepStats => translate('sleep_stats');
  String get symptomStats => translate('symptom_stats');
  String get correlation => translate('correlation');
  String get average => translate('average');
  String get max => translate('max');
  String get min => translate('min');

  // ============ AI 建议 ============
  String get aiAdvisor => translate('ai_advisor');
  String get healthScore => translate('health_score');
  String get healthAdvice => translate('health_advice');
  String get generateReport => translate('generate_report');

  // ============ 备份 ============
  String get backup => translate('backup');
  String get restore => translate('restore');
  String get localBackup => translate('local_backup');
  String get cloudSync => translate('cloud_sync');
  String get autoBackup => translate('auto_backup');
  String get lastBackup => translate('last_backup');

  // ============ 成就 ============
  String get achievementSystem => translate('achievement_system');
  String get unlocked => translate('unlocked');
  String get locked => translate('locked');
  String get progress => translate('progress');
  String get share => translate('share');

  // ============ 中文翻译 ============
  static const Map<String, String> _zhCN = {
    // 通用
    'app_name': 'AI 健康教练',
    'ok': '确定',
    'cancel': '取消',
    'save': '保存',
    'delete': '删除',
    'edit': '编辑',
    'add': '添加',
    'confirm': '确认',
    'close': '关闭',
    'loading': '加载中...',
    'error': '错误',
    'success': '成功',
    'no_data': '暂无数据',
    'retry': '重试',

    // 导航
    'nav_home': '首页',
    'nav_diary': '日记',
    'nav_symptom': '症状',
    'nav_profile': '我的',

    // 首页
    'greeting': '你好',
    'health_tip': '健康小贴士',
    'today_overview': '今日概览',
    'quick_actions': '快捷操作',
    'recent_symptoms': '最近症状',
    'weekly_mood': '本周心情',

    // 日记
    'health_diary': '健康日记',
    'record_mood': '记录心情',
    'mood': '心情',
    'sleep': '睡眠',
    'sleep_hours': '睡眠时长',
    'sleep_quality': '睡眠质量',
    'stress': '压力',
    'energy': '精力',
    'water': '饮水',
    'steps': '步数',
    'weight': '体重',
    'activities': '活动',
    'weather': '天气',
    'notes': '备注',
    'gratitude': '感恩',

    // 症状
    'symptom_tracker': '症状追踪',
    'record_symptom': '记录症状',
    'symptom_name': '症状名称',
    'severity': '严重程度',
    'body_parts': '身体部位',
    'duration': '持续时间',
    'triggers': '触发因素',

    // 个人中心
    'profile': '个人中心',
    'edit_profile': '编辑资料',
    'health_goals': '健康目标',
    'health_record': '健康档案',
    'achievements': '我的成就',
    'reminders': '提醒设置',
    'data_export': '数据导出',
    'backup_sync': '备份与同步',
    'dark_mode': '深色模式',
    'language': '语言',
    'about': '关于',

    // 设置
    'settings': '设置',
    'general': '通用',
    'appearance': '外观',
    'follow_system': '跟随系统',
    'light_mode': '浅色模式',
    'select_theme': '选择主题',
    'select_language': '选择语言',

    // 统计
    'statistics': '数据统计',
    'mood_trend': '心情趋势',
    'sleep_stats': '睡眠统计',
    'symptom_stats': '症状统计',
    'correlation': '相关性分析',
    'average': '平均',
    'max': '最高',
    'min': '最低',

    // AI 建议
    'ai_advisor': 'AI 顾问',
    'health_score': '健康评分',
    'health_advice': '健康建议',
    'generate_report': '生成报告',

    // 备份
    'backup': '备份',
    'restore': '恢复',
    'local_backup': '本地备份',
    'cloud_sync': '云端同步',
    'auto_backup': '自动备份',
    'last_backup': '上次备份',

    // 成就
    'achievement_system': '成就系统',
    'unlocked': '已解锁',
    'locked': '未解锁',
    'progress': '进度',
    'share': '分享',
  };

  // ============ 英文翻译 ============
  static const Map<String, String> _en = {
    // Common
    'app_name': 'AI Health Coach',
    'ok': 'OK',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'confirm': 'Confirm',
    'close': 'Close',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'no_data': 'No Data',
    'retry': 'Retry',

    // Navigation
    'nav_home': 'Home',
    'nav_diary': 'Diary',
    'nav_symptom': 'Symptoms',
    'nav_profile': 'Profile',

    // Home
    'greeting': 'Hello',
    'health_tip': 'Health Tip',
    'today_overview': 'Today\'s Overview',
    'quick_actions': 'Quick Actions',
    'recent_symptoms': 'Recent Symptoms',
    'weekly_mood': 'Weekly Mood',

    // Diary
    'health_diary': 'Health Diary',
    'record_mood': 'Record Mood',
    'mood': 'Mood',
    'sleep': 'Sleep',
    'sleep_hours': 'Sleep Hours',
    'sleep_quality': 'Sleep Quality',
    'stress': 'Stress',
    'energy': 'Energy',
    'water': 'Water',
    'steps': 'Steps',
    'weight': 'Weight',
    'activities': 'Activities',
    'weather': 'Weather',
    'notes': 'Notes',
    'gratitude': 'Gratitude',

    // Symptoms
    'symptom_tracker': 'Symptom Tracker',
    'record_symptom': 'Record Symptom',
    'symptom_name': 'Symptom Name',
    'severity': 'Severity',
    'body_parts': 'Body Parts',
    'duration': 'Duration',
    'triggers': 'Triggers',

    // Profile
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'health_goals': 'Health Goals',
    'health_record': 'Health Record',
    'achievements': 'Achievements',
    'reminders': 'Reminders',
    'data_export': 'Data Export',
    'backup_sync': 'Backup & Sync',
    'dark_mode': 'Dark Mode',
    'language': 'Language',
    'about': 'About',

    // Settings
    'settings': 'Settings',
    'general': 'General',
    'appearance': 'Appearance',
    'follow_system': 'Follow System',
    'light_mode': 'Light Mode',
    'select_theme': 'Select Theme',
    'select_language': 'Select Language',

    // Statistics
    'statistics': 'Statistics',
    'mood_trend': 'Mood Trend',
    'sleep_stats': 'Sleep Statistics',
    'symptom_stats': 'Symptom Statistics',
    'correlation': 'Correlation Analysis',
    'average': 'Average',
    'max': 'Maximum',
    'min': 'Minimum',

    // AI Advisor
    'ai_advisor': 'AI Advisor',
    'health_score': 'Health Score',
    'health_advice': 'Health Advice',
    'generate_report': 'Generate Report',

    // Backup
    'backup': 'Backup',
    'restore': 'Restore',
    'local_backup': 'Local Backup',
    'cloud_sync': 'Cloud Sync',
    'auto_backup': 'Auto Backup',
    'last_backup': 'Last Backup',

    // Achievements
    'achievement_system': 'Achievements',
    'unlocked': 'Unlocked',
    'locked': 'Locked',
    'progress': 'Progress',
    'share': 'Share',
  };
}

/// 本地化代理
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
