import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';

class ChartPage extends StatelessWidget {
  final Project project;

  const ChartPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final data = project.data;

    // Ambil kategori (nama produk)
    final categories = data.map((row) => row[0]).toList();

    // Ambil nilai stok dan penjualan sebagai list of list
    final values = data.map((row) {
      final stok = double.tryParse(row[1]) ?? 0;
      final penjualan = double.tryParse(row[2]) ?? 0;
      return [stok, penjualan];
    }).toList();

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
