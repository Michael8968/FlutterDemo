import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/advisor_bloc.dart';
import '../bloc/advisor_event.dart';
import '../bloc/advisor_state.dart';
import '../widgets/health_score_card.dart';
import '../widgets/advice_card.dart';
import '../../domain/entities/health_advice.dart';

/// AI 健康顾问页面
class AiAdvisorPage extends StatefulWidget {
  const AiAdvisorPage({super.key});

  @override
  State<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends State<AiAdvisorPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdvisorBloc>().add(const GenerateHealthReport());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 健康顾问'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdvisorBloc>().add(const RefreshAdvices());
            },
          ),
        ],
      ),
      body: BlocBuilder<AdvisorBloc, AdvisorState>(
        builder: (context, state) {
          if (state is AdvisorLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在分析您的健康数据...'),
                ],
              ),
            );
          }

          if (state is AdvisorError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdvisorBloc>().add(const RefreshAdvices());
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (state is AdvisorLoaded) {
            return _buildReport(state.report);
          }

          return const Center(
            child: Text('点击刷新按钮生成健康报告'),
          );
        },
      ),
    );
  }

  Widget _buildReport(HealthReport report) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdvisorBloc>().add(const RefreshAdvices());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI 助手头部
          _buildAiHeader(),
          const SizedBox(height: 16),

          // 健康评分卡片
          HealthScoreCard(
            score: report.overallScore,
            categoryScores: report.categoryScores,
            highlights: report.highlights,
            concerns: report.concerns,
          ),
          const SizedBox(height: 24),

          // 建议列表标题
          if (report.advices.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.tips_and_updates, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '健康建议',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${report.advices.length} 条建议',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 建议卡片列表
            ...report.advices.map((advice) => AdviceCard(
                  advice: advice,
                  onTap: () => _showAdviceDetail(advice),
                  onDismiss: () {
                    context.read<AdvisorBloc>().add(DismissAdvice(advice.id));
                  },
                )),
          ] else ...[
            _buildNoAdvicesCard(),
          ],

          const SizedBox(height: 24),

          // 分析时间
          Center(
            child: Text(
              '分析时间: ${_formatDateTime(report.analyzedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAiHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 健康顾问',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '基于您的健康数据，为您提供个性化建议',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAdvicesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              '太棒了！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '您目前的健康状态良好，暂无特别建议',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdviceDetail(HealthAdvice advice) {
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖动指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 标题
              Text(
                advice.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 类型标签
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  advice.type.displayName,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 描述
              Text(
                advice.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // 行动项
              if (advice.actionItems.isNotEmpty) ...[
                const Text(
                  '建议行动',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...advice.actionItems.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // 原因说明
              if (advice.reason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '为什么这很重要',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              advice.reason!,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
