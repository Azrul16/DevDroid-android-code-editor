import 'package:flutter/material.dart';

import '../core/theme/editor_theme.dart';
import '../models/file_node_model.dart';

class FileTreeView extends StatelessWidget {
  const FileTreeView({
    super.key,
    required this.nodes,
    required this.onFileTap,
  });

  final List<FileNodeModel> nodes;
  final ValueChanged<FileNodeModel> onFileTap;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const Center(
        child: Text(
          'No files yet',
          style: TextStyle(color: EditorThemeColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return InkWell(
          onTap: node.isDirectory ? null : () => onFileTap(node),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: EditorThemeColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  node.isDirectory ? Icons.chevron_right_rounded : Icons.insert_drive_file_rounded,
                  size: 16,
                  color: node.isDirectory
                      ? EditorThemeColors.accentOrange
                      : EditorThemeColors.accentBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
