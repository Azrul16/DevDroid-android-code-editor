import 'package:flutter/material.dart';

import '../core/theme/editor_theme.dart';
import 'settings/about_settings_screen.dart';
import 'settings/editor_settings_screen.dart';
import 'settings/general_settings_screen.dart';
import 'settings/look_feel_settings_screen.dart';
import 'settings/terminal_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071221),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 14),
            child: Text(
              'Customize your workspace',
              style: TextStyle(color: EditorThemeColors.textMuted, fontSize: 13),
            ),
          ),
          _SettingsTile(
            icon: Icons.settings_outlined,
            title: 'General',
            subtitle: 'Common Settings',
            onTap: () => _open(context, const GeneralSettingsScreen()),
          ),
          _SettingsTile(
            icon: Icons.code_rounded,
            title: 'Editor',
            subtitle: 'Fonts, tab size, editor settings',
            onTap: () => _open(context, const EditorSettingsScreen()),
          ),
          _SettingsTile(
            icon: Icons.terminal_rounded,
            title: 'Terminal',
            subtitle: 'Terminal settings',
            onTap: () => _open(context, const TerminalSettingsScreen()),
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Look & feel',
            subtitle: 'Dark theme, dynamic color',
            onTap: () => _open(context, const LookFeelSettingsScreen()),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'Version, feedback, auto update',
            onTap: () => _open(context, const AboutSettingsScreen()),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0x201E6FB5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF86C7FF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, height: 1.2)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: EditorThemeColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: EditorThemeColors.textMuted),
          ],
        ),
      ),
    );
  }
}
