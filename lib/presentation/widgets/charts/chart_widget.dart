import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final List<String> categories;
  final List<List<double>> values;
  final String? title;
  final Color? primaryColor;
  final List<String>? valueHeaders; // header kolom nilai
  final List<Color>? barColors; // warna bar custom

  const ChartWidget({
    super.key,
    required this.categories,
    required this.values,
    this.title,
    this.primaryColor,
    this.valueHeaders,
    this.barColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartColor = primaryColor ?? theme.primaryColor;

    final maxValue = values.isNotEmpty
        ? values.expand((list) => list).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final roundedMax = maxValue > 0
        ? ((maxValue * 1.2 / 10).ceil() * 10).toDouble()
        : 10.0;

    final defaultBarColors = [
      chartColor,
      Colors.redAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    final colorsToUse = barColors ?? defaultBarColors;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            if (valueHeaders != null) ...[
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: List.generate(valueHeaders!.length, (i) {
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
                      Text(valueHeaders![i]),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],

            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: roundedMax,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = categories[group.x.toInt()];
                        String barLabel =
                            valueHeaders != null &&
                                rodIndex < valueHeaders!.length
                            ? valueHeaders![rodIndex]
                            : 'Value ${rodIndex + 1}';
                        return BarTooltipItem(
                          '$label\n$barLabel: ${rod.toY.toStringAsFixed(1)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: roundedMax / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                  ),
                  barGroups: List.generate(categories.length, (index) {
                    final rods = <BarChartRodData>[];
                    for (int i = 0; i < values[index].length; i++) {
                      rods.add(
                        BarChartRodData(
                          toY: values[index][i],
                          color: colorsToUse[i % colorsToUse.length],
                          width: 16,
                          borderRadius: BorderRadius.zero, // no curve, kaku
                        ),
                      );
                    }
                    return BarChartGroupData(
                      x: index,
                      barRods: rods,
                      barsSpace: 6,
                    );
                  }),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: roundedMax / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < categories.length) {
                            String label = categories[value.toInt()];
                            if (label.length > 6) {
                              label = '${label.substring(0, 4)}..';
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
