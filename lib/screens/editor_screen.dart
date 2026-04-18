import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../controllers/editor_controller.dart';
import '../controllers/terminal_controller.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/editor_theme.dart';
import '../widgets/bottom_command_panel.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/editor_tab_bar.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key, required this.onOpenTerminal});

  final VoidCallback onOpenTerminal;

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<EditorController>();

    final tabs = editor.openTabs.map((file) => p.basename(file)).toList();
    final selected = editor.selectedTabIndex >= 0 ? editor.selectedTabIndex : 0;
    final currentPath = editor.currentFilePath;

    final language = currentPath == null ? 'text' : _languageByPath(currentPath);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF09182A), Color(0xFF050E1A)],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1727),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x2E6A84A2)),
            ),
            child: EditorTabBar(
              tabs: tabs,
              selected: tabs.isEmpty ? -1 : selected,
              onSelected: (index) => context.read<EditorController>().switchToTab(index),
              onClose: (index) => context.read<EditorController>().closeTab(index),
              onRename: (index) => _renameTab(context, index, tabs[index]),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF091423),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x243D5572)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _languageColor(language).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _languageColor(language).withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    _languageLabel(language),
                    style: TextStyle(
                      fontSize: AppTypography.status.fontSize,
                      fontWeight: AppTypography.status.fontWeight,
                      letterSpacing: 0.5,
                      color: _languageColor(language),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentPath ?? 'No file selected from Explorer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle.copyWith(color: EditorThemeColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A111A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x2A5B6D81)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: currentPath == null
                    ? const Center(
                        child: Text(
                          'Open a file from Explorer to start coding',
                          style: TextStyle(color: EditorThemeColors.textMuted),
                        ),
                      )
                    : CodeEditorWidget(
                        code: editor.currentCode,
                        language: language,
                        onChanged: context.read<EditorController>().updateCode,
                      ),
              ),
            ),
          ),
          BottomCommandPanel(
            onSave: () => context.read<EditorController>().saveCurrentFile(),
            onFormat: () async {
              final editorController = context.read<EditorController>();
              final terminalController = context.read<TerminalController>();
              final command = await editorController.prepareFormatCommand();
              if (!context.mounted) {
                return;
              }
              if (command == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open a file first to format')),
                );
                return;
              }
              onOpenTerminal();
              await terminalController.runQuickCommand(command);
              await editorController.reloadCurrentFile();
            },
            onRun: () async {
              final editorController = context.read<EditorController>();
              final terminalController = context.read<TerminalController>();
              final command = await editorController.prepareRunCommand();
              if (!context.mounted) {
                return;
              }
              if (command == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open a file first to run')),
                );
                return;
              }
              onOpenTerminal();
              await terminalController.runQuickCommand(command);
            },
            onTerminal: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Switch to Terminal tab from bottom nav')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _renameTab(BuildContext context, int index, String currentName) async {
    final editorController = context.read<EditorController>();
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'New filename.ext'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newName == null || newName.isEmpty) {
      return;
    }

    await editorController.renameTabFile(index, newName);
  }

  String _languageByPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.py')) return 'python';
    if (lower.endsWith('.js')) return 'javascript';
    if (lower.endsWith('.java')) return 'java';
    if (lower.endsWith('.c')) return 'c';
    if (lower.endsWith('.cpp')) return 'cpp';
    if (lower.endsWith('.css')) return 'css';
    if (lower.endsWith('.html') || lower.endsWith('.htm')) return 'xml';
    return 'text';
  }

  String _languageLabel(String language) {
    switch (language) {
      case 'python':
        return 'PYTHON';
      case 'javascript':
        return 'JAVASCRIPT';
      case 'java':
        return 'JAVA';
      case 'c':
        return 'C';
      case 'cpp':
        return 'C++';
      case 'css':
        return 'CSS';
      case 'xml':
        return 'HTML/XML';
      default:
        return 'TEXT';
    }
  }

  Color _languageColor(String language) {
    switch (language) {
      case 'python':
        return const Color(0xFF8FC6FF);
      case 'javascript':
        return const Color(0xFFE3C46D);
      case 'java':
        return const Color(0xFFF2938F);
      case 'c':
      case 'cpp':
        return const Color(0xFFAAB9FF);
      case 'css':
        return const Color(0xFF8BD7C1);
      case 'xml':
        return const Color(0xFF9CD1FF);
      default:
        return EditorThemeColors.textMuted;
    }
  }
}
