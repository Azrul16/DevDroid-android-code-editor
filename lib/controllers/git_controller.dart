import 'package:flutter/foundation.dart';

import '../services/git_service.dart';

class GitController extends ChangeNotifier {
  GitController(this._gitService);

  final GitService _gitService;

  String lastOutput = 'Git panel ready';

  Future<void> status(String projectDir) async {
    lastOutput = await _gitService.status(projectDir);
    notifyListeners();
  }

  Future<void> pull(String projectDir) async {
    lastOutput = await _gitService.pull(projectDir);
    notifyListeners();
  }

  Future<void> push(String projectDir) async {
    lastOutput = await _gitService.push(projectDir);
    notifyListeners();
  }

  Future<void> addAndCommit(String projectDir, String message) async {
    lastOutput = await _gitService.addAndCommit(projectDir, message);
    notifyListeners();
  }
}
