import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/editor_controller.dart';
import 'controllers/git_controller.dart';
import 'controllers/project_controller.dart';
import 'controllers/terminal_controller.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/file_service.dart';
import 'services/git_service.dart';
import 'services/settings_service.dart';
import 'services/ssh_terminal_service.dart';
import 'services/termux_run_command_service.dart';

class DevDroidApp extends StatelessWidget {
  const DevDroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FileService>(create: (_) => FileService()),
        Provider<SettingsService>(create: (_) => SettingsService()),
        Provider<TermuxRunCommandService>(create: (_) => TermuxRunCommandService()),
        Provider<SshTerminalService>(create: (_) => SshTerminalService()),
        Provider<GitService>(
          create: (context) => GitService(context.read<TermuxRunCommandService>()),
        ),
        ChangeNotifierProvider<ProjectController>(
          create: (context) =>
              ProjectController(context.read<FileService>(), context.read<SettingsService>())
                ..init(),
        ),
        ChangeNotifierProvider<EditorController>(
          create: (context) =>
              EditorController(context.read<FileService>(), context.read<TermuxRunCommandService>()),
        ),
        ChangeNotifierProvider<TerminalController>(
          create: (context) => TerminalController(
            context.read<TermuxRunCommandService>(),
            context.read<SshTerminalService>(),
          ),
        ),
        ChangeNotifierProvider<GitController>(
          create: (context) => GitController(context.read<GitService>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}
