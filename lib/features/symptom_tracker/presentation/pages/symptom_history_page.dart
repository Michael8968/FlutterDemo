import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/symptom_bloc.dart';
import '../bloc/symptom_event.dart';
import '../bloc/symptom_state.dart';
import '../widgets/symptom_list_tile.dart';
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
              // TODO: 导航到分析页面
              final now = DateTime.now();
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              context.read<SymptomBloc>().add(LoadSymptomAnalysis(
                    DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
                    now,
                  ));
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
                            onTap: () {
                              // TODO: 显示详情
                            },
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
}
