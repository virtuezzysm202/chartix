import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/data_list/data_list_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chartix',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: AppRoutes.dashboard,
      routes: {
        AppRoutes.dashboard: (context) => const DashboardPage(),
        AppRoutes.dataList: (context) => const DataListPage(),
      },
    );
  }
}
