import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';

class PreviewChartPage extends StatelessWidget {
  final Project project;

  const PreviewChartPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final categories = project.data.map((row) => row[0]).toList();
    final values = project.data
        .map((row) => double.tryParse(row[1]) ?? 0)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Preview Chart - ${project.name}")),
      body: SingleChildScrollView(
        // ✅ biar bisa digeser kalau chart tinggi
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.6, // ✅ kasih ukuran fix
            child: ChartWidget(categories: categories, values: values),
          ),
        ),
      ),
    );
  }
}
