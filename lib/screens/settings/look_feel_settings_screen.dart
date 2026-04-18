import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/settings_service.dart';

class LookFeelSettingsScreen extends StatefulWidget {
  const LookFeelSettingsScreen({super.key});

  @override
  State<LookFeelSettingsScreen> createState() => _LookFeelSettingsScreenState();
}

class _LookFeelSettingsScreenState extends State<LookFeelSettingsScreen> {
  bool dynamicColor = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    dynamicColor = await context.read<SettingsService>().getDynamicColorEnabled();
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Look & feel')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const ListTile(
            title: Text('Theme'),
            subtitle: Text('Dark'),
          ),
          SwitchListTile(
            title: const Text('Dynamic color'),
            subtitle: const Text('Use system accent color where possible.'),
            value: dynamicColor,
            onChanged: (v) async {
              setState(() => dynamicColor = v);
              await context.read<SettingsService>().setDynamicColorEnabled(v);
            },
          ),
        ],
      ),
    );
  }
}
