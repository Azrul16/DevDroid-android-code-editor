import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/settings_service.dart';

class EditorSettingsScreen extends StatefulWidget {
  const EditorSettingsScreen({super.key});

  @override
  State<EditorSettingsScreen> createState() => _EditorSettingsScreenState();
}

class _EditorSettingsScreenState extends State<EditorSettingsScreen> {
  bool loading = true;

  String fontFamily = 'KlyxMono';
  double fontSize = 14.0;
  int tabSize = 4;
  bool pinLineNumbers = false;
  bool deleteEmptyLineFast = true;
  bool deleteMultipleSpaces = false;
  bool symbolPairAutocomplete = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = context.read<SettingsService>();
    fontFamily = await settings.getFontFamily();
    fontSize = await settings.getFontSize();
    tabSize = await settings.getTabSize();
    pinLineNumbers = await settings.getPinLineNumbers();
    deleteEmptyLineFast = await settings.getDeleteEmptyLineFast();
    deleteMultipleSpaces = await settings.getDeleteMultipleSpaces();
    symbolPairAutocomplete = await settings.getSymbolPairAutocomplete();

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> _save() async {
    final settings = context.read<SettingsService>();
    await settings.setFontFamily(fontFamily);
    await settings.setFontSize(fontSize);
    await settings.setTabSize(tabSize);
    await settings.setPinLineNumbers(pinLineNumbers);
    await settings.setDeleteEmptyLineFast(deleteEmptyLineFast);
    await settings.setDeleteMultipleSpaces(deleteMultipleSpaces);
    await settings.setSymbolPairAutocomplete(symbolPairAutocomplete);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text('Common', style: TextStyle(color: Color(0xFF8BC3FF), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Font Family'),
            subtitle: Text(fontFamily),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final selected = await _pick(context, 'Font Family', const ['KlyxMono', 'JetBrainsMono', 'FiraCode']);
              if (selected == null) return;
              setState(() => fontFamily = selected);
              await _save();
            },
          ),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Text('${fontSize.toStringAsFixed(1)} sp'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final selected = await _pick(context, 'Font Size', const ['12.0', '13.0', '14.0', '15.0', '16.0']);
              if (selected == null) return;
              setState(() => fontSize = double.tryParse(selected) ?? 14.0);
              await _save();
            },
          ),
          ListTile(
            title: const Text('Tab Size'),
            subtitle: Text('$tabSize'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final selected = await _pick(context, 'Tab Size', const ['2', '4', '8']);
              if (selected == null) return;
              setState(() => tabSize = int.tryParse(selected) ?? 4);
              await _save();
            },
          ),
          const SizedBox(height: 8),
          const Text('Editing', style: TextStyle(color: Color(0xFF8BC3FF), fontWeight: FontWeight.w600)),
          SwitchListTile(
            title: const Text('Pin Line Numbers'),
            subtitle: const Text('Pin line numbers in the editor'),
            value: pinLineNumbers,
            onChanged: (v) async {
              setState(() => pinLineNumbers = v);
              await _save();
            },
          ),
          SwitchListTile(
            title: const Text('Delete empty lines fast'),
            subtitle: const Text('Remove empty line on delete key in empty line.'),
            value: deleteEmptyLineFast,
            onChanged: (v) async {
              setState(() => deleteEmptyLineFast = v);
              await _save();
            },
          ),
          SwitchListTile(
            title: const Text('Delete multiple spaces'),
            subtitle: const Text('Delete multiple spaces quickly while selecting.'),
            value: deleteMultipleSpaces,
            onChanged: (v) async {
              setState(() => deleteMultipleSpaces = v);
              await _save();
            },
          ),
          SwitchListTile(
            title: const Text('Symbol pair auto completion'),
            subtitle: const Text('Automatically insert closing symbols.'),
            value: symbolPairAutocomplete,
            onChanged: (v) async {
              setState(() => symbolPairAutocomplete = v);
              await _save();
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _pick(BuildContext context, String title, List<String> options) async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
              ...options.map((opt) => ListTile(
                    title: Text(opt),
                    onTap: () => Navigator.pop(context, opt),
                  )),
            ],
          ),
        );
      },
    );
  }
}
