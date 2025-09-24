
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/goal.dart';

class DashboardScreen extends StatelessWidget {
  final List<Goal> goals;
  const DashboardScreen({super.key, required this.goals});

  List<double> _getWeeklyProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weeklyProgress = List.filled(7, 0.0);

    for (final goal in goals) {
      for (final record in goal.progressRecords) {
        final recordDate = DateTime(record.recordedAt.year, record.recordedAt.month, record.recordedAt.day);
        final difference = today.difference(recordDate).inDays;
        if (difference >= 0 && difference < 7) {
          weeklyProgress[6 - difference]++;
        }
      }
    }
    return weeklyProgress;
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _getWeeklyProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주간 성장 기록',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weeklyData.any((d) => d > 0) ? weeklyData.reduce((a, b) => a > b ? a : b) + 2 : 10, // Dynamic max Y
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.grey, fontSize: 14);
                          String text;
                          final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          switch (day.weekday) {
                            case 1: text = '월'; break;
                            case 2: text = '화'; break;
                            case 3: text = '수'; break;
                            case 4: text = '목'; break;
                            case 5: text = '금'; break;
                            case 6: text = '토'; break;
                            case 7: text = '일'; break;
                            default: text = ''; break;
                          }
                          return Text(text, style: style);
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (index) {
                    return _makeBarGroup(index, weeklyData[index]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.black,
          width: 14,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
}
