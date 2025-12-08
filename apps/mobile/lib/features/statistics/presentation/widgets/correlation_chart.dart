import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../health_diary/domain/entities/diary_entry.dart';
import 'period_selector.dart';

/// 相关性指标类型
enum CorrelationType {
  sleepMood('睡眠-心情', '睡眠时长', '心情值'),
  sleepEnergy('睡眠-精力', '睡眠时长', '精力值'),
  stressMood('压力-心情', '压力值', '心情值'),
  exerciseMood('运动-心情', '活动数量', '心情值'),
  stressEnergy('压力-精力', '压力值', '精力值');

  final String displayName;
  final String xLabel;
  final String yLabel;

  const CorrelationType(this.displayName, this.xLabel, this.yLabel);
}

/// 相关性分析图表
class CorrelationChart extends StatefulWidget {
  final List<DiaryEntry> diaries;
  final StatsPeriod period;

  const CorrelationChart({
    super.key,
    required this.diaries,
    required this.period,
  });

  @override
  State<CorrelationChart> createState() => _CorrelationChartState();
}

class _CorrelationChartState extends State<CorrelationChart> {
  CorrelationType _selectedType = CorrelationType.sleepMood;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bubble_chart, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  '相关性分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildInfoButton(),
              ],
            ),
            const SizedBox(height: 12),
            // 相关性类型选择
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CorrelationType.values.map((type) {
                  final isSelected = type == _selectedType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = type);
                        }
                      },
                      selectedColor: Colors.deepPurple,
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // 散点图
            SizedBox(
              height: 250,
              child: _buildScatterChart(),
            ),
            const SizedBox(height: 12),
            // 相关性系数
            _buildCorrelationInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoButton() {
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 20),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('相关性分析说明'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('相关性系数(r)说明:'),
                SizedBox(height: 8),
                Text('• |r| > 0.7: 强相关'),
                Text('• 0.4 < |r| <= 0.7: 中等相关'),
                Text('• |r| <= 0.4: 弱相关'),
                SizedBox(height: 8),
                Text('• r > 0: 正相关（一个增加，另一个也增加）'),
                Text('• r < 0: 负相关（一个增加，另一个减少）'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('知道了'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScatterChart() {
    final dataPoints = _getDataPoints();

    if (dataPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.scatter_plot, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              '数据不足，无法进行相关性分析',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final xValues = dataPoints.map((p) => p.dx).toList();
    final yValues = dataPoints.map((p) => p.dy).toList();

    final minX = xValues.reduce(math.min);
    final maxX = xValues.reduce(math.max);
    final minY = yValues.reduce(math.min);
    final maxY = yValues.reduce(math.max);

    final spots = dataPoints
        .map((p) => ScatterSpot(
              p.dx,
              p.dy,
              dotPainter: FlDotCirclePainter(
                radius: 6,
                color: Colors.deepPurple.withOpacity(0.6),
                strokeWidth: 2,
                strokeColor: Colors.deepPurple,
              ),
            ))
        .toList();

    return ScatterChart(
      ScatterChartData(
        scatterSpots: spots,
        minX: minX - 0.5,
        maxX: maxX + 0.5,
        minY: minY - 0.5,
        maxY: maxY + 0.5,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              _selectedType.xLabel,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              _selectedType.yLabel,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade800,
            getTooltipItems: (touchedSpot) {
              return ScatterTooltipItem(
                '${_selectedType.xLabel}: ${touchedSpot.x.toStringAsFixed(1)}\n'
                '${_selectedType.yLabel}: ${touchedSpot.y.toStringAsFixed(1)}',
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Offset> _getDataPoints() {
    final points = <Offset>[];

    for (final diary in widget.diaries) {
      double? x;
      double? y;

      switch (_selectedType) {
        case CorrelationType.sleepMood:
          x = diary.sleepHours;
          y = diary.mood.value.toDouble();
          break;
        case CorrelationType.sleepEnergy:
          x = diary.sleepHours;
          y = diary.energyLevel?.toDouble();
          break;
        case CorrelationType.stressMood:
          x = diary.stressLevel?.toDouble();
          y = diary.mood.value.toDouble();
          break;
        case CorrelationType.exerciseMood:
          x = diary.activities.length.toDouble();
          y = diary.mood.value.toDouble();
          break;
        case CorrelationType.stressEnergy:
          x = diary.stressLevel?.toDouble();
          y = diary.energyLevel?.toDouble();
          break;
      }

      if (x != null && y != null) {
        points.add(Offset(x, y));
      }
    }

    return points;
  }

  Widget _buildCorrelationInfo() {
    final correlation = _calculateCorrelation();

    if (correlation == null) {
      return const SizedBox.shrink();
    }

    String interpretation;
    Color color;
    IconData icon;

    final absCorr = correlation.abs();
    if (absCorr > 0.7) {
      interpretation = correlation > 0 ? '强正相关' : '强负相关';
      color = Colors.green;
      icon = Icons.trending_up;
    } else if (absCorr > 0.4) {
      interpretation = correlation > 0 ? '中等正相关' : '中等负相关';
      color = Colors.orange;
      icon = correlation > 0 ? Icons.trending_up : Icons.trending_down;
    } else {
      interpretation = '弱相关';
      color = Colors.grey;
      icon = Icons.trending_flat;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '相关性系数: ${correlation.toStringAsFixed(3)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                interpretation,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '样本数: ${_getDataPoints().length}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  double? _calculateCorrelation() {
    final points = _getDataPoints();
    if (points.length < 3) return null;

    final n = points.length;
    final xValues = points.map((p) => p.dx).toList();
    final yValues = points.map((p) => p.dy).toList();

    final xMean = xValues.reduce((a, b) => a + b) / n;
    final yMean = yValues.reduce((a, b) => a + b) / n;

    double sumXY = 0;
    double sumX2 = 0;
    double sumY2 = 0;

    for (int i = 0; i < n; i++) {
      final xDiff = xValues[i] - xMean;
      final yDiff = yValues[i] - yMean;
      sumXY += xDiff * yDiff;
      sumX2 += xDiff * xDiff;
      sumY2 += yDiff * yDiff;
    }

    if (sumX2 == 0 || sumY2 == 0) return null;

    return sumXY / math.sqrt(sumX2 * sumY2);
  }
}
