import 'package:path/path.dart' as p;

import '../constants/app_constants.dart';

class CommandUtils {
  static String toTermuxSharedPath(String androidPath) {
    return androidPath.replaceFirst('/storage/emulated/0', r'$HOME/storage/shared');
  }

  static String buildRunCommand(String filePath) {
    final termuxPath = toTermuxSharedPath(filePath);
    final fileExtension = filePath.split('.').last.toLowerCase();
    final fileName = p.basename(filePath);
    final fileNameWithoutExt = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    final dir = p.dirname(termuxPath).replaceAll('\\', '/');

    if (fileExtension == 'py') {
      return 'python "$termuxPath"';
    }

    if (fileExtension == 'js') {
      return 'node "$termuxPath"';
    }

    if (fileExtension == 'c') {
      return 'cd "$dir" && clang "$fileName" -o app && ./app';
    }

    if (fileExtension == 'cpp') {
      return 'cd "$dir" && clang++ "$fileName" -o app && ./app';
    }

    if (fileExtension == 'java') {
      return 'cd "$dir" && javac "$fileName" && java "$fileNameWithoutExt"';
    }

    if (fileExtension == 'html' || fileExtension == 'css') {
      return 'cd "$dir" && python -m http.server 8080';
    }

    return 'echo "Unsupported file type"';
  }

  static String buildFormatCommand(String filePath) {
    final termuxPath = toTermuxSharedPath(filePath);
    final fileExtension = filePath.split('.').last.toLowerCase();

    if (fileExtension == 'py') {
      return 'if command -v black >/dev/null 2>&1; then black --quiet "$termuxPath"; '
          'elif python -m black --version >/dev/null 2>&1; then python -m black "$termuxPath"; '
          'else echo "Formatter missing: install black with pip install black"; fi';
    }

    if (fileExtension == 'js') {
      return 'if command -v prettier >/dev/null 2>&1; then prettier --write "$termuxPath"; '
          'elif command -v npx >/dev/null 2>&1; then npx --yes prettier --write "$termuxPath"; '
          'else echo "Formatter missing: install prettier (npm i -g prettier)"; fi';
    }

    if (fileExtension == 'java') {
      return 'if command -v google-java-format >/dev/null 2>&1; then google-java-format -i "$termuxPath"; '
          'elif command -v clang-format >/dev/null 2>&1; then clang-format -i "$termuxPath"; '
          'else echo "Formatter missing: install google-java-format or clang-format"; fi';
    }

    if (fileExtension == 'c' || fileExtension == 'cpp') {
      return 'if command -v clang-format >/dev/null 2>&1; then clang-format -i "$termuxPath"; '
          'else echo "Formatter missing: install clang-format"; fi';
    }

    return 'echo "No formatter configured for .$fileExtension"';
  }

  static String defaultProjectDir(String projectName) {
    return '${AppConstants.termuxSharedRoot}/$projectName';
  }
}
