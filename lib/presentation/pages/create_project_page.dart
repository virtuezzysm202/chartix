import 'package:flutter/material.dart';
import '../../data/models/project.dart';
import '../../core/services/storage_service.dart';
import '../pages/categorial/mixed_data_page.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama project tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
        headers: ["Name", "Category", "Active", "Score"],
        data: [
          ["Item 1", "Type A", "true", "85"],
          ["Item 2", "Type B", "false", "72"],
        ],
        columnConfigs: [
          const ColumnConfig(name: "Name", dataType: DataType.categorical),
          const ColumnConfig(
            name: "Category",
            dataType: DataType.categorical,
            categoryOptions: ["Type A", "Type B", "Type C"],
          ),
          const ColumnConfig(name: "Active", dataType: DataType.boolean),
          const ColumnConfig(name: "Score", dataType: DataType.numeric),
        ],
      );

      await StorageService.saveProject(project);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MixedDataPage(project: project),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text('Buat Project Baru'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.create_new_folder, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            const Text(
              'Nama Project',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama project...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ Default Setup:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text('• 4 kolom: Name, Category, Active, Score'),
                  Text('• 2 baris sample data'),
                  Text('• Mixed data types: text, dropdown, boolean, numeric'),
                  Text('• Bisa dikustomisasi sepenuhnya nanti'),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _createProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Buat Project', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
