import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/symptom_tracker/data/datasources/symptom_local_datasource.dart';
import 'features/symptom_tracker/data/models/symptom_entry_model.dart';
import 'features/symptom_tracker/data/repositories/symptom_repository_impl.dart';
import 'features/symptom_tracker/presentation/bloc/symptom_bloc.dart';
import 'features/symptom_tracker/presentation/pages/symptom_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 注册 Hive TypeAdapter
  Hive.registerAdapter(SymptomEntryModelAdapter());

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

    return MaterialApp(
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
      home: BlocProvider(
        create: (context) => SymptomBloc(repository: symptomRepository),
        child: const SymptomHistoryPage(),
      ),
    );
  }
}
