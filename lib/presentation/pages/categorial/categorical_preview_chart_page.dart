import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../data/models/project.dart';
import '../../widgets/charts/chart_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';

class CategoricalPreviewChartPage extends StatefulWidget {
  final Project project;

  const CategoricalPreviewChartPage({super.key, required this.project});

  @override
  State<CategoricalPreviewChartPage> createState() =>
      _CategoricalPreviewChartPageState();
}

class _CategoricalPreviewChartPageState
    extends State<CategoricalPreviewChartPage> {
  late List<String> categories;
  late List<List<double>> values;
  late List<String> valueHeaders;
  late bool isSingleSeries;
  late String selectedChartType;

  late List<Color> userBarColors;
  late List<Color> userPieColors;

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

    userBarColors = List.generate(
      valueHeaders.length,
      (index) => Colors.primaries[index % Colors.primaries.length],
    );
    userPieColors = List.generate(
      categories.length,
      (index) => Colors.primaries[index % Colors.primaries.length],
    );
  }

  void pickColor({
    required int index,
    required List<Color> colorList,
    required String label,
  }) {
    Color currentColor = colorList[index];

    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: Text('Pilih warna untuk $label'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => tempColor = color,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Pilih'),
              onPressed: () {
                setState(() {
                  colorList[index] = tempColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview - ${widget.project.name}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(
                value: selectedChartType,
                underline: const SizedBox(),
                items: [
                  if (isSingleSeries)
                    const DropdownMenuItem(
                      value: 'pie',
                      child: Text('Pie Chart'),
                    ),
                  const DropdownMenuItem(
                    value: 'bar',
                    child: Text('Bar Chart'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedChartType = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Warna
            if (selectedChartType == 'bar' && valueHeaders.isNotEmpty)
              Wrap(
                spacing: 12,
                children: List.generate(valueHeaders.length, (index) {
                  return GestureDetector(
                    onTap: () => pickColor(
                      index: index,
                      colorList: userBarColors,
                      label: valueHeaders[index],
                    ),
                    child: Chip(
                      backgroundColor: userBarColors[index],
                      label: Text(
                        valueHeaders[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            if (selectedChartType == 'pie' && categories.isNotEmpty)
              Wrap(
                spacing: 12,
                children: List.generate(categories.length, (index) {
                  return GestureDetector(
                    onTap: () => pickColor(
                      index: index,
                      colorList: userPieColors,
                      label: categories[index],
                    ),
                    child: Chip(
                      backgroundColor: userPieColors[index],
                      label: Text(
                        categories[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }),
              ),

            const SizedBox(height: 16),

            // Chart preview
            AspectRatio(
              aspectRatio: 1.6,
              child: selectedChartType == 'pie'
                  ? PieChartWidget(
                      categories: categories,
                      values: values.map((v) => v[0]).toList(),
                      pieColors: userPieColors,
                      title: "Pie Chart - ${widget.project.name}",
                    )
                  : ChartWidget(
                      categories: categories,
                      values: values,
                      valueHeaders: valueHeaders,
                      barColors: userBarColors,
                      title: "Bar Chart - ${widget.project.name}",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
