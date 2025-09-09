import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/project.dart';
import '../../../core/services/storage_service.dart';
import '../../pages/view_table_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  List<Project> projects = [];
  bool isLoading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadProjects();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
        _fadeController.forward(from: 0); // reset animasi setiap refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: $e'),
            backgroundColor: CupertinoColors.systemRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Method to refresh projects from other pages
  void refreshProjects() {
    _loadProjects();
  }

  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildProjectCard(Project project, int index) {
    final animation =
        Tween<Offset>(
          begin: const Offset(0, 0.1), // geser sedikit dari bawah
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(
              0.1 * index, // delay antar item biar berurutan
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        );

    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: animation,
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade600,
              child: const Icon(CupertinoIcons.table, color: Colors.white),
            ),
            title: Text(
              project.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "Updated ${_formatDateTime(project.updatedAt ?? project.createdAt)}",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              icon: const Icon(CupertinoIcons.chevron_forward, size: 18),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => ViewTablePage(project: project),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, String route, Color c) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, route);
        if (result == true) {
          _loadProjects();
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: c.withOpacity(0.1),
            child: Icon(icon, color: c, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          "DataHub Pro",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFF9F9F9),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(CupertinoIcons.line_horizontal_3),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.settings),
            onPressed: () => Navigator.pushNamed(context, "/settings"),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : RefreshIndicator(
              onRefresh: _loadProjects,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          "New",
                          CupertinoIcons.add,
                          AppRoutes.mixedData,
                          Colors.blue,
                        ),
                        _buildQuickAction(
                          "List",
                          CupertinoIcons.list_bullet,
                          AppRoutes.dataList,
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Recent Projects
                    const Text(
                      "Recent Projects",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (projects.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            "No projects yet",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projects.length > 5 ? 5 : projects.length,
                        itemBuilder: (context, i) =>
                            _buildProjectCard(projects[i], i),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const ListTile(
              title: Text(
                "DataHub Pro",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Text("Manage your data effortlessly"),
            ),
            const Divider(),
            _drawerItem(CupertinoIcons.folder, "Templates", "/templates"),
            _drawerItem(CupertinoIcons.square_arrow_up, "Import", "/import"),
            _drawerItem(CupertinoIcons.square_arrow_down, "Export", "/export"),
            const Divider(),
            _drawerItem(CupertinoIcons.shield, "Privacy", "/privacy"),
            _drawerItem(CupertinoIcons.info, "About", "/about"),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
