import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../controllers/project_controller.dart';
import '../../services/termux_run_command_service.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _loading = true;
  Map<String, bool> _checks = const {};

  @override
  void initState() {
    super.initState();
    _runChecks();
  }

  Future<void> _runChecks() async {
    final projectController = context.read<ProjectController>();
    final termuxService = context.read<TermuxRunCommandService>();

    bool permissionOk = true;
    if (Platform.isAndroid) {
      final manage = await Permission.manageExternalStorage.status;
      final storage = await Permission.storage.status;
      permissionOk = manage.isGranted || storage.isGranted;
    }

    bool termuxOk = false;
    try {
      final result = await termuxService.runCommand(command: 'echo devdroid-check');
      termuxOk = !result.toLowerCase().contains('error');
    } catch (_) {
      termuxOk = false;
    }

    final rootExists = projectController.rootPath.isNotEmpty && await Directory(projectController.rootPath).exists();

    if (!mounted) {
      return;
    }

    setState(() {
      _checks = {
        'Storage Permission': permissionOk,
        'Workspace Root Ready': rootExists,
        'Termux Command Bridge': termuxOk,
        'Project Controller Init': projectController.lastError == null,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _checks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final key = _checks.keys.elementAt(index);
                final value = _checks.values.elementAt(index);
                return ListTile(
                  tileColor: const Color(0xFF122033),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(Icons.circle, color: value ? Colors.green : Colors.red, size: 12),
                  title: Text(key),
                  subtitle: Text(value ? 'Enabled / Working' : 'Not configured'),
                );
              },
            ),
    );
  }
}
