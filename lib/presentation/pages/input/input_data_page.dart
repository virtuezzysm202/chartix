import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../../core/services/storage_service.dart';

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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Buat project default
    currentProject =
        widget.project ??
        Project(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "New project",
          headers: ["Variabel", "Nilai"],
          data: [
            ["Data 1", "100"],
          ],
          createdAt: DateTime.now(),
        );

    headers = List.from(currentProject.headers);

    projectNameController = TextEditingController(text: currentProject.name);
    projectNameController.addListener(() => setState(() => _hasChanges = true));

    table = currentProject.data.map((row) {
      return row.asMap().entries.map((entry) {
        final controller = TextEditingController(text: entry.value);
        controller.addListener(() => setState(() => _hasChanges = true));
        return controller;
      }).toList();
    }).toList();
  }

  @override
  void dispose() {
    projectNameController.dispose();
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
      for (var row in table) {
        final controller = TextEditingController();
        controller.addListener(() => setState(() => _hasChanges = true));
        row.add(controller);
      }
      _hasChanges = true;
    });
  }

  void _removeColumn() {
    if (headers.length > 1) {
      setState(() {
        headers.removeLast();
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

          // Tabel
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(headers.length, (index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            headers[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                      // Tombol kolom
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_box,
                              color: Colors.green,
                            ),
                            onPressed: _addColumn,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.indeterminate_check_box,
                              color: Colors.red,
                            ),
                            onPressed: headers.length > 1
                                ? _removeColumn
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ISI TABEL
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(table.length, (rowIndex) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(table[rowIndex].length, (
                                colIndex,
                              ) {
                                return Container(
                                  width: 120,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextField(
                                    controller: table[rowIndex][colIndex],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 10,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // Tombol baris (hanya di baris terakhir)
                              if (rowIndex == table.length - 1)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_box,
                                        color: Colors.blue,
                                      ),
                                      onPressed: _addRow,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.indeterminate_check_box,
                                        color: Colors.orange,
                                      ),
                                      onPressed: table.length > 1
                                          ? _removeRow
                                          : null,
                                    ),
                                  ],
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
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
