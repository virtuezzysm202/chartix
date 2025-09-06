import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../../core/services/storage_service.dart';
import './categorical_preview_chart_page.dart';

class CategoricalDataPage extends StatefulWidget {
  final Project? project;

  const CategoricalDataPage({super.key, this.project});

  @override
  State<CategoricalDataPage> createState() => _CategoricalDataPageState();
}

class _CategoricalDataPageState extends State<CategoricalDataPage> {
  late Project currentProject;
  late List<List<dynamic>> table; // Changed to dynamic for mixed data types
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
          name: "New Categorical Project",
          headers: ["Name", "Category", "Active", "Description"],
          data: [
            ["Item 1", "Type A", "true", "Sample description"],
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
            const ColumnConfig(
              name: "Description",
              dataType: DataType.categorical,
            ), // Using categorical for text-like fields
          ],
        );

    columnConfigs = List.from(currentProject.columnConfigs);
    if (columnConfigs.isEmpty) {
      // Initialize default column configs if empty
      columnConfigs = currentProject.headers.map((header) {
        if (header.toLowerCase().contains('active') ||
            header.toLowerCase().contains('enabled') ||
            header.toLowerCase().contains('status')) {
          return ColumnConfig(name: header, dataType: DataType.boolean);
        }
        // All text-like fields will use categorical without predefined options
        return ColumnConfig(name: header, dataType: DataType.categorical);
      }).toList();
    }

    projectNameController = TextEditingController(text: currentProject.name);
    projectNameController.addListener(() => setState(() => _hasChanges = true));

    // Initialize table data
    table = currentProject.data.map((row) {
      return row.asMap().entries.map((entry) {
        int index = entry.key;
        String value = entry.value;

        if (index < columnConfigs.length) {
          if (columnConfigs[index].dataType == DataType.boolean) {
            return value.toLowerCase() == 'true';
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

  void _addColumn() {
    setState(() {
      String newColumnName = "Column ${columnConfigs.length + 1}";
      columnConfigs.add(
        ColumnConfig(
          name: newColumnName,
          dataType: DataType.categorical,
        ), // Default to categorical
      );

      // Add to table data
      for (var row in table) {
        row.add("");
      }
      _hasChanges = true;
    });
  }

  void _removeColumn() {
    if (columnConfigs.length > 1) {
      setState(() {
        columnConfigs.removeLast();
        for (var row in table) {
          row.removeLast();
        }
        _hasChanges = true;
      });
    }
  }

  void _addRow() {
    setState(() {
      final newRow = List.generate(columnConfigs.length, (i) {
        if (columnConfigs[i].dataType == DataType.boolean) {
          return false;
        }
        return i == 0 ? "Item ${table.length + 1}" : "";
      });
      table.add(newRow);
      _hasChanges = true;
    });
  }

  void _removeRow() {
    if (table.length > 1) {
      setState(() {
        table.removeLast();
        _hasChanges = true;
      });
    }
  }

  void _updateColumnConfig(int index, ColumnConfig newConfig) {
    setState(() {
      columnConfigs[index] = newConfig;

      // Convert existing data if data type changed
      for (var row in table) {
        if (index < row.length) {
          if (newConfig.dataType == DataType.boolean) {
            if (row[index] is String) {
              row[index] = (row[index] as String).toLowerCase() == 'true';
            }
          } else {
            if (row[index] is bool) {
              row[index] = (row[index] as bool).toString();
            }
          }
        }
      }
      _hasChanges = true;
    });
  }

  Future<void> _saveData() async {
    try {
      // Convert table data to strings for storage
      List<List<String>> stringData = table.map((row) {
        return row.asMap().entries.map((entry) {
          int index = entry.key;
          dynamic value = entry.value;

          if (index < columnConfigs.length &&
              columnConfigs[index].dataType == DataType.boolean) {
            return (value as bool).toString();
          }
          return value.toString();
        }).toList();
      }).toList();

      final updatedProject = currentProject.copyWith(
        name: projectNameController.text.trim().isEmpty
            ? "Categorical Project"
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildCell(int rowIndex, int colIndex) {
    if (colIndex >= columnConfigs.length) return const SizedBox();

    final config = columnConfigs[colIndex];
    final value = table[rowIndex][colIndex];

    switch (config.dataType) {
      case DataType.boolean:
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Checkbox(
            value: value as bool,
            onChanged: (newValue) {
              setState(() {
                table[rowIndex][colIndex] = newValue ?? false;
                _hasChanges = true;
              });
            },
          ),
        );

      case DataType.categorical:
        if (config.categoryOptions != null &&
            config.categoryOptions!.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DropdownButtonFormField<String>(
              initialValue: config.categoryOptions!.contains(value)
                  ? value as String
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
            ),
          );
        } else {
          // For categorical without predefined options, allow free text input (acts like text field)
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextFormField(
              initialValue: value.toString(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              maxLines: null, // Allow multiple lines
              keyboardType: TextInputType.multiline,
              onChanged: (newValue) {
                setState(() {
                  table[rowIndex][colIndex] = newValue;
                  _hasChanges = true;
                });
              },
            ),
          );
        }

      case DataType.numeric:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (newValue) {
              setState(() {
                table[rowIndex][colIndex] = newValue;
                _hasChanges = true;
              });
            },
          ),
        );
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
                  initialValue: selectedDataType,
                  decoration: const InputDecoration(
                    labelText: 'Data Type',
                    border: OutlineInputBorder(),
                  ),
                  items: DataType.values.map((type) {
                    String displayName = type.toString().split('.').last;
                    // Show "text" label for categorical without options
                    if (type == DataType.categorical &&
                        (config.categoryOptions == null ||
                            config.categoryOptions!.isEmpty)) {
                      displayName += " (text)";
                    }
                    return DropdownMenuItem(
                      value: type,
                      child: Text(displayName),
                    );
                  }).toList(),
                  onChanged: (newType) {
                    setDialogState(() {
                      selectedDataType = newType!;
                    });
                  },
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
                        onPressed: () {
                          setDialogState(() {
                            categoryOptions.remove(option);
                          });
                        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectNameController.text.isEmpty
                  ? "Categorical Project"
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
                const Icon(Icons.category, color: Colors.purple),
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
                      IconButton(
                        icon: const Icon(
                          Icons.indeterminate_check_box,
                          color: Colors.red,
                        ),
                        onPressed: columnConfigs.length > 1
                            ? _removeColumn
                            : null,
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
                          children: columnConfigs.asMap().entries.map((entry) {
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
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getDataTypeColor(config),
                                        borderRadius: BorderRadius.circular(10),
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
                          }).toList(),
                        ),

                        // Data rows
                        ...table.asMap().entries.map((rowEntry) {
                          int rowIndex = rowEntry.key;
                          return TableRow(
                            children: columnConfigs.asMap().entries.map((
                              colEntry,
                            ) {
                              int colIndex = colEntry.key;
                              return _buildCell(rowIndex, colIndex);
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Row controls and preview
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
                          // Convert table data for preview
                          final stringData = table.map((row) {
                            return row.asMap().entries.map((entry) {
                              int index = entry.key;
                              dynamic value = entry.value;

                              if (index < columnConfigs.length &&
                                  columnConfigs[index].dataType ==
                                      DataType.boolean) {
                                return (value as bool).toString();
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.pie_chart),
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

  Color _getDataTypeColor(ColumnConfig config) {
    switch (config.dataType) {
      case DataType.categorical:
        // Different colors for categorical with/without options
        if (config.categoryOptions != null &&
            config.categoryOptions!.isNotEmpty) {
          return Colors.blue; // Categorical with dropdown
        } else {
          return Colors.purple; // Categorical as text
        }
      case DataType.boolean:
        return Colors.green;
      case DataType.numeric:
        return Colors.orange;
    }
  }

  String _getDataTypeLabel(ColumnConfig config) {
    switch (config.dataType) {
      case DataType.categorical:
        if (config.categoryOptions != null &&
            config.categoryOptions!.isNotEmpty) {
          return 'categorical';
        } else {
          return 'text';
        }
      case DataType.boolean:
        return 'boolean';
      case DataType.numeric:
        return 'numeric';
    }
  }
}
