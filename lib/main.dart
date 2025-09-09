import 'package:flutter/material.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/data_list/data_list_page.dart';
import 'presentation/pages/create_project_page.dart';
import 'presentation/pages/categorial/mixed_data_page.dart';
import 'presentation/pages/settings/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chartix - Data Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/data-list': (context) => const DataListPage(),
        '/create-project': (context) => const CreateProjectPage(),
        '/mixed-data': (context) => const MixedDataPage(),
        '/settings': (context) => const SettingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
