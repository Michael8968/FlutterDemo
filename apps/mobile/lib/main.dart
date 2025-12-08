import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';

import 'features/symptom_tracker/data/models/symptom_entry_model.dart';
import 'features/symptom_tracker/presentation/bloc/symptom_bloc.dart';
import 'features/symptom_tracker/presentation/pages/symptom_history_page.dart';

import 'features/health_diary/data/models/diary_entry_model.dart';
import 'features/health_diary/presentation/bloc/diary_bloc.dart';
import 'features/health_diary/presentation/pages/diary_home_page.dart';

import 'features/dashboard/presentation/pages/dashboard_page.dart';

import 'features/profile/data/models/user_profile_model.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';

import 'features/ai_advisor/presentation/bloc/advisor_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 注册 Hive TypeAdapter
  Hive.registerAdapter(SymptomEntryModelAdapter());
  Hive.registerAdapter(DiaryEntryModelAdapter());
  Hive.registerAdapter(GoalProgressModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());
  Hive.registerAdapter(HealthGoalModelAdapter());
  Hive.registerAdapter(GoalRecordModelAdapter());

  // 初始化依赖注入
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SymptomBloc>()),
        BlocProvider(create: (_) => getIt<DiaryBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<AdvisorBloc>()),
      ],
      child: LocaleProviderWidget(
        localeProvider: getIt<LocaleProvider>(),
        child: ThemeProviderWidget(
          themeProvider: getIt<ThemeProvider>(),
          child: Builder(
            builder: (context) {
              final themeProvider = ThemeProviderWidget.of(context);
              final localeProvider = LocaleProviderWidget.of(context);

              return ListenableBuilder(
                listenable: Listenable.merge([themeProvider, localeProvider]),
                builder: (context, _) {
                  return MaterialApp(
                    title: 'AI Health Coach',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeProvider.materialThemeMode,
                    locale: localeProvider.locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    localeResolutionCallback: (locale, supportedLocales) {
                      if (localeProvider.locale != null) {
                        return localeProvider.locale;
                      }
                      for (final supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                            locale?.languageCode) {
                          return supportedLocale;
                        }
                      }
                      return supportedLocales.first;
                    },
                    home: const MainPage(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 主页面（带底部导航）
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardPage(onNavigate: _navigateToTab),
      const DiaryHomePage(),
      const SymptomHistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context).navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: AppLocalizations.of(context).navDiary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.healing_outlined),
            selectedIcon: const Icon(Icons.healing),
            label: AppLocalizations.of(context).navSymptom,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context).navProfile,
          ),
        ],
      ),
    );
  }
}
