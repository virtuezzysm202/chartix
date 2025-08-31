import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/project.dart';

class StorageService {
  static const String _projectsKey = 'projects';

  // Simpan semua projects
  static Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = projects.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_projectsKey, projectsJson);
  }

  // Ambil semua projects
  static Future<List<Project>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getStringList(_projectsKey) ?? [];
    return projectsJson
        .map((json) => Project.fromJson(jsonDecode(json)))
        .toList();
  }

  // Simpan project baru atau update
  static Future<void> saveProject(Project project) async {
    final projects = await getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);

    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }

    await saveProjects(projects);
  }

  // Hapus project
  static Future<void> deleteProject(String id) async {
    final projects = await getProjects();
    projects.removeWhere((p) => p.id == id);
    await saveProjects(projects);
  }
}
