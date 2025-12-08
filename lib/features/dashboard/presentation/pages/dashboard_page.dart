import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import '../../../health_diary/presentation/bloc/diary_bloc.dart';
import '../../../health_diary/presentation/bloc/diary_event.dart';
import '../../../health_diary/presentation/bloc/diary_state.dart';
import '../../../symptom_tracker/domain/entities/symptom_entry.dart';
import '../../../symptom_tracker/presentation/bloc/symptom_bloc.dart';
import '../../../symptom_tracker/presentation/bloc/symptom_event.dart';
import '../../../symptom_tracker/presentation/bloc/symptom_state.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../ai_advisor/presentation/pages/ai_advisor_page.dart';
import '../widgets/health_overview_card.dart';
import '../widgets/recent_symptoms_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/weekly_mood_chart.dart';

/// 仪表盘页面
class DashboardPage extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardPage({super.key, this.onNavigate});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DiaryEntry? _todayDiary;
  final List<DiaryEntry> _weekDiaries = [];
  List<SymptomEntry> _recentSymptoms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // 加载今日日记
    context.read<DiaryBloc>().add(LoadDiaryByDate(DateTime.now()));

    // 加载本周日记
    context.read<DiaryBloc>().add(LoadDatesWithDiary(DateTime.now()));

    // 加载最近症状
    context.read<SymptomBloc>().add(const LoadRecentSymptoms(limit: 5));
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 9) return '早上好';
    if (hour < 12) return '上午好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    if (hour < 22) return '晚上好';
    return '夜深了';
  }

  String _getHealthTip() {
    final tips = [
      '记得多喝水，保持身体水分充足',
      '适当休息，让眼睛远眺放松一下',
      '站起来活动活动，久坐不利于健康',
      '深呼吸几次，释放压力',
      '今天有什么值得感恩的事吗？',
      '保持微笑，好心情是最好的良药',
      '睡前不要看手机，保证睡眠质量',
      '适量运动，增强体质',
    ];
    return tips[DateTime.now().minute % tips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<DiaryBloc, DiaryState>(
            listener: (context, state) {
              if (state is DiaryLoaded) {
                setState(() => _todayDiary = state.entry);
              }
            },
          ),
          BlocListener<SymptomBloc, SymptomState>(
            listener: (context, state) {
              if (state is SymptomLoaded) {
                setState(() => _recentSymptoms = state.symptoms);
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 内容
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 健康提示
                    HealthTipCard(tip: _getHealthTip()),
                    const SizedBox(height: 16),

                    // 今日状态概览
                    HealthOverviewCard(
                      todayDiary: _todayDiary,
                      onTap: () => widget.onNavigate?.call(1),
                    ),
                    const SizedBox(height: 16),

                    // 快捷操作
                    QuickActionsCard(
                      onRecordMood: () => widget.onNavigate?.call(1),
                      onRecordSymptom: () => widget.onNavigate?.call(2),
                      onViewDiary: () => widget.onNavigate?.call(1),
                      onViewStats: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatisticsPage(),
                          ),
                        );
                      },
                      onViewAiAdvisor: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AiAdvisorPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // 本周心情
                    WeeklyMoodChart(weekDiaries: _weekDiaries),
                    const SizedBox(height: 16),

                    // 最近症状
                    RecentSymptomsCard(
                      symptoms: _recentSymptoms,
                      onViewAll: () => widget.onNavigate?.call(2),
                      onAddSymptom: () => widget.onNavigate?.call(2),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
