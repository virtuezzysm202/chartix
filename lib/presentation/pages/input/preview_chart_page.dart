import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';

class PreviewChartPage extends StatefulWidget {
  final Project project;
  final List<String> valueHeaders;

  const PreviewChartPage({
    super.key,
    required this.project,
    required this.valueHeaders,
  });

  @override
  State<PreviewChartPage> createState() => _PreviewChartPageState();
}

class _PreviewChartPageState extends State<PreviewChartPage> {
  late List<String> categories;
  late List<List<double>> values;
  late bool isSingleSeries;
  late String selectedChartType; // 'pie' or 'bar'

  @override
  void initState() {
    super.initState();

    categories = widget.project.data.map((row) => row[0]).toList();
    values = widget.project.data.map((row) {
      return row.sublist(1).map((e) => double.tryParse(e) ?? 0).toList();
    }).toList();

    isSingleSeries = values.every((v) => v.length == 1);
    selectedChartType = isSingleSeries ? 'pie' : 'bar';
  }

  @override
  Widget build(BuildContext context) {
    final valueHeaders = widget.valueHeaders;

    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Chart - ${widget.project.name}"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: selectedChartType,
              dropdownColor: Colors.blue,
              underline: const SizedBox(),
              iconEnabledColor: Colors.white,
              items: [
                if (isSingleSeries)
                  const DropdownMenuItem(
                    value: 'pie',
                    child: Text(
                      'Pie Chart',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                const DropdownMenuItem(
                  value: 'bar',
                  child: Text(
                    'Bar Chart',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedChartType = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.6,
            child: selectedChartType == 'pie'
                ? PieChartWidget(
                    categories: categories,
                    values: values.map((v) => v[0]).toList(),
                    title: "Pie Chart - ${widget.project.name}",
                  )
                : ChartWidget(
                    categories: categories,
                    values: values,
                    valueHeaders: valueHeaders,
                    title: "Bar Chart - ${widget.project.name}",
                  ),
          ),
        ),
      ),
    );
  }
}
