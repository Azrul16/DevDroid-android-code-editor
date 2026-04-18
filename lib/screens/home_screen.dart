import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/project_controller.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/editor_theme.dart';
import '../models/project_model.dart';
import 'project_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _createProjectFromDialog() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final projectController = context.read<ProjectController>();
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Project name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) {
      return;
    }

    final success = await projectController.createProject(name);
    if (!mounted) return;

    if (!success || projectController.currentProject == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(projectController.lastError ?? 'Could not create project')),
      );
      return;
    }

    navigator.push(MaterialPageRoute(builder: (_) => const ProjectScreen()));
  }

  Future<void> _openProjectPicker() async {
    final projectController = context.read<ProjectController>();
    final parentNavigator = Navigator.of(context);
    final projects = projectController.recentProjects;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0B1523),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        if (projects.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text('No projects found', style: TextStyle(color: EditorThemeColors.textMuted)),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: projects.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0x22FFFFFF)),
          itemBuilder: (context, index) {
            final project = projects[index];
            return ListTile(
              leading: const Icon(Icons.folder_open_rounded, color: EditorThemeColors.accentOrange),
              title: Text(project.name),
              subtitle: Text(
                project.path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.meta.copyWith(color: EditorThemeColors.textMuted),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () async {
                  final ok = await _confirmDelete(project);
                  if (!ok || !mounted) return;
                  await projectController.deleteProject(project);
                  if (!mounted) return;
                  if (parentNavigator.canPop()) {
                    parentNavigator.pop();
                  }
                },
              ),
              onTap: () {
                projectController.openProject(project);
                Navigator.pop(context);
                Navigator.of(this.context).push(MaterialPageRoute(builder: (_) => const ProjectScreen()));
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmDelete(ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Delete "${project.name}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _openCommandPalette() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0C1726),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Command Palette', style: AppTypography.title),
                subtitle: Text('Quick actions', style: AppTypography.meta),
              ),
              _CommandItem(
                icon: Icons.add_rounded,
                label: 'New Project',
                onTap: () {
                  Navigator.pop(context);
                  _createProjectFromDialog();
                },
              ),
              _CommandItem(
                icon: Icons.folder_open_rounded,
                label: 'Open Project',
                onTap: () {
                  Navigator.pop(context);
                  _openProjectPicker();
                },
              ),
              _CommandItem(
                icon: Icons.settings_rounded,
                label: 'Open Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(this.context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectController = context.watch<ProjectController>();

    return Scaffold(
      backgroundColor: const Color(0xFF041021),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF051325), Color(0xFF030B16)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('K', style: AppTypography.brandMark.copyWith(color: const Color(0xFF9ED7B7))),
                    const SizedBox(width: 10),
                    Text(
                      'Welcome to DevDroid',
                      style: AppTypography.heroTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Code. Run. Ship from your phone.',
                  style: AppTypography.body.copyWith(color: EditorThemeColors.textMuted),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('GET STARTED'),
                _WelcomeItem(
                  icon: Icons.add_rounded,
                  label: 'New',
                  trailing: '',
                  onTap: _createProjectFromDialog,
                ),
                _WelcomeItem(
                  icon: Icons.folder_open_rounded,
                  label: 'Open Project',
                  trailing: 'Ctrl-O',
                  onTap: _openProjectPicker,
                ),
                _WelcomeItem(
                  icon: Icons.keyboard_command_key_rounded,
                  label: 'Open Command Palette',
                  trailing: 'Ctrl-Shift-P',
                  onTap: _openCommandPalette,
                ),
                const SizedBox(height: 12),
                const _SectionTitle('CONFIGURE'),
                _WelcomeItem(
                  icon: Icons.settings_rounded,
                  label: 'Open Settings',
                  trailing: '',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                const SizedBox(height: 14),
                const _SectionTitle('RECENT'),
                Expanded(
                  child: projectController.recentProjects.isEmpty
                      ? Center(
                          child: Text(
                            'No recent projects',
                            style: AppTypography.meta.copyWith(color: EditorThemeColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          itemCount: projectController.recentProjects.length,
                          itemBuilder: (context, index) {
                            final project = projectController.recentProjects[index];
                            return _RecentProjectTile(
                              project: project,
                              onOpen: () {
                                projectController.openProject(project);
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectScreen()));
                              },
                              onDelete: () async {
                                final ok = await _confirmDelete(project);
                                if (!ok) return;
                                await projectController.deleteProject(project);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title, style: AppTypography.sectionLabel.copyWith(color: EditorThemeColors.textMuted)),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: Color(0x2FFFFFFF), height: 1)),
        ],
      ),
    );
  }
}

class _WelcomeItem extends StatelessWidget {
  const _WelcomeItem({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8BC3FF)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.menuItem)),
            if (trailing.isNotEmpty)
              Text(trailing, style: AppTypography.meta.copyWith(color: EditorThemeColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _RecentProjectTile extends StatelessWidget {
  const _RecentProjectTile({
    required this.project,
    required this.onOpen,
    required this.onDelete,
  });

  final ProjectModel project;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: const Icon(Icons.folder_rounded, color: EditorThemeColors.accentOrange),
        title: Text(project.name, style: AppTypography.title),
        subtitle: Text(
          project.path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.meta.copyWith(color: EditorThemeColors.textMuted),
        ),
        trailing: IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent)),
        onTap: onOpen,
      ),
    );
  }
}

class _CommandItem extends StatelessWidget {
  const _CommandItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
