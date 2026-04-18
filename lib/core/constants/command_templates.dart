class CommandTemplates {
  static String gitStatus(String projectDir) => 'cd "$projectDir" && git status';

  static String gitPull(String projectDir) => 'cd "$projectDir" && git pull';

  static String gitPush(String projectDir) => 'cd "$projectDir" && git push';

  static String gitAddCommit(String projectDir, String message) {
    return 'cd "$projectDir" && git add . && git commit -m "$message"';
  }

  static String installPackage(String packageName) => 'pkg install $packageName';
}
