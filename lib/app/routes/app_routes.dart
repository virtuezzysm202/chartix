// File: app/routes/app_routes.dart (Updated version)
import 'package:flutter/material.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/input/input_data_page.dart';
import '../../presentation/pages/categorial/categorical_data_page.dart';
import '../../presentation/pages/data_list/data_list_page.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String inputData = '/input-data';
  static const String categoricalData = '/categorical-data'; // New route
  static const String dataList = '/data-list';

  static Map<String, WidgetBuilder> get routes {
    return {
      dashboard: (context) => const DashboardPage(),
      inputData: (context) => const InputDataPage(),
      categoricalData: (context) => const CategoricalDataPage(), // New route
      dataList: (context) => const DataListPage(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (context) => const DashboardPage(),
          settings: settings,
        );
      case inputData:
        return MaterialPageRoute(
          builder: (context) => const InputDataPage(),
          settings: settings,
        );
      case categoricalData:
        return MaterialPageRoute(
          builder: (context) => const CategoricalDataPage(),
          settings: settings,
        );
      case dataList:
        return MaterialPageRoute(
          builder: (context) => const DataListPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
