import 'package:flutter/material.dart';

class TerminalSettingsScreen extends StatelessWidget {
  const TerminalSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terminal')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: const [
          ListTile(
            leading: Icon(Icons.terminal_rounded),
            title: Text('Default Shell'),
            subtitle: Text('bash'),
          ),
          ListTile(
            leading: Icon(Icons.route_rounded),
            title: Text('Termux Home'),
            subtitle: Text('/data/data/com.termux/files/home'),
          ),
          ListTile(
            leading: Icon(Icons.keyboard_rounded),
            title: Text('Extra Keys Bar'),
            subtitle: Text('Enabled'),
          ),
        ],
      ),
    );
  }
}
