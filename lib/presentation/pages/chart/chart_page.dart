import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';

class ChartPage extends StatelessWidget {
  final Project project;

  const ChartPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final data = project.data;
    final headers = project.headers;

    // Ambil kategori (kolom pertama)
    final categories = data.map((row) => row[0]).toList();

    // Ambil semua kolom nilai (kolom ke-1 sampai akhir) sebagai list of double
    final values = data.map((row) {
      return row.sublist(1).map((e) => double.tryParse(e) ?? 0).toList();
    }).toList();

    // Ambil header kolom nilai (kolom ke-1 sampai akhir)
    final valueHeaders = headers.length > 1 ? headers.sublist(1) : <String>[];

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
              valueHeaders:
                  valueHeaders, // Kirim header kolom nilai ke ChartWidget
              title: "Chart - ${project.name}",
            ),
          ),
        ),
      ),
    );
  }
}
