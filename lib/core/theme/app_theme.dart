import 'package:flutter/material.dart';

import 'editor_theme.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EditorThemeColors.background,
      colorScheme: const ColorScheme.dark(
        primary: EditorThemeColors.accentBlue,
        secondary: EditorThemeColors.accentGreen,
        surface: EditorThemeColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EditorThemeColors.background,
        foregroundColor: EditorThemeColors.textPrimary,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: EditorThemeColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: EditorThemeColors.surfaceSoft,
        indicatorColor: EditorThemeColors.panel,
      ),
      listTileTheme: const ListTileThemeData(
        dense: true,
        iconColor: EditorThemeColors.textMuted,
        textColor: EditorThemeColors.textPrimary,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: EditorThemeColors.accentBlue,
        selectionColor: Color(0x4D58A6FF),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: EditorThemeColors.border),
          foregroundColor: EditorThemeColors.textPrimary,
          backgroundColor: EditorThemeColors.surfaceSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EditorThemeColors.accentBlue,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: EditorThemeColors.surfaceSoft,
        hintStyle: TextStyle(color: EditorThemeColors.textMuted),
        labelStyle: TextStyle(color: EditorThemeColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: EditorThemeColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: EditorThemeColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: EditorThemeColors.accentBlue, width: 1),
        ),
      ),
      fontFamily: 'monospace',
    );
  }
}
