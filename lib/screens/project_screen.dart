import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/editor_controller.dart';
import '../controllers/project_controller.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/editor_theme.dart';
import '../widgets/file_tree_view.dart';
import 'editor_screen.dart';
import 'git_screen.dart';
import 'terminal_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final projectPath = context.read<ProjectController>().currentProject?.path;
    if (projectPath != null) {
      context.read<EditorController>().loadProjectFiles(projectPath);
    }
  }

  Future<void> _showCreateFileDialog() async {
    final editorController = context.read<EditorController>();
    final nameController = TextEditingController();
    String ext = 'py';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Create New File'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'File name (without extension)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: ext,
                    items: const [
                      DropdownMenuItem(value: 'py', child: Text('.py Python')),
                      DropdownMenuItem(value: 'js', child: Text('.js JavaScript')),
                      DropdownMenuItem(value: 'java', child: Text('.java Java')),
                      DropdownMenuItem(value: 'html', child: Text('.html HTML')),
                      DropdownMenuItem(value: 'css', child: Text('.css CSS')),
                      DropdownMenuItem(value: 'c', child: Text('.c C')),
                      DropdownMenuItem(value: 'cpp', child: Text('.cpp C++')),
                      DropdownMenuItem(value: 'txt', child: Text('.txt Text')),
                    ],
                    onChanged: (value) => setLocal(() => ext = value ?? 'py'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
              ],
            );
          },
        );
      },
    );

    if (result != true || nameController.text.trim().isEmpty) {
      return;
    }

    await editorController.createFileInProject(
      baseName: nameController.text.trim(),
      extension: ext,
    );

    if (!mounted) {
      return;
    }

    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectController>().currentProject;
    final editorController = context.watch<EditorController>();

    if (project == null) {
      return const Scaffold(body: Center(child: Text('No project selected')));
    }

    final pages = [
      EditorScreen(onOpenTerminal: () => setState(() => _selectedIndex = 1)),
      const TerminalScreen(),
      const GitScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF040C16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061321),
        foregroundColor: EditorThemeColors.textPrimary,
        elevation: 0,
        titleSpacing: 8,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.name, style: AppTypography.title),
            Text('workspace', style: AppTypography.subtitle.copyWith(color: EditorThemeColors.textMuted)),
          ],
        ),
        actions: [
          _TopActionButton(
            tooltip: 'New file',
            icon: Icons.note_add_rounded,
            onPressed: _showCreateFileDialog,
          ),
          _TopActionButton(
            tooltip: 'Open terminal',
            icon: Icons.terminal_rounded,
            onPressed: () => setState(() => _selectedIndex = 1),
          ),
          _TopActionButton(
            tooltip: 'Open git',
            icon: Icons.account_tree_rounded,
            onPressed: () => setState(() => _selectedIndex = 2),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x1FFFFFFF))),
            ),
            child: Row(
              children: [
                _WorkspaceChip(
                  icon: Icons.code_rounded,
                  label: 'Editor',
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                const SizedBox(width: 8),
                _WorkspaceChip(
                  icon: Icons.terminal_rounded,
                  label: 'Terminal',
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const SizedBox(width: 8),
                _WorkspaceChip(
                  icon: Icons.account_tree_rounded,
                  label: 'Git',
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF071524),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x26FFFFFF))),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPLORER',
                            style: AppTypography.sectionLabel,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Project Files',
                            style: AppTypography.menuItem,
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: _showCreateFileDialog, icon: const Icon(Icons.add_rounded, size: 20)),
                  ],
                ),
              ),
              Expanded(
                child: FileTreeView(
                  nodes: editorController.files,
                  onFileTap: (node) {
                    final navigator = Navigator.of(context);
                    context.read<EditorController>().openFile(node.path).then((_) {
                      if (!mounted) {
                        return;
                      }
                      navigator.pop();
                      setState(() => _selectedIndex = 0);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08172A), Color(0xFF040B15)],
          ),
        ),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF06111D),
          border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFF06111D),
            indicatorColor: const Color(0x243A88E8),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final active = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: AppTypography.chip.fontSize,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? const Color(0xFF8CC4FF) : EditorThemeColors.textMuted,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.code_rounded), label: 'Editor'),
              NavigationDestination(icon: Icon(Icons.terminal_rounded), label: 'Terminal'),
              NavigationDestination(icon: Icon(Icons.account_tree_rounded), label: 'Git'),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0x1D8BC3FF),
        side: const BorderSide(color: Color(0x2F8BC3FF)),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  const _WorkspaceChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0x203A88E8) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0x5A5AA6FF) : const Color(0x2AFFFFFF)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: selected ? const Color(0xFF8CC4FF) : EditorThemeColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.chip.fontSize,
                fontWeight: AppTypography.chip.fontWeight,
                color: selected ? const Color(0xFFB9DBFF) : EditorThemeColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
