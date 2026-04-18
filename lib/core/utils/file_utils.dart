import 'package:path/path.dart' as p;

class FileUtils {
  static String fileName(String filePath) => p.basename(filePath);

  static String extension(String filePath) => p.extension(filePath).toLowerCase();

  static String parentDirectory(String filePath) => p.dirname(filePath);
}
