import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../models/project_model.dart';
import '../services/file_service.dart';
import '../services/settings_service.dart';

class ProjectController extends ChangeNotifier {
  ProjectController(this._fileService, this._settingsService);

  final FileService _fileService;
  final SettingsService _settingsService;

  List<ProjectModel> recentProjects = [];
  ProjectModel? currentProject;
  bool isLoading = false;
  String? lastError;
  String rootPath = '';
  bool permissionGranted = false;

  Future<void> init() async {
    try {
      isLoading = true;
      notifyListeners();

      await _ensureStoragePermissionIfNeeded();
      permissionGranted = true;
      await _fileService.createRootFolder();
      rootPath = await _fileService.getRootPath();
      recentProjects = await _settingsService.loadRecentProjects();

      if (recentProjects.isEmpty) {
        await refreshProjectsFromDisk();
      }
    } catch (error) {
      permissionGranted = false;
      lastError = 'Initialization failed: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProjectsFromDisk() async {
    final dir = Directory(await _fileService.getRootPath());
    if (!await dir.exists()) {
      recentProjects = [];
      notifyListeners();
      return;
    }

    final entities = dir.listSync().whereType<Directory>();
    recentProjects = entities
        .map((e) => ProjectModel(name: p.basename(e.path), path: e.path))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    await _settingsService.saveRecentProjects(recentProjects);
    notifyListeners();
  }

  Future<bool> createProject(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      lastError = 'Project name is required';
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      lastError = null;
      notifyListeners();

      await _ensureStoragePermissionIfNeeded();
      permissionGranted = true;
      await _fileService.createProject(trimmed);
      await refreshProjectsFromDisk();

      final root = await _fileService.getRootPath();
      currentProject = recentProjects.firstWhere(
        (project) => project.name == trimmed,
        orElse: () => ProjectModel(
          name: trimmed,
          path: p.join(root, trimmed),
        ),
      );

      notifyListeners();
      return true;
    } catch (error) {
      permissionGranted = false;
      lastError = 'Create project failed: $error';
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void openProject(ProjectModel project) {
    currentProject = project;
    notifyListeners();
  }

  Future<bool> deleteProject(ProjectModel project) async {
    try {
      isLoading = true;
      notifyListeners();
      await _fileService.deleteFileOrFolder(project.path);
      if (currentProject?.path == project.path) {
        currentProject = null;
      }
      await refreshProjectsFromDisk();
      return true;
    } catch (error) {
      lastError = 'Delete failed: $error';
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTemplateProject(String name, String type) async {
    final ok = await createProject(name);
    if (!ok || currentProject == null) {
      return false;
    }

    final projectPath = currentProject!.path;
    try {
      if (type == 'web') {
        await _fileService.createFile(
          p.join(projectPath, 'index.html'),
          '<!doctype html>\\n<html>\\n<head>\\n  <meta charset="utf-8">\\n  <meta name="viewport" content="width=device-width, initial-scale=1">\\n  <title>$name</title>\\n  <link rel="stylesheet" href="style.css">\\n</head>\\n<body>\\n  <h1>Hello from DevDroid</h1>\\n  <script src="script.js"></script>\\n</body>\\n</html>\\n',
        );
        await _fileService.createFile(
          p.join(projectPath, 'style.css'),
          'body {\\n  background: #0d1117;\\n  color: #c9d1d9;\\n  font-family: monospace;\\n}\\n',
        );
        await _fileService.createFile(
          p.join(projectPath, 'script.js'),
          'console.log("DevDroid web project ready");\\n',
        );
      } else if (type == 'java') {
        await _fileService.createFile(
          p.join(projectPath, 'Main.java'),
          'public class Main {\\n  public static void main(String[] args) {\\n    System.out.println("Hello from DevDroid Java");\\n  }\\n}\\n',
        );
      } else {
        await _fileService.createFile(
          p.join(projectPath, 'main.py'),
          'print("Hello from DevDroid")\\n',
        );
      }
      return true;
    } catch (error) {
      lastError = 'Template creation failed: $error';
      notifyListeners();
      return false;
    }
  }

  Future<void> _ensureStoragePermissionIfNeeded() async {
    if (!Platform.isAndroid) {
      return;
    }

    final manageStatus = await Permission.manageExternalStorage.status;
    if (manageStatus.isGranted) {
      return;
    }

    final requestedManage = await Permission.manageExternalStorage.request();
    if (requestedManage.isGranted) {
      return;
    }

    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      final requestedStorage = await Permission.storage.request();
      if (!requestedStorage.isGranted) {
        throw Exception('Storage permission denied');
      }
    }
  }
}
