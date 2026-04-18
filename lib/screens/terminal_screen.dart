import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart' hide TerminalController;

import '../controllers/terminal_controller.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/editor_theme.dart';
import '../services/termux_run_command_service.dart';

class TerminalScreen extends StatelessWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final terminalController = context.watch<TerminalController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF061427), Color(0xFF030A14)],
        ),
      ),
      child: Column(
        children: [
          _TerminalHeader(controller: terminalController),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A111A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x2A5B6D81)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: TerminalView(
                  terminalController.terminal,
                  autofocus: true,
                  deleteDetection: true,
                  backgroundOpacity: 1,
                  theme: _devDroidTerminalTheme,
                  textStyle: TerminalStyle(
                    fontFamily: 'monospace',
                    fontSize: AppTypography.meta.fontSize!,
                    height: 1.24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _TerminalExtraKeysBar(onKeyTap: context.read<TerminalController>().handleExtraKey),
        ],
      ),
    );
  }
}

class _TerminalHeader extends StatelessWidget {
  const _TerminalHeader({required this.controller});

  final TerminalController controller;

  @override
  Widget build(BuildContext context) {
    final String statusLabel;
    final Color statusColor;

    if (controller.connecting) {
      statusLabel = 'CONNECTING';
      statusColor = const Color(0xFFE3B341);
    } else if (controller.isExecuting) {
      statusLabel = 'RUNNING';
      statusColor = const Color(0xFF2EA043);
    } else {
      statusLabel = 'READY';
      statusColor = const Color(0xFF86C7FF);
    }

    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x2F87A3C3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.terminal_rounded, size: 16, color: Color(0xFF86C7FF)),
          const SizedBox(width: 8),
          const Text('TERMINAL', style: AppTypography.terminalHeader),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: statusColor.withValues(alpha: 0.42)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: AppTypography.status.fontSize,
                letterSpacing: AppTypography.status.letterSpacing,
                fontWeight: AppTypography.status.fontWeight,
                color: statusColor,
              ),
            ),
          ),
          const Spacer(),
          if (controller.connecting)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            tooltip: 'Fix Termux Access',
            onPressed: () async {
              await context.read<TermuxRunCommandService>().openAppSettings();
            },
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x1930D0A7),
              side: const BorderSide(color: Color(0x2F30D0A7)),
            ),
            icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Clear terminal',
            onPressed: () => controller.clearOutput(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x1A8BC3FF),
              side: const BorderSide(color: Color(0x2E8BC3FF)),
            ),
            icon: const Icon(Icons.clear_all_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _TerminalExtraKeysBar extends StatelessWidget {
  const _TerminalExtraKeysBar({required this.onKeyTap});

  final ValueChanged<String> onKeyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF070F1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x24395A78)),
      ),
      child: Column(
        children: [
          _row(const [
            _TerminalKey('ESC', 'ESC'),
            _TerminalKey('/', '/'),
            _TerminalKey('-', '-'),
            _TerminalKey('HOME', 'HOME'),
            _TerminalKey('\u2191', 'UP'),
            _TerminalKey('END', 'END'),
            _TerminalKey('PGUP', 'PGUP'),
          ]),
          const SizedBox(height: 6),
          _row(const [
            _TerminalKey('TAB', 'TAB'),
            _TerminalKey('CTRL', 'CTRL'),
            _TerminalKey('ALT', 'ALT'),
            _TerminalKey('\u2190', 'LEFT'),
            _TerminalKey('\u2193', 'DOWN'),
            _TerminalKey('\u2192', 'RIGHT'),
            _TerminalKey('PGDN', 'PGDN'),
          ]),
          const SizedBox(height: 6),
          _row(const [
            _TerminalKey('{', '{'),
            _TerminalKey('}', '}'),
            _TerminalKey('[', '['),
            _TerminalKey(']', ']'),
            _TerminalKey('(', '('),
            _TerminalKey(')', ')'),
            _TerminalKey(';', ';'),
            _TerminalKey(':', ':'),
            _TerminalKey('"', '"'),
            _TerminalKey("'", "'"),
            _TerminalKey('=', '='),
            _TerminalKey('ENTER', 'ENTER'),
          ]),
        ],
      ),
    );
  }

  Widget _row(List<_TerminalKey> keys) {
    return Row(
      children: keys
          .map(
            (key) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () => onKeyTap(key.value),
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1624),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFF1A3552)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        key.label,
                        style: AppTypography.terminalKey.copyWith(color: const Color(0xFFD4DCE6)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TerminalKey {
  const _TerminalKey(this.label, this.value);

  final String label;
  final String value;
}

const TerminalTheme _devDroidTerminalTheme = TerminalTheme(
  cursor: Color(0xFF8FC8FF),
  selection: Color(0x553A88E8),
  foreground: Color(0xFFD6DEEB),
  background: Color(0xFF0A111A),
  black: Color(0xFF101826),
  red: Color(0xFFF7768E),
  green: Color(0xFF9ECE6A),
  yellow: Color(0xFFE0AF68),
  blue: Color(0xFF7AA2F7),
  magenta: Color(0xFFBB9AF7),
  cyan: Color(0xFF7DCFFF),
  white: Color(0xFFBFC6D3),
  brightBlack: Color(0xFF586176),
  brightRed: Color(0xFFFF899D),
  brightGreen: Color(0xFFB3D98E),
  brightYellow: Color(0xFFE7C28D),
  brightBlue: Color(0xFF8AB4FF),
  brightMagenta: Color(0xFFC7A8FF),
  brightCyan: Color(0xFF97DAFF),
  brightWhite: Color(0xFFEAF2FF),
  searchHitBackground: Color(0xFF26364A),
  searchHitBackgroundCurrent: Color(0xFF35506E),
  searchHitForeground: EditorThemeColors.textPrimary,
);
