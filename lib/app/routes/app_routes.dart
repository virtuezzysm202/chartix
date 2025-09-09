import 'package:flutter/material.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/categorial/mixed_data_page.dart';
import '../../presentation/pages/data_list/data_list_page.dart';
import '../../presentation/pages/settings/settings_page.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String mixedData = '/mixed-data';
  static const String dataList = '/data-list';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      dashboard: (context) => const DashboardPage(),
      mixedData: (context) => const MixedDataPage(),
      dataList: (context) => const DataListPage(),
      settings: (context) => const SettingsPage(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (context) => const DashboardPage(),
          settings: settings,
        );
      case mixedData:
        return MaterialPageRoute(
          builder: (context) {
            final templateData = settings.arguments as Map<String, dynamic>?;
            return MixedDataPage(templateData: templateData);
          },
          settings: settings,
        );
      case dataList:
        return MaterialPageRoute(
          builder: (context) => const DataListPage(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (context) => const SettingsPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
