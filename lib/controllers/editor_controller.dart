import 'package:path/path.dart' as p;

import 'package:flutter/foundation.dart';

import '../core/utils/command_utils.dart';
import '../models/file_node_model.dart';
import '../services/file_service.dart';
import '../services/termux_run_command_service.dart';

class EditorController extends ChangeNotifier {
  EditorController(this._fileService, this._termuxService);

  final FileService _fileService;
  final TermuxRunCommandService _termuxService;

  List<FileNodeModel> files = [];
  String? currentProjectPath;
  String? currentFilePath;
  String currentCode = '';
  List<String> openTabs = [];
  int selectedTabIndex = -1;

  Future<void> loadProjectFiles(String projectPath) async {
    currentProjectPath = projectPath;
    files = await _fileService.listNodes(projectPath);
    notifyListeners();
  }

  Future<void> openFile(String filePath) async {
    if (!openTabs.contains(filePath)) {
      openTabs.add(filePath);
    }
    selectedTabIndex = openTabs.indexOf(filePath);
    currentFilePath = filePath;
    currentCode = await _fileService.readFile(filePath);
    notifyListeners();
  }

  void updateCode(String value) {
    currentCode = value;
    notifyListeners();
  }

  Future<void> saveCurrentFile() async {
    final path = currentFilePath;
    if (path == null) {
      return;
    }
    await _fileService.saveFile(path, currentCode);
  }

  Future<String> runCurrentFile() async {
    final path = currentFilePath;
    if (path == null) {
      return 'No file selected';
    }

    await saveCurrentFile();
    final command = CommandUtils.buildRunCommand(path);
    return _termuxService.runCommand(command: command);
  }

  Future<String?> prepareRunCommand() async {
    final path = currentFilePath;
    if (path == null) {
      return null;
    }
    await saveCurrentFile();
    return CommandUtils.buildRunCommand(path);
  }

  Future<String?> prepareFormatCommand() async {
    final path = currentFilePath;
    if (path == null) {
      return null;
    }
    await saveCurrentFile();
    return CommandUtils.buildFormatCommand(path);
  }

  Future<void> reloadCurrentFile() async {
    final path = currentFilePath;
    if (path == null) {
      return;
    }
    currentCode = await _fileService.readFile(path);
    notifyListeners();
  }

  Future<bool> createFileInProject({
    required String baseName,
    required String extension,
  }) async {
    final root = currentProjectPath;
    if (root == null) {
      return false;
    }

    final ext = extension.startsWith('.') ? extension : '.$extension';
    final filePath = p.join(root, '$baseName$ext');
    await _fileService.createFile(filePath, _templateByExtension(ext));
    await loadProjectFiles(root);
    await openFile(filePath);
    return true;
  }

  Future<void> closeTab(int index) async {
    if (index < 0 || index >= openTabs.length) {
      return;
    }

    final closingPath = openTabs[index];
    if (currentFilePath == closingPath) {
      await saveCurrentFile();
    }

    openTabs.removeAt(index);

    if (openTabs.isEmpty) {
      selectedTabIndex = -1;
      currentFilePath = null;
      currentCode = '';
      notifyListeners();
      return;
    }

    if (selectedTabIndex >= openTabs.length) {
      selectedTabIndex = openTabs.length - 1;
    } else if (selectedTabIndex > index) {
      selectedTabIndex -= 1;
    }

    final nextPath = openTabs[selectedTabIndex];
    currentFilePath = nextPath;
    currentCode = await _fileService.readFile(nextPath);
    notifyListeners();
  }

  Future<void> switchToTab(int index) async {
    if (index < 0 || index >= openTabs.length) {
      return;
    }
    selectedTabIndex = index;
    currentFilePath = openTabs[index];
    currentCode = await _fileService.readFile(currentFilePath!);
    notifyListeners();
  }

  Future<bool> renameTabFile(int index, String newFileName) async {
    if (index < 0 || index >= openTabs.length) {
      return false;
    }

    final oldPath = openTabs[index];
    final dir = p.dirname(oldPath);
    final targetPath = p.join(dir, newFileName);
    if (oldPath == targetPath) {
      return true;
    }

    await _fileService.renamePath(oldPath, targetPath);
    openTabs[index] = targetPath;
    if (currentFilePath == oldPath) {
      currentFilePath = targetPath;
    }
    if (currentProjectPath != null) {
      files = await _fileService.listNodes(currentProjectPath!);
    }
    notifyListeners();
    return true;
  }

  String _templateByExtension(String ext) {
    switch (ext) {
      case '.py':
        return 'print("Hello from DevDroid")\n';
      case '.js':
        return 'console.log("Hello from DevDroid");\n';
      case '.html':
        return '<!doctype html>\n<html>\n<head>\n  <meta charset=\'utf-8\'>\n  <link rel=\'stylesheet\' href=\'style.css\'>\n</head>\n<body>\n  <h1>Hello DevDroid</h1>\n  <script src=\'script.js\'></script>\n</body>\n</html>\n';
      case '.css':
        return 'body {\n  background: #0d1117;\n  color: #c9d1d9;\n}\n';
      case '.java':
        return 'public class Main {\n  public static void main(String[] args) {\n    System.out.println("Hello from DevDroid");\n  }\n}\n';
      case '.c':
        return '#include <stdio.h>\n\nint main() {\n  printf("Hello from DevDroid\\n");\n  return 0;\n}\n';
      case '.cpp':
        return '#include <iostream>\n\nint main() {\n  std::cout << "Hello from DevDroid" << std::endl;\n  return 0;\n}\n';
      default:
        return '';
    }
  }
}
