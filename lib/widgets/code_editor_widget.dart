import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/c.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/styles/vs2015.dart';

import '../core/theme/editor_theme.dart';
import '../services/settings_service.dart';

class CodeEditorWidget extends StatefulWidget {
  const CodeEditorWidget({
    super.key,
    required this.code,
    required this.language,
    required this.onChanged,
  });

  final String code;
  final String language;
  final ValueChanged<String> onChanged;

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  late CodeLineEditingController _controller;
  bool _mutating = false;
  final SettingsService _settingsService = SettingsService();

  double _fontSize = 14;
  int _tabSize = 4;
  bool _symbolPairAutocomplete = true;

  @override
  void initState() {
    super.initState();
    _controller = _buildController(widget.code, _tabSize);
    _controller.addListener(_onControllerChanged);
    _loadEditorSettings();
  }

  @override
  void didUpdateWidget(covariant CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != _controller.text) {
      _mutating = true;
      _controller.text = widget.code;
      _mutating = false;
    }
  }

  void _onControllerChanged() {
    if (_mutating) {
      return;
    }
    widget.onChanged(_controller.text);
  }

  Future<void> _loadEditorSettings() async {
    final fontSize = await _settingsService.getFontSize();
    final tabSize = await _settingsService.getTabSize();
    final pairAutocomplete = await _settingsService.getSymbolPairAutocomplete();

    if (!mounted) {
      return;
    }

    final currentText = _controller.text;
    final currentSelection = _controller.selection;

    setState(() {
      _fontSize = fontSize;
      _tabSize = tabSize.clamp(1, 8).toInt();
      _symbolPairAutocomplete = pairAutocomplete;
    });

    _replaceController(
      _buildController(currentText, _tabSize),
      previousSelection: currentSelection,
    );
  }

  CodeLineEditingController _buildController(String text, int tabSize) {
    return CodeLineEditingController.fromText(
      text,
      CodeLineOptions(indentSize: tabSize),
    );
  }

  void _replaceController(
    CodeLineEditingController nextController, {
    CodeLineSelection? previousSelection,
  }) {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _controller = nextController;
    if (previousSelection != null) {
      _controller.selection = previousSelection;
    }
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightModes = _highlightModes(widget.language);
    final suggestions = _suggestions(widget.language);

    return Column(
      children: [
        Expanded(
          child: CodeEditor(
            controller: _controller,
            wordWrap: false,
            style: CodeEditorStyle(
              backgroundColor: EditorThemeColors.surface,
              textColor: EditorThemeColors.textPrimary,
              cursorColor: EditorThemeColors.accentBlue,
              cursorLineColor: EditorThemeColors.panelMuted,
              fontFamily: 'monospace',
              fontSize: _fontSize,
              codeTheme: CodeHighlightTheme(
                languages: highlightModes,
                theme: vs2015Theme,
              ),
            ),
            autocompleteSymbols: _symbolPairAutocomplete,
            indicatorBuilder: (context, editingController, chunkController, notifier) {
              return Container(
                color: EditorThemeColors.surfaceSoft,
                child: DefaultCodeLineNumber(
                  controller: editingController,
                  notifier: notifier,
                  textStyle: const TextStyle(fontSize: 12, color: EditorThemeColors.textMuted),
                ),
              );
            },
            sperator: const VerticalDivider(width: 1, thickness: 1, color: EditorThemeColors.border),
          ),
        ),
        Container(
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF0A1727),
            border: Border(top: BorderSide(color: Color(0x243D5572))),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final token = suggestions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                child: OutlinedButton(
                  onPressed: () => _insertToken(token),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    side: const BorderSide(color: Color(0x3F5A78A0)),
                    backgroundColor: const Color(0xFF0C1C30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  child: Text(token, style: const TextStyle(fontSize: 11, color: Color(0xFFD7E6FA))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _insertToken(String token) {
    final value = token == 'TAB' ? '\t' : token;
    _controller.replaceSelection(value);
    widget.onChanged(_controller.text);
  }

  Map<String, CodeHighlightThemeMode> _highlightModes(String language) {
    switch (language) {
      case 'python':
        return {'python': CodeHighlightThemeMode(mode: langPython)};
      case 'javascript':
        return {'javascript': CodeHighlightThemeMode(mode: langJavascript)};
      case 'java':
        return {'java': CodeHighlightThemeMode(mode: langJava)};
      case 'c':
        return {'c': CodeHighlightThemeMode(mode: langC)};
      case 'cpp':
        return {'cpp': CodeHighlightThemeMode(mode: langCpp)};
      case 'css':
        return {'css': CodeHighlightThemeMode(mode: langCss)};
      case 'xml':
        return {'xml': CodeHighlightThemeMode(mode: langXml)};
      default:
        return {'text': CodeHighlightThemeMode(mode: langPlaintext)};
    }
  }

  List<String> _suggestions(String language) {
    switch (language) {
      case 'python':
        return const ['def ', 'class ', 'import ', 'if ', 'else:', 'for ', 'while ', ':', '(', ')', '{', '}', '[', ']', '=', '""', 'TAB'];
      case 'javascript':
        return const ['function ', 'const ', 'let ', 'if ', 'else ', 'return ', '{', '}', '(', ')', '[', ']', ';', '=>', '.', ',', 'TAB'];
      case 'java':
        return const ['public ', 'class ', 'static ', 'void ', 'if ', 'else ', 'return ', '{', '}', '(', ')', '[', ']', ';', '.', ',', 'TAB'];
      case 'c':
      case 'cpp':
        return const ['#include ', 'int ', 'main()', 'if ', 'else ', 'for ', 'while ', 'return ', '{', '}', '(', ')', '[', ']', ';', '*', 'TAB'];
      case 'css':
        return const ['body', '.class', '#id', '@media ', '{', '}', ':', ';', 'margin', 'padding', 'color', 'background', 'TAB'];
      case 'xml':
        return const ['<div>', '</div>', '<p>', '</p>', '<h1>', '</h1>', 'class=""', 'id=""', '<', '>', '/', 'TAB'];
      default:
        return const ['{', '}', '(', ')', '[', ']', ';', ':', ',', '.', '=', '""', 'TAB'];
    }
  }
}
