// File: presentation/pages/categorical/categorical_preview_chart_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/project.dart';

class CategoricalPreviewChartPage extends StatefulWidget {
  final Project project;

  const CategoricalPreviewChartPage({super.key, required this.project});

  @override
  State<CategoricalPreviewChartPage> createState() =>
      _CategoricalPreviewChartPageState();
}

class _CategoricalPreviewChartPageState
    extends State<CategoricalPreviewChartPage> {
  int selectedChartType = 0; // 0: Pie Chart, 1: Bar Chart, 2: Boolean Summary

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview - ${widget.project.name}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chart type selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('Pie Chart'),
                        icon: Icon(Icons.pie_chart),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('Bar Chart'),
                        icon: Icon(Icons.bar_chart),
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text('Summary'),
                        icon: Icon(Icons.summarize),
                      ),
                    ],
                    selected: {selectedChartType},
                    onSelectionChanged: (Set<int> selection) {
                      setState(() {
                        selectedChartType = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chart display
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildSelectedChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (selectedChartType) {
      case 0:
        return _buildPieCharts();
      case 1:
        return _buildBarCharts();
      case 2:
        return _buildSummaryView();
      default:
        return _buildPieCharts();
    }
  }

  Widget _buildPieCharts() {
    List<Widget> charts = [];

    for (
      int colIndex = 0;
      colIndex < widget.project.columnConfigs.length;
      colIndex++
    ) {
      final config = widget.project.columnConfigs[colIndex];

      if (config.dataType == DataType.categorical ||
          config.dataType == DataType.boolean) {
        charts.add(_buildPieChartForColumn(colIndex, config));
        charts.add(const SizedBox(height: 32));
      }
    }

    return Column(children: charts);
  }

  Widget _buildPieChartForColumn(int columnIndex, ColumnConfig config) {
    // Count occurrences
    Map<String, int> counts = {};
    for (var row in widget.project.data) {
      if (columnIndex < row.length) {
        String value = row[columnIndex];
        if (config.dataType == DataType.boolean) {
          value = value.toLowerCase() == 'true' ? 'Yes' : 'No';
        }
        counts[value] = (counts[value] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No data available for ${config.name}'),
        ),
      );
    }

    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int colorIndex = 0;
    counts.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value.toDouble(),
          title: '$key\n($value)',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              config.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarCharts() {
    List<Widget> charts = [];

    for (
      int colIndex = 0;
      colIndex < widget.project.columnConfigs.length;
      colIndex++
    ) {
      final config = widget.project.columnConfigs[colIndex];

      if (config.dataType == DataType.categorical ||
          config.dataType == DataType.boolean) {
        charts.add(_buildBarChartForColumn(colIndex, config));
        charts.add(const SizedBox(height: 32));
      }
    }

    return Column(children: charts);
  }

  Widget _buildBarChartForColumn(int columnIndex, ColumnConfig config) {
    // Count occurrences
    Map<String, int> counts = {};
    for (var row in widget.project.data) {
      if (columnIndex < row.length) {
        String value = row[columnIndex];
        if (config.dataType == DataType.boolean) {
          value = value.toLowerCase() == 'true' ? 'Yes' : 'No';
        }
        counts[value] = (counts[value] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No data available for ${config.name}'),
        ),
      );
    }

    List<BarChartGroupData> barGroups = [];
    List<String> categories = counts.keys.toList();

    for (int i = 0; i < categories.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: counts[categories[i]]!.toDouble(),
              color: Colors.purple,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              config.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < categories.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                categories[index],
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Summary',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // General info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'General Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Project Name: ${widget.project.name}'),
                Text('Total Rows: ${widget.project.data.length}'),
                Text('Total Columns: ${widget.project.columnConfigs.length}'),
                Text(
                  'Created: ${widget.project.createdAt.toString().substring(0, 19)}',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Column analysis
        ...widget.project.columnConfigs.asMap().entries.map((entry) {
          int colIndex = entry.key;
          ColumnConfig config = entry.value;
          return _buildColumnSummary(colIndex, config);
        }).toList(),
      ],
    );
  }

  Widget _buildColumnSummary(int columnIndex, ColumnConfig config) {
    Map<String, int> counts = {};
    int totalRows = 0;
    int emptyRows = 0;

    for (var row in widget.project.data) {
      totalRows++;
      if (columnIndex < row.length) {
        String value = row[columnIndex];
        if (value.isEmpty) {
          emptyRows++;
        } else {
          if (config.dataType == DataType.boolean) {
            value = value.toLowerCase() == 'true' ? 'True' : 'False';
          }
          counts[value] = (counts[value] ?? 0) + 1;
        }
      } else {
        emptyRows++;
      }
    }

    // Create widgets list for category display
    List<Widget> categoryWidgets = [];

    if (config.dataType == DataType.boolean) {
      categoryWidgets.add(const SizedBox(height: 8));
      categoryWidgets.add(
        const Text(
          'Distribution:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );

      for (var entry in counts.entries) {
        double percentage = (entry.value / (totalRows - emptyRows)) * 100;
        categoryWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              '${entry.key}: ${entry.value} (${percentage.toStringAsFixed(1)}%)',
            ),
          ),
        );
      }
    } else if (config.dataType == DataType.categorical && counts.isNotEmpty) {
      categoryWidgets.add(const SizedBox(height: 8));
      categoryWidgets.add(
        const Text(
          'Top categories:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );

      // Sort and take top 5
      final sortedEntries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var entry in sortedEntries.take(5)) {
        double percentage = (entry.value / (totalRows - emptyRows)) * 100;
        categoryWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              '${entry.key}: ${entry.value} (${percentage.toStringAsFixed(1)}%)',
            ),
          ),
        );
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  config.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDataTypeColor(config.dataType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    config.dataType.toString().split('.').last,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text('Total entries: $totalRows'),
            Text('Empty entries: $emptyRows'),
            Text('Unique values: ${counts.length}'),

            // Add category widgets
            ...categoryWidgets,
          ],
        ),
      ),
    );
  }

  Color _getDataTypeColor(DataType dataType) {
    switch (dataType) {
      case DataType.categorical:
        return Colors.blue;
      case DataType.boolean:
        return Colors.green;
      case DataType.numeric:
        return Colors.orange;
    }
  }
}
