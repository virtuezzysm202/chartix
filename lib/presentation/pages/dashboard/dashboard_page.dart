import 'package:flutter/material.dart';
import '../../../app/routes/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final quickActions = [
      {
        "title": "Numeric Data",
        "icon": Icons.edit_document,
        "route": AppRoutes.inputData,
        "color": Colors.blue,
      },
      {
        "title": "Categorical Data",
        "icon": Icons.category,
        "route": AppRoutes.categoricalData,
        "color": Colors.purple,
      },
      {
        "title": "Data List",
        "icon": Icons.list_alt,
        "route": AppRoutes.dataList,
        "color": Colors.teal,
      },
      {
        "title": "Settings",
        "icon": Icons.settings,
        "route": "/settings",
        "color": Colors.grey,
      },
    ];

    final dataTypes = [
      {
        "title": "Numeric",
        "description": "Numbers, calculations, measurements",
        "icon": Icons.numbers,
        "color": Colors.blue,
        "route": AppRoutes.inputData,
      },
      {
        "title": "Categorical",
        "description": "Categories, text labels, classifications",
        "icon": Icons.category,
        "color": Colors.purple,
        "route": AppRoutes.categoricalData,
      },
      {
        "title": "Boolean",
        "description": "True/false, yes/no, checkboxes",
        "icon": Icons.check_box,
        "color": Colors.green,
        "route": AppRoutes.categoricalData,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            //  HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, User 👋",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Welcome back!", style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  BANNER / HERO
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Multi-Type Data Hub",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create, manage and visualize numeric, categorical, and boolean datasets",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.inputData,
                                  ),
                                  icon: const Icon(Icons.numbers),
                                  label: const Text("Numeric"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.categoricalData,
                                  ),
                                  icon: const Icon(Icons.category),
                                  label: const Text("Categorical"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade100,
                                    foregroundColor: Colors.purple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  QUICK ACTIONS
                    Text(
                      "Quick Actions",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: quickActions.map((item) {
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            item["route"] as String,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: (item["color"] as Color).withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: (item["color"] as Color).withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: item["color"] as Color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item["title"] as String,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    //  DATA TYPES
                    Text(
                      "Data Types",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dataTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final dataType = dataTypes[index];
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              dataType["route"] as String,
                            ),
                            child: Container(
                              width: 180,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (dataType["color"] as Color)
                                      .withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: (dataType["color"] as Color)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      dataType["icon"] as IconData,
                                      color: dataType["color"] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    dataType["title"] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: dataType["color"] as Color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dataType["description"] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  RECENT DATA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Projects",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.dataList),
                          child: const Text("View All"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final projectTypes = [
                          "Numeric",
                          "Categorical",
                          "Mixed",
                        ];
                        final projectIcons = [
                          Icons.numbers,
                          Icons.category,
                          Icons.dataset,
                        ];
                        final projectColors = [
                          Colors.blue,
                          Colors.purple,
                          Colors.teal,
                        ];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: projectColors[index % 3]
                                  .withOpacity(0.1),
                              child: Icon(
                                projectIcons[index % 3],
                                color: projectColors[index % 3],
                              ),
                            ),
                            title: Text(
                              "${projectTypes[index % 3]} Dataset ${index + 1}",
                            ),
                            subtitle: Text(
                              "Last updated: ${index + 1} day${index == 0 ? '' : 's'} ago",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: projectColors[index % 3].withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    projectTypes[index % 3],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: projectColors[index % 3],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      //  Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
