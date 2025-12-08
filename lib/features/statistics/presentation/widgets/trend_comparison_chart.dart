import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import 'period_selector.dart';

/// 可比较的数据类型
enum TrendMetric {
  mood('心情', Colors.pink, 5),
  sleep('睡眠', Colors.indigo, 10),
  energy('精力', Colors.green, 10),
  stress('压力', Colors.orange, 10),
  water('饮水', Colors.blue, 10);

  final String displayName;
  final Color color;
  final double maxValue;

  const TrendMetric(this.displayName, this.color, this.maxValue);
}

/// 趋势对比图表
class TrendComparisonChart extends StatefulWidget {
  final List<DiaryEntry> diaries;
  final StatsPeriod period;

  const TrendComparisonChart({
    super.key,
    required this.diaries,
    required this.period,
  });

  @override
  State<TrendComparisonChart> createState() => _TrendComparisonChartState();
}

class _TrendComparisonChartState extends State<TrendComparisonChart> {
  final Set<TrendMetric> _selectedMetrics = {TrendMetric.mood, TrendMetric.energy};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.stacked_line_chart, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '趋势对比',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 指标选择
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TrendMetric.values.map((metric) {
                  final isSelected = _selectedMetrics.contains(metric);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        metric.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedMetrics.add(metric);
                          } else {
                            // 至少保留一个指标
                            if (_selectedMetrics.length > 1) {
                              _selectedMetrics.remove(metric);
                            }
                          }
                        });
                      },
                      selectedColor: metric.color,
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // 图表
            SizedBox(
              height: 250,
              child: _buildLineChart(),
            ),
            const SizedBox(height: 12),
            // 图例
            _buildLegend(),
            const SizedBox(height: 12),
            // 统计摘要
            _buildStatsSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    if (widget.diaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              '暂无数据',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final sortedDiaries = List<DiaryEntry>.from(widget.diaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final lineBarsData = _selectedMetrics.map((metric) {
      final spots = <FlSpot>[];
      for (int i = 0; i < sortedDiaries.length; i++) {
        final diary = sortedDiaries[i];
        final value = _getMetricValue(diary, metric);
        if (value != null) {
          // 归一化到0-10范围以便比较
          final normalizedValue = (value / metric.maxValue) * 10;
          spots.add(FlSpot(i.toDouble(), normalizedValue));
        }
      }
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: metric.color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: sortedDiaries.length <= 14,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: metric.color,
            strokeWidth: 0,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: metric.color.withOpacity(0.1),
        ),
      );
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        minY: 0,
        maxY: 10,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getXInterval(sortedDiaries.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedDiaries.length) {
                  final date = sortedDiaries[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${date.month}/${date.day}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final metric = _selectedMetrics.elementAt(
                  touchedSpots.indexOf(spot) % _selectedMetrics.length,
                );
                // 反归一化
                final actualValue = (spot.y / 10) * metric.maxValue;
                return LineTooltipItem(
                  '${metric.displayName}: ${actualValue.toStringAsFixed(1)}',
                  TextStyle(
                    color: metric.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getXInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 7;
  }

  double? _getMetricValue(DiaryEntry diary, TrendMetric metric) {
    switch (metric) {
      case TrendMetric.mood:
        return diary.mood.value.toDouble();
      case TrendMetric.sleep:
        return diary.sleepHours;
      case TrendMetric.energy:
        return diary.energyLevel?.toDouble();
      case TrendMetric.stress:
        return diary.stressLevel?.toDouble();
      case TrendMetric.water:
        return diary.waterIntake?.toDouble();
    }
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _selectedMetrics.map((metric) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 3,
                decoration: BoxDecoration(
                  color: metric.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                metric.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsSummary() {
    if (widget.diaries.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _selectedMetrics.map((metric) {
        final values = widget.diaries
            .map((d) => _getMetricValue(d, metric))
            .whereType<double>()
            .toList();

        if (values.isEmpty) {
          return const SizedBox.shrink();
        }

        final avg = values.reduce((a, b) => a + b) / values.length;
        final maxVal = values.reduce((a, b) => a > b ? a : b);
        final minVal = values.reduce((a, b) => a < b ? a : b);

        // 计算趋势
        final trend = _calculateTrend(values);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: metric.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: metric.color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: metric.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: metric.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildMiniStat('平均', avg.toStringAsFixed(1)),
                        const SizedBox(width: 16),
                        _buildMiniStat('最高', maxVal.toStringAsFixed(1)),
                        const SizedBox(width: 16),
                        _buildMiniStat('最低', minVal.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
              // 趋势指示器
              _buildTrendIndicator(trend),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0;

    // 简单线性回归计算趋势
    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }

  Widget _buildTrendIndicator(double trend) {
    IconData icon;
    Color color;
    String label;

    if (trend > 0.1) {
      icon = Icons.trending_up;
      color = Colors.green;
      label = '上升';
    } else if (trend < -0.1) {
      icon = Icons.trending_down;
      color = Colors.red;
      label = '下降';
    } else {
      icon = Icons.trending_flat;
      color = Colors.grey;
      label = '平稳';
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }
}
