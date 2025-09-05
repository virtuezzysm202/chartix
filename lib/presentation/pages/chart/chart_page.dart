import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';

class ChartPage extends StatefulWidget {
  final Project project;

  const ChartPage({super.key, required this.project});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late List<String> categories;
  late List<List<double>> values;
  late List<String> valueHeaders;
  late bool isSingleSeries;
  late String selectedChartType; // 'pie' or 'bar'

  @override
  void initState() {
    super.initState();

    final data = widget.project.data;
    final headers = widget.project.headers;

    categories = data.map((row) => row[0]).toList();
    values = data.map((row) {
      return row.sublist(1).map((e) => double.tryParse(e) ?? 0).toList();
    }).toList();

    valueHeaders = headers.length > 1 ? headers.sublist(1) : <String>[];

    isSingleSeries = values.every((v) => v.length == 1);
    selectedChartType = isSingleSeries ? 'pie' : 'bar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chart - ${widget.project.name}"),
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
      body: SingleChildScrollView(
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
