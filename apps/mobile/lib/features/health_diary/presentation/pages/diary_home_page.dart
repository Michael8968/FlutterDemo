import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/diary_entry.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/diary_event.dart';
import '../bloc/diary_state.dart';
import '../widgets/mood_picker.dart';
import 'diary_edit_page.dart';

/// 日记首页
class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  DateTime _selectedDate = DateTime.now();
  final DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDiary();
    _loadDatesWithDiary();
  }

  void _loadDiary() {
    context.read<DiaryBloc>().add(LoadDiaryByDate(_selectedDate));
  }

  void _loadDatesWithDiary() {
    context.read<DiaryBloc>().add(LoadDatesWithDiary(_focusedMonth));
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    _loadDiary();
  }

  Future<void> _openEditor({DiaryEntry? existingEntry}) async {
    final bloc = context.read<DiaryBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: DiaryEditPage(
            date: _selectedDate,
            existingEntry: existingEntry,
          ),
        ),
      ),
    );
    if (result == true) {
      _loadDiary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                _selectDate(picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 简易周视图
          _buildWeekView(),

          // 日记内容
          Expanded(
            child: BlocBuilder<DiaryBloc, DiaryState>(
              builder: (context, state) {
                if (state is DiaryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DiaryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(state.message),
                        ElevatedButton(
                          onPressed: _loadDiary,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DiaryLoaded) {
                  if (state.entry == null) {
                    return _buildEmptyState();
                  }
                  return _buildDiaryContent(state.entry!);
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final state = context.read<DiaryBloc>().state;
          DiaryEntry? existing;
          if (state is DiaryLoaded) {
            existing = state.entry;
          }
          _openEditor(existingEntry: existing);
        },
        icon: const Icon(Icons.edit),
        label: const Text('记录'),
      ),
    );
  }

  Widget _buildWeekView() {
    final now = DateTime.now();
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;
          final isFuture = date.isAfter(now);

          return GestureDetector(
            onTap: isFuture ? null : () => _selectDate(date),
            child: Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    ['一', '二', '三', '四', '五', '六', '日'][index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : isFuture
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isFuture
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isToday = _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isToday ? '今天还没有记录' : '这天没有日记',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮开始记录',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryContent(DiaryEntry entry) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 心情卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                MoodDisplay(mood: entry.mood, size: 56),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '心情${entry.mood.displayName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${entry.date.month}月${entry.date.day}日',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Spacer(),
                if (entry.weather != null)
                  Text(
                    entry.weather!.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 数据卡片
        Row(
          children: [
            if (entry.sleepHours != null)
              Expanded(
                child: _buildStatCard(
                  '睡眠',
                  '${entry.sleepHours!.toStringAsFixed(1)}h',
                  Icons.bedtime,
                  Colors.indigo,
                ),
              ),
            if (entry.stressLevel != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  '压力',
                  '${entry.stressLevel}/10',
                  Icons.psychology,
                  Colors.orange,
                ),
              ),
            ],
            if (entry.energyLevel != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  '精力',
                  '${entry.energyLevel}/10',
                  Icons.bolt,
                  Colors.amber,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // 活动
        if (entry.activities.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日活动',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.activities
                        .map((a) => Chip(
                              avatar: Text(a.emoji),
                              label: Text(a.displayName),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 感恩
        if (entry.gratitudes.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🙏'),
                      SizedBox(width: 8),
                      Text(
                        '今日感恩',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...entry.gratitudes.map((g) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(g)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 日记内容
        if (entry.notes != null && entry.notes!.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '日记',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.notes!),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
