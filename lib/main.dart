import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/data_list/data_list_page.dart';
import 'presentation/pages/create_project_page.dart';
import 'presentation/pages/categorial/mixed_data_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/pin_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedPin = prefs.getString('app_pin') ?? '';
  runApp(MyApp(initialPin: savedPin));
}

class MyApp extends StatelessWidget {
  final String initialPin; // ✅ PIN tersimpan
  const MyApp({super.key, required this.initialPin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chartix - Data Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: initialPin.isNotEmpty
          ? const PinLoginPage()
          : const DashboardPage(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/data-list': (context) => const DataListPage(),
        '/create-project': (context) => const CreateProjectPage(),
        '/mixed-data': (context) => const MixedDataPage(),
        '/settings': (context) => const SettingsPage(),
        '/pin-login': (context) => const PinLoginPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
