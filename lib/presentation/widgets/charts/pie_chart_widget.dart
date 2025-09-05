import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final List<String> categories;
  final List<double> values;
  final String? title;
  final List<Color>? pieColors; // <<<< warna custom

  const PieChartWidget({
    super.key,
    required this.categories,
    required this.values,
    this.title,
    this.pieColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = values.fold(0.0, (a, b) => a + b);

    final defaultColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];

    final colorsToUse = pieColors ?? defaultColors;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: List.generate(categories.length, (i) {
                    final value = values[i];
                    final percent = total == 0 ? 0 : (value / total) * 100;
                    return PieChartSectionData(
                      color: colorsToUse[i % colorsToUse.length],
                      value: value,
                      title: '${percent.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: List.generate(categories.length, (i) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colorsToUse[i % colorsToUse.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(categories[i]),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
