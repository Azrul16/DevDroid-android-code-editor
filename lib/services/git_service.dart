import '../core/constants/command_templates.dart';
import 'termux_run_command_service.dart';

class GitService {
  GitService(this._termuxService);

  final TermuxRunCommandService _termuxService;

  Future<String> status(String projectDir) {
    return _termuxService.runCommand(
      command: CommandTemplates.gitStatus(projectDir),
    );
  }

  Future<String> pull(String projectDir) {
    return _termuxService.runCommand(
      command: CommandTemplates.gitPull(projectDir),
    );
  }

  Future<String> push(String projectDir) {
    return _termuxService.runCommand(
      command: CommandTemplates.gitPush(projectDir),
    );
  }

  Future<String> addAndCommit(String projectDir, String message) {
    return _termuxService.runCommand(
      command: CommandTemplates.gitAddCommit(projectDir, message),
    );
  }
}
