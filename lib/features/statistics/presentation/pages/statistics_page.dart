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
import '../widgets/mood_trend_chart.dart';
import '../widgets/symptom_stats_card.dart';
import '../widgets/health_summary_card.dart';
import '../widgets/period_selector.dart';

/// 统计分析页面
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatsPeriod _selectedPeriod = StatsPeriod.week;
  List<DiaryEntry> _diaries = [];
  List<SymptomEntry> _symptoms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final now = DateTime.now();
    final startDate = _getStartDate(now);

    // 加载日记数据
    context.read<DiaryBloc>().add(LoadDiaryRange(startDate, now));

    // 加载症状数据
    context.read<SymptomBloc>().add(LoadSymptomsByDateRange(startDate, now));
  }

  DateTime _getStartDate(DateTime now) {
    switch (_selectedPeriod) {
      case StatsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case StatsPeriod.month:
        return DateTime(now.year, now.month - 1, now.day);
      case StatsPeriod.quarter:
        return DateTime(now.year, now.month - 3, now.day);
      case StatsPeriod.year:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }

  void _onPeriodChanged(StatsPeriod period) {
    setState(() => _selectedPeriod = period);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DiaryBloc, DiaryState>(
            listener: (context, state) {
              if (state is DiaryRangeLoaded) {
                setState(() => _diaries = state.entries);
              }
            },
          ),
          BlocListener<SymptomBloc, SymptomState>(
            listener: (context, state) {
              if (state is SymptomLoaded) {
                setState(() => _symptoms = state.symptoms);
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 时间周期选择
              PeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: _onPeriodChanged,
              ),
              const SizedBox(height: 16),

              // 健康概览
              HealthSummaryCard(
                diaries: _diaries,
                symptoms: _symptoms,
                period: _selectedPeriod,
              ),
              const SizedBox(height: 16),

              // 心情趋势图
              MoodTrendChart(
                diaries: _diaries,
                period: _selectedPeriod,
              ),
              const SizedBox(height: 16),

              // 症状统计
              SymptomStatsCard(
                symptoms: _symptoms,
                period: _selectedPeriod,
              ),
              const SizedBox(height: 16),

              // 睡眠统计
              _buildSleepStatsCard(),
              const SizedBox(height: 16),

              // 压力与精力统计
              _buildStressEnergyCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStatsCard() {
    final sleepData = _diaries
        .where((d) => d.sleepHours != null)
        .map((d) => d.sleepHours!)
        .toList();

    if (sleepData.isEmpty) {
      return _buildEmptyCard('睡眠统计', '暂无睡眠数据', Icons.bedtime);
    }

    final avgSleep = sleepData.reduce((a, b) => a + b) / sleepData.length;
    final maxSleep = sleepData.reduce((a, b) => a > b ? a : b);
    final minSleep = sleepData.reduce((a, b) => a < b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bedtime, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  '睡眠统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '平均睡眠',
                    '${avgSleep.toStringAsFixed(1)}h',
                    Colors.indigo,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '最长睡眠',
                    '${maxSleep.toStringAsFixed(1)}h',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '最短睡眠',
                    '${minSleep.toStringAsFixed(1)}h',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 睡眠质量评估
            _buildSleepQualityIndicator(avgSleep),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualityIndicator(double avgSleep) {
    String quality;
    Color color;
    IconData icon;

    if (avgSleep >= 7 && avgSleep <= 9) {
      quality = '睡眠质量良好';
      color = Colors.green;
      icon = Icons.thumb_up;
    } else if (avgSleep >= 6 && avgSleep < 7) {
      quality = '睡眠略有不足';
      color = Colors.orange;
      icon = Icons.warning;
    } else if (avgSleep > 9) {
      quality = '睡眠时间偏长';
      color = Colors.blue;
      icon = Icons.info;
    } else {
      quality = '睡眠严重不足';
      color = Colors.red;
      icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            quality,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '建议每天睡眠7-9小时',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressEnergyCard() {
    final stressData = _diaries
        .where((d) => d.stressLevel != null)
        .map((d) => d.stressLevel!)
        .toList();
    final energyData = _diaries
        .where((d) => d.energyLevel != null)
        .map((d) => d.energyLevel!)
        .toList();

    if (stressData.isEmpty && energyData.isEmpty) {
      return _buildEmptyCard('压力与精力', '暂无数据', Icons.psychology);
    }

    final avgStress = stressData.isNotEmpty
        ? stressData.reduce((a, b) => a + b) / stressData.length
        : 0.0;
    final avgEnergy = energyData.isNotEmpty
        ? energyData.reduce((a, b) => a + b) / energyData.length
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '压力与精力',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stressData.isNotEmpty) ...[
              _buildProgressBar('压力指数', avgStress / 10, Colors.orange),
              const SizedBox(height: 12),
            ],
            if (energyData.isNotEmpty) ...[
              _buildProgressBar('精力水平', avgEnergy / 10, Colors.green),
            ],
            const SizedBox(height: 12),
            // 建议
            _buildStressEnergyAdvice(avgStress, avgEnergy),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${(value * 10).toStringAsFixed(1)}/10',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStressEnergyAdvice(double stress, double energy) {
    String advice;
    IconData icon;
    Color color;

    if (stress > 7) {
      advice = '压力较大，建议多休息放松';
      icon = Icons.self_improvement;
      color = Colors.orange;
    } else if (energy < 4) {
      advice = '精力不足，注意作息规律';
      icon = Icons.battery_charging_full;
      color = Colors.red;
    } else if (stress <= 4 && energy >= 7) {
      advice = '状态良好，继续保持！';
      icon = Icons.celebration;
      color = Colors.green;
    } else {
      advice = '状态一般，关注身心健康';
      icon = Icons.favorite;
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String title, String message, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
