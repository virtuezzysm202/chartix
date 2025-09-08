import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../../core/services/storage_service.dart';
import './categorical_preview_chart_page.dart';

class MixedDataPage extends StatefulWidget {
  final Project? project;
  final Map<String, dynamic>? templateData;

  const MixedDataPage({super.key, this.project, this.templateData});

  @override
  State<MixedDataPage> createState() => _MixedDataPageState();
}

class _MixedDataPageState extends State<MixedDataPage> {
  late Project currentProject;
  late List<List<dynamic>> table;
  late List<ColumnConfig> columnConfigs;
  late TextEditingController projectNameController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    currentProject =
        widget.project ??
        Project(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "New Mixed Data Project",
          headers: [
            "Name",
            "Category",
            "Active",
            "Score",
            "Date",
            "Description",
          ],
          data: [
            [
              "Item 1",
              "Type A",
              "true",
              "85",
              "2024-01-15",
              "Sample description",
            ],
          ],
          createdAt: DateTime.now(),
          columnConfigs: [
            const ColumnConfig(name: "Name", dataType: DataType.categorical),
            const ColumnConfig(
              name: "Category",
              dataType: DataType.categorical,
              categoryOptions: ["Type A", "Type B", "Type C"],
            ),
            const ColumnConfig(name: "Active", dataType: DataType.boolean),
            const ColumnConfig(name: "Score", dataType: DataType.numeric),
            const ColumnConfig(name: "Date", dataType: DataType.categorical),
            const ColumnConfig(
              name: "Description",
              dataType: DataType.categorical,
            ),
          ],
        );

    columnConfigs = List.from(currentProject.columnConfigs);
    if (columnConfigs.isEmpty) {
      columnConfigs = currentProject.headers.map((header) {
        if (header.toLowerCase().contains('active') ||
            header.toLowerCase().contains('enabled') ||
            header.toLowerCase().contains('status')) {
          return ColumnConfig(name: header, dataType: DataType.boolean);
        } else if (header.toLowerCase().contains('score') ||
            header.toLowerCase().contains('price') ||
            header.toLowerCase().contains('amount') ||
            header.toLowerCase().contains('count')) {
          return ColumnConfig(name: header, dataType: DataType.numeric);
        }
        return ColumnConfig(name: header, dataType: DataType.categorical);
      }).toList();
    }

    projectNameController = TextEditingController(text: currentProject.name);
    projectNameController.addListener(() => setState(() => _hasChanges = true));

