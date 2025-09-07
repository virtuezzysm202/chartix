import 'package:flutter/material.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/project.dart';
import '../../../core/services/storage_service.dart';
import '../../pages/view_table_page.dart';
import '../chart/chart_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  List<Project> projects = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => isLoading = true);
    try {
      final loadedProjects = await StorageService.getProjects();
      loadedProjects.sort(
        (a, b) =>
            (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt),
      );
      if (mounted) {
        setState(() {
          projects = loadedProjects;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading projects: $e')));
      }
    }
  }

  String _formatDateTime(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    String dayName = days[date.weekday % 7];
    String monthName = months[date.month - 1];
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return '$dayName, ${date.day} $monthName ${date.year}, '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  Color _getProjectColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  Widget _buildProjectCard(Project project, int index) {
    final projectColor = _getProjectColor(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ViewTablePage(project: project),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: projectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.data_usage, color: projectColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last updated: ${_formatDateTime(project.updatedAt ?? project.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Table'),
                    ),
                    const PopupMenuItem(
                      value: 'chart',
                      child: Text('View Chart'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'view') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewTablePage(project: project),
                        ),
                      );
                    } else if (value == 'chart') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChartPage(project: project),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      {
        "title": "New Project",
        "icon": Icons.add_circle,
        "route": AppRoutes.mixedData,
        "color": Colors.blue,
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

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("DataHub Pro"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Templates'),
              onTap: () {
                Navigator.pushNamed(context, '/templates');
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import'),
              onTap: () {
                Navigator.pushNamed(context, '/import');
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export'),
              onTap: () {
                Navigator.pushNamed(context, '/export');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Actions",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: quickActions.map((item) {
                      return SizedBox(
                        width: 100,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            item["route"] as String,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: (item["color"] as Color)
                                        .withOpacity(0.1),
                                    child: Icon(
                                      item["icon"] as IconData,
                                      color: item["color"] as Color,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item["title"] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Recent Projects",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projects.length > 5 ? 5 : projects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(projects[index], index);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
