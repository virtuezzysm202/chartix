import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.6,
            child: ChartWidget(
              categories: categories,
              values: values,
              title: "Chart - ${project.name}",
            ),
          ),
        ),
      ),
    );
  }
}
