import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/symptom_tracker/data/datasources/symptom_local_datasource.dart';
import 'features/symptom_tracker/data/models/symptom_entry_model.dart';
import 'features/symptom_tracker/data/repositories/symptom_repository_impl.dart';
import 'features/symptom_tracker/presentation/bloc/symptom_bloc.dart';
import 'features/symptom_tracker/presentation/pages/symptom_history_page.dart';

import 'features/health_diary/data/datasources/diary_local_datasource.dart';
import 'features/health_diary/data/models/diary_entry_model.dart';
import 'features/health_diary/data/repositories/diary_repository_impl.dart';
import 'features/health_diary/presentation/bloc/diary_bloc.dart';
import 'features/health_diary/presentation/pages/diary_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 注册 Hive TypeAdapter
  Hive.registerAdapter(SymptomEntryModelAdapter());
  Hive.registerAdapter(DiaryEntryModelAdapter());
  Hive.registerAdapter(GoalProgressModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 创建依赖
    final symptomLocalDataSource = SymptomLocalDataSourceImpl();
    final symptomRepository = SymptomRepositoryImpl(
      localDataSource: symptomLocalDataSource,
    );

    final diaryLocalDataSource = DiaryLocalDataSourceImpl();
    final diaryRepository = DiaryRepositoryImpl(
      localDataSource: diaryLocalDataSource,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SymptomBloc(repository: symptomRepository),
        ),
        BlocProvider(
          create: (_) => DiaryBloc(repository: diaryRepository),
        ),
      ],
      child: MaterialApp(
        title: 'AI Health Coach',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const MainPage(),
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

  final List<Widget> _pages = const [
    DiaryHomePage(),
    SymptomHistoryPage(),
    _ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '日记',
          ),
          NavigationDestination(
            icon: Icon(Icons.healing_outlined),
            selectedIcon: Icon(Icons.healing),
            label: '症状',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 个人中心占位页面
class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '功能开发中...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '健康档案、设置等功能即将上线',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
