import 'package:flutter/material.dart';

class InputDataPage extends StatefulWidget {
  const InputDataPage({super.key});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  // Default table 2x2
  List<List<TextEditingController>> table = [
    [TextEditingController(), TextEditingController()],
    [TextEditingController(), TextEditingController()],
  ];

  // Method for adding a new row
  void _addRow() {
    setState(() {
      table.add(List.generate(table[0].length, (_) => TextEditingController()));
    });
  }

  // Method for adding a new column
  void _addColumn() {
    setState(() {
      for (var row in table) {
        row.add(TextEditingController());
      }
    });
  }

  // Method for saving the table data
  void _saveTable() async {
    final fileNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Simpan Data"),
        content: TextField(
          controller: fileNameController,
          decoration: const InputDecoration(labelText: "Nama File"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              // Gather table contents
              List<List<String>> values = table
                  .map((row) => row.map((c) => c.text).toList())
                  .toList();

              debugPrint("Simpan ke file: ${fileNameController.text}");
              debugPrint("Isi tabel: $values");

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Data (Mirip Excel)"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTable),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // semua baris tabel
                  ...List.generate(table.length, (rowIndex) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // semua kolom di baris ini
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

                        // tombol tambah kolom hanya di baris terakhir
                        if (rowIndex == table.length - 1)
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                            ),
                            onPressed: _addColumn,
                          ),
                      ],
                    );
                  }),

                  // tombol tambah baris di bawah tabel
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: _addRow,
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
