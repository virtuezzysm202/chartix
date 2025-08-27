import 'package:flutter/material.dart';

class InputDataPage extends StatefulWidget {
  const InputDataPage({super.key});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  // Default tabel: 2 baris x 2 kolom (Label + Data1)
  List<List<TextEditingController>> table = [
    [TextEditingController(text: "Variable 1"), TextEditingController()],
    [TextEditingController(text: "Variable 2"), TextEditingController()],
  ];

  // Header (default: Label + Data1)
  List<String> headers = ["Label", "Data 1"];

  // Tambah kolom
  void _addColumn() {
    setState(() {
      headers.add("Data ${headers.length}");
      for (var row in table) {
        row.add(TextEditingController());
      }
    });
  }

  // Hapus kolom terakhir (jangan sampai habis Label)
  void _removeColumn() {
    if (headers.length > 1) {
      setState(() {
        headers.removeLast();
        for (var row in table) {
          row.removeLast();
        }
      });
    }
  }

  // Tambah baris
  void _addRow() {
    setState(() {
      table.add(
        List.generate(headers.length, (i) {
          return TextEditingController(
            text: i == 0 ? "Variable ${table.length + 1}" : "",
          );
        }),
      );
    });
  }

  // Hapus baris terakhir (jangan sampai kosong)
  void _removeRow() {
    if (table.length > 1) {
      setState(() {
        table.removeLast();
      });
    }
  }

  // Simpan data
  void _saveTable() {
    List<List<String>> values = table
        .map((row) => row.map((c) => c.text).toList())
        .toList();
    debugPrint("Headers: $headers");
    debugPrint("Values: $values");
    // TODO: Integrasikan ke chart_page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Data"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTable),
        ],
      ),
      body: Column(
        children: [
          // seluruh tabel (header + body) dalam satu scroll horizontal
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
                      // Tombol tambah/kurang kolom
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
                            onPressed: _removeColumn,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ISI TABEL
                  ...List.generate(table.length, (rowIndex) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(table[rowIndex].length, (colIndex) {
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
                        // Tombol tambah/kurang baris hanya di akhir
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
                                onPressed: _removeRow,
                              ),
                            ],
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
