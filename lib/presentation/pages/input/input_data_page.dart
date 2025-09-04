import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/project.dart';
import '../../../core/services/storage_service.dart';
import './preview_chart_page.dart';

class InputDataPage extends StatefulWidget {
  final Project? project;

  const InputDataPage({super.key, this.project});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  late Project currentProject;
  late List<List<TextEditingController>> table;
  late List<String> headers;
  late TextEditingController projectNameController;
  late List<TextEditingController> headerControllers;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    currentProject =
        widget.project ??
        Project(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "New project",
          headers: ["Kategori", "Nilai"],
          data: [
            ["Data 1", "100"],
          ],
          createdAt: DateTime.now(),
        );

    headers = List.from(currentProject.headers);

    projectNameController = TextEditingController(text: currentProject.name);
    projectNameController.addListener(() => setState(() => _hasChanges = true));

    headerControllers = headers.map((h) {
      final controller = TextEditingController(text: h);
      controller.addListener(() => setState(() => _hasChanges = true));
      return controller;
    }).toList();

    table = currentProject.data.map((row) {
      return row.map((cell) {
        final controller = TextEditingController(text: cell);
        controller.addListener(() => setState(() => _hasChanges = true));
        return controller;
      }).toList();
    }).toList();
  }

  @override
  void dispose() {
    projectNameController.dispose();
    for (var controller in headerControllers) {
      controller.dispose();
    }
    for (var row in table) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addColumn() {
    setState(() {
      headers.add("Data ${headers.length}");
      headerControllers.add(
        TextEditingController(text: "Data ${headers.length}")
          ..addListener(() => setState(() => _hasChanges = true)),
      );

      for (var row in table) {
        final controller = TextEditingController()
          ..addListener(() => setState(() => _hasChanges = true));
        row.add(controller);
      }
      _hasChanges = true;
    });
  }

  void _removeColumn() {
    if (headers.length > 1) {
      setState(() {
        headers.removeLast();
        headerControllers.removeLast().dispose();

        for (var row in table) {
          row.removeLast().dispose();
        }
        _hasChanges = true;
      });
    }
  }

  void _addRow() {
    setState(() {
      final newRow = List.generate(headers.length, (i) {
        final controller = TextEditingController(
          text: i == 0 ? "Variable ${table.length + 1}" : "",
        );
        controller.addListener(() => setState(() => _hasChanges = true));
        return controller;
      });
      table.add(newRow);
      _hasChanges = true;
    });
  }

  void _removeRow() {
    if (table.length > 1) {
      setState(() {
        for (var controller in table.last) {
          controller.dispose();
        }
        table.removeLast();
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveData() async {
    try {
      headers = headerControllers.map((c) => c.text).toList();

      List<List<String>> data = table
          .map((row) => row.map((c) => c.text).toList())
          .toList();

      final updatedProject = currentProject.copyWith(
        name: projectNameController.text.trim().isEmpty
            ? "Project Baru"
            : projectNameController.text.trim(),
        headers: headers,
        data: data,
      );

      await StorageService.saveProject(updatedProject);

      if (mounted) {
        setState(() {
          currentProject = updatedProject;
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectNameController.text.isEmpty
                  ? "Project Baru"
                  : projectNameController.text,
            ),
            if (_hasChanges)
              const Text(
                'Belum disimpan',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: _hasChanges ? Colors.orange : Colors.white,
            ),
            onPressed: _saveData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Field edit nama project
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Project',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: projectNameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama project',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info project
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentProject.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Text(
                  '${table.length}×${headers.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),

          // TABEL INPUT DATA
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol tambah/hapus kolom
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_box, color: Colors.green),
                        onPressed: _addColumn,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.indeterminate_check_box,
                          color: Colors.red,
                        ),
                        onPressed: headers.length > 1 ? _removeColumn : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Table header + data
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                      defaultColumnWidth: const FixedColumnWidth(120),
                      children: [
                        // HEADER
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          children: headerControllers.map((controller) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // DATA ROWS
                        ...table.map((rowControllers) {
                          return TableRow(
                            children: rowControllers.asMap().entries.map((
                              entry,
                            ) {
                              int colIndex = entry.key;
                              TextEditingController controller = entry.value;
                              bool isValueColumn = colIndex != 0;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                alignment: Alignment.centerLeft,
                                child: TextField(
                                  controller: controller,
                                  keyboardType: isValueColumn
                                      ? TextInputType.number
                                      : TextInputType.text,
                                  inputFormatters: isValueColumn
                                      ? [FilteringTextInputFormatter.digitsOnly]
                                      : [],
                                  decoration: InputDecoration(
                                    hintText: isValueColumn
                                        ? 'Masukkan angka'
                                        : 'Nama kategori',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tombol tambah/hapus baris + preview chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_box, color: Colors.blue),
                            onPressed: _addRow,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.indeterminate_check_box,
                              color: Colors.orange,
                            ),
                            onPressed: table.length > 1 ? _removeRow : null,
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Ambil data dari tabel
                          final projectData = table
                              .map((row) => row.map((c) => c.text).toList())
                              .toList();

                          final previewProject = currentProject.copyWith(
                            name: projectNameController.text,
                            headers: headers,
                            data: projectData,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PreviewChartPage(project: previewProject),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text("Preview Chart"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
