import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/symptom_bloc.dart';
import '../bloc/symptom_event.dart';
import '../bloc/symptom_state.dart';
import '../widgets/symptom_list_tile.dart';
import '../../domain/entities/symptom_entry.dart';
import '../../domain/entities/body_part.dart';
import 'symptom_input_page.dart';

/// 症状历史页面
class SymptomHistoryPage extends StatefulWidget {
  const SymptomHistoryPage({super.key});

  @override
  State<SymptomHistoryPage> createState() => _SymptomHistoryPageState();
}

class _SymptomHistoryPageState extends State<SymptomHistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  void _loadSymptoms() {
    context.read<SymptomBloc>().add(const LoadRecentSymptoms(limit: 50));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('症状记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              final now = DateTime.now();
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              context.read<SymptomBloc>().add(LoadSymptomAnalysis(
                    DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
                    now,
                  ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('正在加载本周症状分析...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: '查看分析',
          ),
        ],
      ),
      body: BlocConsumer<SymptomBloc, SymptomState>(
        listener: (context, state) {
          if (state is SymptomOperationSuccess) {
            _loadSymptoms();
          }
        },
        builder: (context, state) {
          if (state is SymptomLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SymptomError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSymptoms,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (state is SymptomAnalysisLoaded) {
            return _buildAnalysisView(state.analysis);
          }

          if (state is SymptomLoaded) {
            final symptoms = state.symptoms;

            if (symptoms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无症状记录',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击下方按钮记录症状',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 按日期分组
            final groupedSymptoms = <String, List<dynamic>>{};
            for (final symptom in symptoms) {
              final dateKey = _formatDate(symptom.timestamp);
              groupedSymptoms.putIfAbsent(dateKey, () => []).add(symptom);
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadSymptoms();
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: groupedSymptoms.length,
                itemBuilder: (context, index) {
                  final dateKey = groupedSymptoms.keys.elementAt(index);
                  final items = groupedSymptoms[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          dateKey,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      ...items.map((symptom) => SymptomListTile(
                            entry: symptom,
                            onTap: () => _showSymptomDetails(symptom),
                            onDelete: () {
                              context.read<SymptomBloc>().add(
                                    DeleteSymptomEvent(symptom.id),
                                  );
                            },
                          )),
                    ],
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bloc = context.read<SymptomBloc>();
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const SymptomInputPage(),
              ),
            ),
          );
          if (result == true) {
            _loadSymptoms();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('记录症状'),
      ),
    );
  }

  Widget _buildAnalysisView(dynamic analysis) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _loadSymptoms,
            ),
            const Text(
              '本周症状分析',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '总记录: ${analysis.totalEntries} 次',
                  style: const TextStyle(fontSize: 18),
                ),
                const Divider(),
                if (analysis.topSymptoms.isNotEmpty) ...[
                  const Text(
                    '最常见症状:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: analysis.topSymptoms
                        .map<Widget>((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                ],
                if (analysis.topTriggers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '常见诱因:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: analysis.topTriggers
                        .map<Widget>((t) => Chip(
                              label: Text(t),
                              backgroundColor: Colors.orange.shade100,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSymptomDetails(SymptomEntry symptom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖动指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 症状名称和类型
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(symptom.severity).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      symptom.type.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symptom.symptomName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          symptom.type.displayName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (symptom.isOngoing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '进行中',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // 严重程度
              _buildDetailSection(
                icon: Icons.speed,
                title: '严重程度',
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: symptom.severity / 10,
                          backgroundColor: Colors.grey.shade200,
                          color: _getSeverityColor(symptom.severity),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${symptom.severity}/10',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getSeverityColor(symptom.severity),
                      ),
                    ),
                  ],
                ),
              ),

              // 时间
              _buildDetailSection(
                icon: Icons.access_time,
                title: '记录时间',
                child: Text(
                  _formatFullDate(symptom.timestamp),
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // 持续时间
              if (symptom.durationMinutes != null)
                _buildDetailSection(
                  icon: Icons.timer_outlined,
                  title: '持续时间',
                  child: Text(
                    symptom.durationDisplay ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

              // 身体部位
              if (symptom.bodyParts.isNotEmpty)
                _buildDetailSection(
                  icon: Icons.accessibility_new,
                  title: '涉及部位',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: symptom.bodyParts.map((part) {
                      final bodyPart = _getBodyPartDisplayName(part);
                      return Chip(
                        label: Text(bodyPart),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                      );
                    }).toList(),
                  ),
                ),

              // 诱因
              if (symptom.triggers.isNotEmpty)
                _buildDetailSection(
                  icon: Icons.lightbulb_outline,
                  title: '可能诱因',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: symptom.triggers.map((trigger) {
                      return Chip(
                        label: Text(trigger),
                        backgroundColor: Colors.orange.shade50,
                        labelStyle: TextStyle(color: Colors.orange.shade700),
                      );
                    }).toList(),
                  ),
                ),

              // 备注
              if (symptom.notes != null && symptom.notes!.isNotEmpty)
                _buildDetailSection(
                  icon: Icons.notes,
                  title: '备注',
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      symptom.notes!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 5) return Colors.orange;
    if (severity <= 8) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getBodyPartDisplayName(String partId) {
    try {
      final bodyPart = BodyPart.values.firstWhere(
        (part) => part.name == partId,
      );
      return bodyPart.displayName;
    } catch (_) {
      return partId;
    }
  }
}
