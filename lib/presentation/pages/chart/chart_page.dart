import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/project.dart';

class ChartPage extends StatelessWidget {
  final Project project;

  const ChartPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari project
    final data = project.data;

    // Convert format
    final categories = data.map((row) => row[0]).toList();
    final values = data.map((row) => double.tryParse(row[1]) ?? 0).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Chart - ${project.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(categories.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index],
                    color: Colors.blue,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < categories.length) {
                      return Text(categories[value.toInt()]);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
