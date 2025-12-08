import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/mood_level.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/diary_event.dart';
import '../bloc/diary_state.dart';
import '../widgets/mood_picker.dart';
import '../widgets/sleep_tracker.dart';
import '../widgets/activity_picker.dart';

/// 日记编辑页面
class DiaryEditPage extends StatefulWidget {
  final DateTime date;
  final DiaryEntry? existingEntry;

  const DiaryEditPage({
    super.key,
    required this.date,
    this.existingEntry,
  });

  @override
  State<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {
  final _notesController = TextEditingController();
  final _gratitudeController = TextEditingController();

  MoodLevel? _selectedMood;
  double? _sleepHours;
  SleepQuality? _sleepQuality;
  int? _stressLevel;
  int? _energyLevel;
  int? _waterIntake;
  int? _steps;
  final List<ActivityType> _activities = [];
  WeatherType? _weather;
  final List<String> _gratitudes = [];
  final List<GoalProgress> _goals = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _loadExistingEntry(widget.existingEntry!);
    }
  }

  void _loadExistingEntry(DiaryEntry entry) {
    _selectedMood = entry.mood;
    _sleepHours = entry.sleepHours;
    _sleepQuality = entry.sleepQuality;
    _stressLevel = entry.stressLevel;
    _energyLevel = entry.energyLevel;
    _waterIntake = entry.waterIntake;
    _steps = entry.steps;
    _activities.addAll(entry.activities);
    _weather = entry.weather;
    _notesController.text = entry.notes ?? '';
    _gratitudes.addAll(entry.gratitudes);
    _goals.addAll(entry.goals);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  void _addGratitude() {
    final text = _gratitudeController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _gratitudes.add(text);
        _gratitudeController.clear();
      });
    }
  }

  void _save() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择今日心情')),
      );
      return;
    }

    context.read<DiaryBloc>().add(SaveDiaryEvent(
          date: widget.date,
          mood: _selectedMood!,
          sleepHours: _sleepHours,
          sleepQuality: _sleepQuality,
          stressLevel: _stressLevel,
          energyLevel: _energyLevel,
          waterIntake: _waterIntake,
          steps: _steps,
          activities: _activities,
          weather: _weather,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          gratitudes: _gratitudes,
          goals: _goals,
        ));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return '昨天';
    }
    return '${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiaryBloc, DiaryState>(
      listener: (context, state) {
        if (state is DiaryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is DiaryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_formatDate(widget.date)),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text('保存'),
            ),
          ],
        ),
        body: BlocBuilder<DiaryBloc, DiaryState>(
          builder: (context, state) {
            if (state is DiaryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 心情选择
                MoodPicker(
                  selectedMood: _selectedMood,
                  onMoodSelected: (mood) {
                    setState(() => _selectedMood = mood);
                  },
                ),
                const SizedBox(height: 24),

                // 睡眠追踪
                SleepTracker(
                  sleepHours: _sleepHours,
                  sleepQuality: _sleepQuality,
                  onHoursChanged: (hours) {
                    setState(() => _sleepHours = hours);
                  },
                  onQualityChanged: (quality) {
                    setState(() => _sleepQuality = quality);
                  },
                ),
                const SizedBox(height: 24),

                // 压力和精力
                _buildLevelSliders(),
                const SizedBox(height: 24),

                // 活动选择
                ActivityPicker(
                  selectedActivities: _activities,
                  onActivityToggled: (activity) {
                    setState(() {
                      if (_activities.contains(activity)) {
                        _activities.remove(activity);
                      } else {
                        _activities.add(activity);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 天气选择
                WeatherPicker(
                  selectedWeather: _weather,
                  onWeatherSelected: (weather) {
                    setState(() => _weather = weather);
                  },
                ),
                const SizedBox(height: 24),

                // 今日感恩
                _buildGratitudeSection(),
                const SizedBox(height: 24),

                // 日记内容
                Text(
                  '今日日记',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: '记录今天的点点滴滴...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 保存按钮
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('保存日记', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelSliders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 压力等级
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('压力等级'),
                const Spacer(),
                Text(
                  _stressLevel != null ? '$_stressLevel/10' : '未记录',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _stressLevel != null
                        ? _getStressColor(_stressLevel!)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            Slider(
              value: (_stressLevel ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor:
                  _stressLevel != null ? _getStressColor(_stressLevel!) : null,
              onChanged: (v) => setState(() => _stressLevel = v.round()),
            ),

            const SizedBox(height: 8),

            // 精力等级
            Row(
              children: [
                const Icon(Icons.bolt, color: Colors.amber),
                const SizedBox(width: 8),
                const Text('精力等级'),
                const Spacer(),
                Text(
                  _energyLevel != null ? '$_energyLevel/10' : '未记录',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _energyLevel != null
                        ? _getEnergyColor(_energyLevel!)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            Slider(
              value: (_energyLevel ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor:
                  _energyLevel != null ? _getEnergyColor(_energyLevel!) : null,
              onChanged: (v) => setState(() => _energyLevel = v.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGratitudeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日感恩 🙏',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _gratitudeController,
                decoration: InputDecoration(
                  hintText: '今天有什么值得感恩的事？',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _addGratitude(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addGratitude,
              icon: const Icon(Icons.add_circle),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        if (_gratitudes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _gratitudes.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                onDeleted: () {
                  setState(() => _gratitudes.removeAt(entry.key));
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Color _getStressColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  Color _getEnergyColor(int level) {
    if (level <= 3) return Colors.red;
    if (level <= 6) return Colors.orange;
    return Colors.green;
  }
}
