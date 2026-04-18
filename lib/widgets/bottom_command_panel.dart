import 'package:flutter/material.dart';

import '../core/theme/editor_theme.dart';

class BottomCommandPanel extends StatelessWidget {
  const BottomCommandPanel({
    super.key,
    required this.onRun,
    required this.onSave,
    required this.onFormat,
    required this.onTerminal,
  });

  final VoidCallback onRun;
  final VoidCallback onSave;
  final VoidCallback onFormat;
  final VoidCallback onTerminal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF091524),
        border: Border(top: BorderSide(color: Color(0x223D5572))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilledButton.icon(
              onPressed: onRun,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2D76CF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Run'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                foregroundColor: EditorThemeColors.textPrimary,
                side: const BorderSide(color: Color(0x3F78A5D3)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onFormat,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFCFE2FB),
                side: const BorderSide(color: Color(0x3F78A5D3)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
              label: const Text('Format'),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onTerminal,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8CC4FF),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              icon: const Icon(Icons.terminal_rounded, size: 18),
              label: const Text('Terminal'),
            ),
          ],
        ),
      ),
    );
  }
}
