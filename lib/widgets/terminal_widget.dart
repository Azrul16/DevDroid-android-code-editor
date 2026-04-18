import 'package:flutter/material.dart';

import '../core/theme/editor_theme.dart';

class TerminalWidget extends StatelessWidget {
  const TerminalWidget({
    super.key,
    required this.lines,
    required this.inputController,
    required this.onSubmit,
    required this.onClear,
  });

  final List<String> lines;
  final TextEditingController inputController;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EditorThemeColors.surface,
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: EditorThemeColors.surfaceSoft,
              border: Border(bottom: BorderSide(color: EditorThemeColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded, size: 16, color: EditorThemeColors.textMuted),
                const SizedBox(width: 8),
                const Text('TERMINAL', style: TextStyle(fontSize: 11, letterSpacing: 0.6)),
                const Spacer(),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                final prompt = line.startsWith(r'$');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: prompt ? EditorThemeColors.accentGreen : EditorThemeColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: EditorThemeColors.surfaceSoft,
              border: Border(top: BorderSide(color: EditorThemeColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chevron_right_rounded, color: EditorThemeColors.accentGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: inputController,
                    onSubmitted: onSubmit,
                    decoration: const InputDecoration(
                      hintText: 'Enter command...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
