import 'package:flutter/material.dart';
import '../../../app/routes/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final quickActions = [
      {
        "title": "Input Data",
        "icon": Icons.edit_document,
        "route": AppRoutes.inputData,
      },
      {
        "title": "Data List",
        "icon": Icons.list_alt,
        "route": AppRoutes.dataList,
      },
      {"title": "Profile", "icon": Icons.person, "route": "/profile"},
      {"title": "Settings", "icon": Icons.settings, "route": "/settings"},
    ];

    final categories = [
      {"title": "Numeric", "icon": Icons.numbers, "color": Colors.teal},
      {"title": "Categorical", "icon": Icons.category, "color": Colors.indigo},
      {"title": "Text", "icon": Icons.text_snippet, "color": Colors.deepOrange},
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
                    backgroundImage: AssetImage("assets/images/avatar.png"),
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
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.indigo],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Data Hub",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Manage, visualize, and explore your datasets",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.inputData,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Add New Data"),
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
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item["title"] as String,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    //  CATEGORIES
                    Text(
                      "Categories",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return Container(
                            width: 140,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (cat["color"] as Color).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  cat["icon"] as IconData,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const Spacer(),
                                Text(
                                  cat["title"] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  RECENT DATA
                    Text(
                      "Recent Data",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade200,
                              child: const Icon(
                                Icons.insert_drive_file,
                                color: Colors.white,
                              ),
                            ),
                            title: Text("Dataset ${index + 1}"),
                            subtitle: const Text("Last updated: today"),
                            trailing: const Icon(Icons.chevron_right),
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