    table = currentProject.data.map((row) {
      return row.asMap().entries.map((entry) {
        int index = entry.key;
        String value = entry.value;

        if (index < columnConfigs.length) {
          if (columnConfigs[index].dataType == DataType.boolean) {
            return value.toLowerCase() == 'true';
          } else if (columnConfigs[index].dataType == DataType.numeric) {
            return double.tryParse(value) ?? 0.0;
          }
          if (_isDateColumn(columnConfigs[index].name)) {
            return DateTime.tryParse(value) ?? DateTime.now();
          }
        }
        return value;
      }).toList();
    }).toList();
  }

  @override
  void dispose() {
    projectNameController.dispose();
    super.dispose();
  }

  bool _isDateColumn(String columnName) {
    return columnName.toLowerCase().contains('date') ||
        columnName.toLowerCase().contains('time') ||
        columnName.toLowerCase().contains('created') ||
        columnName.toLowerCase().contains('updated');
  }

  void _addColumn() {
    setState(() {
      String newColumnName = "Column ${columnConfigs.length + 1}";
      columnConfigs.add(
        ColumnConfig(name: newColumnName, dataType: DataType.categorical),
      );
      for (var row in table) row.add("");
      _hasChanges = true;
    });
  }

  void _addRow() {
    setState(() {
      final newRow = List.generate(columnConfigs.length, (i) {
        if (columnConfigs[i].dataType == DataType.boolean) return false;
        if (columnConfigs[i].dataType == DataType.numeric) return 0.0;
        if (_isDateColumn(columnConfigs[i].name)) return DateTime.now();
        return i == 0 ? "Item ${table.length + 1}" : "";
      });
      table.add(newRow);
      _hasChanges = true;
    });
  }

  void _showDeleteRowDialog(int rowIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Row'),
        content: Text('Are you sure you want to delete row ${rowIndex + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                table.removeAt(rowIndex);
                _hasChanges = true;
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateColumnConfig(int index, ColumnConfig newConfig) {
    setState(() {
      columnConfigs[index] = newConfig;
      for (var row in table) {
        if (index < row.length) {
          if (newConfig.dataType == DataType.boolean) {
            if (row[index] is String)
              row[index] = row[index].toLowerCase() == 'true';
            else if (row[index] is num)
              row[index] = (row[index] as num) > 0;
          } else if (newConfig.dataType == DataType.numeric) {
            if (row[index] is String)
              row[index] = double.tryParse(row[index] as String) ?? 0.0;
            else if (row[index] is bool)
              row[index] = (row[index] as bool) ? 1.0 : 0.0;
          } else {
            if (row[index] is bool)
              row[index] = (row[index] as bool).toString();
            else if (row[index] is num)
              row[index] = row[index].toString();
            else if (row[index] is DateTime && !_isDateColumn(newConfig.name)) {
              row[index] = (row[index] as DateTime).toIso8601String().split(
                'T',
              )[0];
            }
          }
        }
      }
      _hasChanges = true;
    });
  }

  Future<void> _saveData() async {
    try {
      List<List<String>> stringData = table.map((row) {
        return row.asMap().entries.map((entry) {
          int index = entry.key;
          dynamic value = entry.value;
          if (index < columnConfigs.length) {
            if (columnConfigs[index].dataType == DataType.boolean)
              return (value as bool).toString();
            if (columnConfigs[index].dataType == DataType.numeric)
              return (value as num).toString();
            if (_isDateColumn(columnConfigs[index].name) && value is DateTime)
              return value.toIso8601String().split('T')[0];
          }
          return value.toString();
        }).toList();
      }).toList();

      final updatedProject = currentProject.copyWith(
        name: projectNameController.text.trim().isEmpty
            ? "Mixed Data Project"
            : projectNameController.text.trim(),
        headers: columnConfigs.map((c) => c.name).toList(),
        data: stringData,
        columnConfigs: columnConfigs,
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
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _selectDate(int rowIndex, int colIndex) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: table[rowIndex][colIndex] is DateTime
          ? table[rowIndex][colIndex]
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        table[rowIndex][colIndex] = picked;
        _hasChanges = true;
      });
    }
  }

  Widget _buildCell(int rowIndex, int colIndex) {
    if (colIndex >= columnConfigs.length) return const SizedBox();
    final config = columnConfigs[colIndex];
    final value = table[rowIndex][colIndex];

    if (_isDateColumn(config.name)) {
      return InkWell(
        onTap: () => _selectDate(rowIndex, colIndex),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                value is DateTime
                    ? "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}"
                    : value.toString(),
              ),
            ],
          ),
        ),
      );
    }

    switch (config.dataType) {
      case DataType.boolean:
        return Checkbox(
          value: value as bool,
          onChanged: (newValue) {
            setState(() {
              table[rowIndex][colIndex] = newValue ?? false;
              _hasChanges = true;
            });
          },
        );
      case DataType.numeric:
        return TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: (newValue) {
            setState(() {
              table[rowIndex][colIndex] = double.tryParse(newValue) ?? 0.0;
              _hasChanges = true;
            });
          },
        );
      case DataType.categorical:
        if (config.categoryOptions != null &&
            config.categoryOptions!.isNotEmpty) {
          return DropdownButtonFormField<String>(
            value: config.categoryOptions!.contains(value.toString())
                ? value.toString()
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            items: config.categoryOptions!.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                table[rowIndex][colIndex] = newValue ?? "";
                _hasChanges = true;
              });
            },
          );
        } else {
          return TextFormField(
            initialValue: value.toString(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onChanged: (newValue) {
              setState(() {
                table[rowIndex][colIndex] = newValue;
                _hasChanges = true;
              });
            },
          );
        }
    }
  }

  void _showColumnConfigDialog(int columnIndex) {
    final config = columnConfigs[columnIndex];
    DataType selectedDataType = config.dataType;
    TextEditingController nameController = TextEditingController(
      text: config.name,
    );
    List<String> categoryOptions = List.from(config.categoryOptions ?? []);
    TextEditingController newOptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Configure Column ${columnIndex + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Column Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DataType>(
                  value: selectedDataType,
                  decoration: const InputDecoration(
                    labelText: 'Data Type',
                    border: OutlineInputBorder(),
                  ),
                  items: DataType.values.map((type) {
                    String displayName = type.toString().split('.').last;
                    if (type == DataType.categorical &&
                        (config.categoryOptions == null ||
                            config.categoryOptions!.isEmpty))
                      displayName += " (text)";
                    return DropdownMenuItem(
                      value: type,
                      child: Text(displayName),
                    );
                  }).toList(),
                  onChanged: (newType) =>
                      setDialogState(() => selectedDataType = newType!),
                ),
                if (selectedDataType == DataType.categorical) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Category Options (leave empty for free text):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...categoryOptions.map(
                    (option) => ListTile(
                      title: Text(option),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setDialogState(
                          () => categoryOptions.remove(option),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newOptionController,
                          decoration: const InputDecoration(
                            hintText: 'New option',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (newOptionController.text.isNotEmpty) {
                            setDialogState(() {
                              categoryOptions.add(newOptionController.text);
                              newOptionController.clear();
                            });
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (categoryOptions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'No options = Free text input',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (columnConfigs.length > 1)
              TextButton(
                onPressed: () {
                  // Konfirmasi delete kolom
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Column'),
                      content: Text(
                        'Are you sure you want to delete column "${config.name}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // tutup konfirmasi
                            setState(() {
                              columnConfigs.removeAt(columnIndex);
                              for (var row in table) row.removeAt(columnIndex);
                              _hasChanges = true;
                            });
                            Navigator.pop(context); // tutup dialog configure
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Delete Column',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () {
                final newConfig = ColumnConfig(
                  name: nameController.text,
                  dataType: selectedDataType,
                  categoryOptions: selectedDataType == DataType.categorical
                      ? (categoryOptions.isEmpty ? null : categoryOptions)
                      : null,
                );
                _updateColumnConfig(columnIndex, newConfig);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDataTypeColor(ColumnConfig config) {
    switch (config.dataType) {
      case DataType.categorical:
        if (_isDateColumn(config.name)) return Colors.teal;
        if (config.categoryOptions != null &&
            config.categoryOptions!.isNotEmpty)
          return Colors.blue;
        return Colors.purple;
      case DataType.boolean:
        return Colors.green;
      case DataType.numeric:
        return Colors.orange;
    }
  }

  String _getDataTypeLabel(ColumnConfig config) {
    switch (config.dataType) {
      case DataType.categorical:
        if (_isDateColumn(config.name)) return 'date';
        if (config.categoryOptions != null &&
            config.categoryOptions!.isNotEmpty)
          return 'categorical';
        return 'text';
      case DataType.boolean:
        return 'boolean';
      case DataType.numeric:
        return 'numeric';
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
                  ? "Mixed Data Project"
                  : projectNameController.text,
            ),
            if (_hasChanges)
              const Text(
                'Belum disimpan',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
          ],
        ),
        backgroundColor: Colors.purple,
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
          // Project name field
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

          // Project info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.data_usage, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentProject.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                ),
                Text(
                  '${table.length}×${columnConfigs.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.purple),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column controls
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_box, color: Colors.green),
                        onPressed: _addColumn,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Table
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                      defaultColumnWidth: const FixedColumnWidth(150),
                      children: [
                        // Header
                        TableRow(
                          decoration: BoxDecoration(color: Colors.purple[100]),
                          children: [
                            // Row number header
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  '#',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            ...columnConfigs.asMap().entries.map((entry) {
                              int index = entry.key;
                              ColumnConfig config = entry.value;
                              return GestureDetector(
                                onTap: () => _showColumnConfigDialog(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Text(
                                        config.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getDataTypeColor(config),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          _getDataTypeLabel(config),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),

                        // Data rows
                        ...table.asMap().entries.map((rowEntry) {
                          int rowIndex = rowEntry.key;
                          return TableRow(
                            children: [
                              // Row number with options
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Row ${rowIndex + 1} options',
                                      ),
                                      content: const Text(
                                        'Choose an action for this row.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _showDeleteRowDialog(rowIndex);
                                          },
                                          child: const Text(
                                            'Delete Row',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  child: Text('${rowIndex + 1}'),
                                ),
                              ),
                              ...columnConfigs.asMap().entries.map(
                                (colEntry) =>
                                    _buildCell(rowIndex, colEntry.key),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_box, color: Colors.blue),
                        onPressed: _addRow,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          final stringData = table.map((row) {
                            return row.asMap().entries.map((entry) {
                              int index = entry.key;
                              dynamic value = entry.value;
                              if (index < columnConfigs.length) {
                                if (columnConfigs[index].dataType ==
                                    DataType.boolean)
                                  return (value as bool).toString();
                                if (columnConfigs[index].dataType ==
                                    DataType.numeric)
                                  return (value as num).toString();
                                if (_isDateColumn(columnConfigs[index].name) &&
                                    value is DateTime)
                                  return value.toIso8601String().split('T')[0];
                              }
                              return value.toString();
                            }).toList();
                          }).toList();

                          final previewProject = currentProject.copyWith(
                            name: projectNameController.text,
                            headers: columnConfigs.map((c) => c.name).toList(),
                            data: stringData,
                            columnConfigs: columnConfigs,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoricalPreviewChartPage(
                                project: previewProject,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.pie_chart),
                        label: const Text("Preview Chart"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
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
