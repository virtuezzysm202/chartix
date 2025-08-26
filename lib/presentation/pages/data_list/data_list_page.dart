import 'package:flutter/material.dart';

class DataListPage extends StatelessWidget {
  const DataListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data List")),
      body: const Center(child: Text("Daftar Data tampil di sini")),
    );
  }
}
