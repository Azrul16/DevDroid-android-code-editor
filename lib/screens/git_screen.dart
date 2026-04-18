import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/git_controller.dart';
import '../controllers/project_controller.dart';
import '../core/theme/editor_theme.dart';

class GitScreen extends StatefulWidget {
  const GitScreen({super.key});

  @override
  State<GitScreen> createState() => _GitScreenState();
}

class _GitScreenState extends State<GitScreen> {
  final TextEditingController _commitController = TextEditingController();

  @override
  void dispose() {
    _commitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final git = context.watch<GitController>();
    final projectPath = context.watch<ProjectController>().currentProject?.path;

    if (projectPath == null) {
      return const Center(child: Text('No project selected'));
    }

    return Container(
      color: EditorThemeColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => context.read<GitController>().status(projectPath),
                  child: const Text('Status'),
                ),
                OutlinedButton(
                  onPressed: () => context.read<GitController>().pull(projectPath),
                  child: const Text('Pull'),
                ),
                OutlinedButton(
                  onPressed: () => context.read<GitController>().push(projectPath),
                  child: const Text('Push'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commitController,
              decoration: const InputDecoration(
                labelText: 'Commit Message',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => context
                  .read<GitController>()
                  .addAndCommit(projectPath, _commitController.text.trim()),
              child: const Text('Git Add + Commit'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EditorThemeColors.surfaceSoft,
                  border: Border.all(color: EditorThemeColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(git.lastOutput),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
