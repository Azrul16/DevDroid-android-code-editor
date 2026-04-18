import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/file_node_model.dart';

class FileService {
  FileService({this.rootPath = AppConstants.rootProjectsPath});

  final String rootPath;
  String? _resolvedRootPath;

  Future<String> getRootPath() async {
    if (_resolvedRootPath != null) {
      return _resolvedRootPath!;
    }

    if (!kIsWeb && Platform.isAndroid) {
      _resolvedRootPath = rootPath;
      return _resolvedRootPath!;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    _resolvedRootPath = p.join(docsDir.path, 'DevDroidProjects');
    return _resolvedRootPath!;
  }

  Future<void> createRootFolder() async {
    final dir = Directory(await getRootPath());
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<void> createProject(String projectName) async {
    final dir = Directory(p.join(await getRootPath(), projectName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<void> renamePath(String oldPath, String newPath) async {
    final type = FileSystemEntity.typeSync(oldPath);
    if (type == FileSystemEntityType.file) {
      await File(oldPath).rename(newPath);
      return;
    }
    if (type == FileSystemEntityType.directory) {
      await Directory(oldPath).rename(newPath);
    }
  }

  Future<void> createFolder(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<void> createFile(String path, String content) async {
    final file = File(path);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  Future<String> readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return '';
    }
    return file.readAsString();
  }

  Future<void> saveFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  Future<List<FileNodeModel>> listNodes(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return const [];
    }

    final entities = dir.listSync();
    final mapped = entities.map((entity) {
      final isDirectory = entity is Directory;
      return FileNodeModel(
        name: p.basename(entity.path),
        path: entity.path,
        isDirectory: isDirectory,
      );
    }).toList();

    mapped.sort((a, b) {
      if (a.isDirectory != b.isDirectory) {
        return a.isDirectory ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return mapped;
  }

  Future<void> deleteFileOrFolder(String path) async {
    final type = FileSystemEntity.typeSync(path);
    if (type == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: true);
    } else if (type == FileSystemEntityType.file) {
      await File(path).delete();
    }
  }
}
