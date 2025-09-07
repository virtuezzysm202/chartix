import 'package:flutter/material.dart';
import '../../data/models/project.dart';
import '../pages/categorial/mixed_data_page.dart';

class ViewTablePage extends StatelessWidget {
  final Project project;

  const ViewTablePage({super.key, required this.project});

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MixedDataPage(project: project),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
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
                Row(
                  children: [
                    Icon(Icons.data_usage, color: Colors.purple.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${project.data.length} baris',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dibuat: ${_formatDateTime(project.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.purple.shade600),
                ),
                if (project.columnConfigs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: project.columnConfigs.map((config) {
                      Color color = _getDataTypeColor(config.dataType);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${config.name}: ${_getDataTypeLabel(config)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Tabel data
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      Colors.grey.shade100,
                    ),
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnSpacing: 20,
                    columns: project.headers.asMap().entries.map((entry) {
                      int index = entry.key;
                      String header = entry.value;
                      ColumnConfig? config =
                          index < project.columnConfigs.length
                          ? project.columnConfigs[index]
                          : null;

                      return DataColumn(
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              header,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (config != null) ...[
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDataTypeColor(config.dataType),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getDataTypeLabel(config),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    rows: project.data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return DataRow(
                        color: WidgetStateProperty.all(
                          index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                        ),
                        cells: row.asMap().entries.map((cellEntry) {
                          int colIndex = cellEntry.key;
                          String cell = cellEntry.value;

                          // Get column config to format display
                          ColumnConfig? config =
                              colIndex < project.columnConfigs.length
                              ? project.columnConfigs[colIndex]
                              : null;

                          Widget cellContent;

                          if (config?.dataType == DataType.boolean) {
                            bool boolValue = cell.toLowerCase() == 'true';
                            cellContent = Icon(
                              boolValue ? Icons.check_circle : Icons.cancel,
                              color: boolValue ? Colors.green : Colors.red,
                              size: 20,
                            );
                          } else {
                            cellContent = Text(
                              cell.isEmpty ? '-' : cell,
                              style: TextStyle(
                                color: cell.isEmpty
                                    ? Colors.grey
                                    : Colors.black,
                                fontStyle: cell.isEmpty
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            );
                          }

                          return DataCell(cellContent);
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // Summary info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.table_rows,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project.data.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Baris',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.view_column,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project.headers.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'Kolom',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.grid_on,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project.data.length * project.headers.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    Text(
                      'Total Cell',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDataTypeColor(DataType dataType) {
    switch (dataType) {
      case DataType.categorical:
        return Colors.blue;
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
