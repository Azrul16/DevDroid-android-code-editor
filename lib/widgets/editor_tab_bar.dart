import 'package:flutter/material.dart';

import '../core/theme/app_typography.dart';
import '../core/theme/editor_theme.dart';

class EditorTabBar extends StatelessWidget {
  const EditorTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    required this.onClose,
    required this.onRename,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onClose;
  final ValueChanged<int> onRename;

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 14, color: EditorThemeColors.textMuted),
              const SizedBox(width: 8),
              Text('No file opened', style: AppTypography.meta.copyWith(color: EditorThemeColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      itemCount: tabs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 6),
      itemBuilder: (context, index) {
        final active = index == selected;
        return GestureDetector(
          onSecondaryTap: () => onRename(index),
          onLongPress: () => onRename(index),
          onDoubleTap: () => onRename(index),
          child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              constraints: const BoxConstraints(minWidth: 138),
              padding: const EdgeInsets.only(left: 12, right: 4),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF0E1A29) : const Color(0xFF0B1420),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: active ? const Color(0x6E63AFFF) : const Color(0x332C3B4D),
                ),
                boxShadow: active
                    ? const [BoxShadow(color: Color(0x22111B2A), blurRadius: 8, offset: Offset(0, 2))]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF8CC4FF) : const Color(0xFF4C5C72),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tabs[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.meta.fontSize,
                        color: active ? EditorThemeColors.textPrimary : EditorThemeColors.textMuted,
                        fontWeight: AppTypography.meta.fontWeight,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close tab',
                    onPressed: () => onClose(index),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: active ? const Color(0xFF9CB8D8) : EditorThemeColors.textMuted,
                    ),
                    splashRadius: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
