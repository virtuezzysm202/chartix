import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';

class PreviewChartPage extends StatelessWidget {
  final Project project;
  final List<String> valueHeaders; // header kolom nilai

  const PreviewChartPage({
    super.key,
    required this.project,
    required this.valueHeaders,
  });

  @override
  Widget build(BuildContext context) {
    final categories = project.data.map((row) => row[0]).toList();

    final values = project.data.map((row) {
      return row.sublist(1).map((e) => double.tryParse(e) ?? 0).toList();
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Preview Chart - ${project.name}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.6,
            child: ChartWidget(
              categories: categories,
              values: values,
              valueHeaders: valueHeaders, // kirim header nilai ke chart
            ),
          ),
        ),
      ),
    );
  }
}
