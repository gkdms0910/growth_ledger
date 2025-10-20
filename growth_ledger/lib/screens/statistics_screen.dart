import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:growth_ledger/models/goal.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Goal> goals;

  const StatisticsScreen({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 달성 현황'),
      ),
      body: goals.isEmpty
          ? const Center(
              child: Text('아직 목표가 없습니다. 목표를 추가하고 통계를 확인해보세요!'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '카테고리별 목표 분포',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildCategoryPieChart(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '최근 5개 목표 진행률',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildGoalProgressBarChart(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryPieChart() {
    if (goals.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final Map<String, int> categoryCounts = {};
    for (var goal in goals) {
      categoryCounts[goal.category] = (categoryCounts[goal.category] ?? 0) + 1;
    }

    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
    ];
    int colorIndex = 0;

    categoryCounts.forEach((category, count) {
      const double fontSize = 14.0;
      const double radius = 50.0;
      final double percentage = (count / goals.length) * 100;

      final section = PieChartSectionData(
        color: colors[colorIndex % colors.length],
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%\n$category',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
      sections.add(section);
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildGoalProgressBarChart() {
    final recentGoals = goals.length > 5 ? goals.sublist(goals.length - 5) : goals;

    if (recentGoals.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < recentGoals.length; i++) {
      final goal = recentGoals[i];
      final completedTasks = goal.subTasks.where((task) => task['isCompleted'] == true).length;
      final totalTasks = goal.subTasks.length;
      final progressPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

      final barGroup = BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: progressPercentage,
            color: Colors.lightBlue,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
      barGroups.add(barGroup);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < recentGoals.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4.0,
                    child: Text(
                      recentGoals[index].title,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        gridData: const FlGridData(show: false),
      ),
    );
  }
}
