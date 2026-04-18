import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xterm/xterm.dart';

import '../services/ssh_terminal_service.dart';
import '../services/termux_run_command_service.dart';

class TerminalController extends ChangeNotifier {
  TerminalController(this._termuxService, this._sshService) {
    _sshSubscription = _sshService.output.listen((line) {
      terminal.write(line);
    });

    terminal.onOutput = _handleTerminalOutput;
    _boot();
  }

  final TermuxRunCommandService _termuxService;
  final SshTerminalService _sshService;

  final Terminal terminal = Terminal(maxLines: 5000);

  bool connecting = false;
  bool _isExecuting = false;
  bool get isExecuting => _isExecuting;
  String _currentInput = '';
  int _cursorPosition = 0;
  final String _prompt = r'devdroid@android:~$ ';

  late final StreamSubscription<String> _sshSubscription;

  Future<void> _boot() async {
    terminal.write('DevDroid Terminal v1\r\n');
    terminal.write('Type command and press Enter.\r\n\r\n');
    _writePrompt();
  }

  void _writePrompt() {
    terminal.write(_prompt);
  }

  void _refreshCurrentLine() {
    terminal.write('\r');
    terminal.write(_prompt);
    terminal.write(_currentInput);
    terminal.write(' ');

    final moveLeftCount = (_currentInput.length - _cursorPosition) + 1;
    if (moveLeftCount > 0) {
      terminal.write('\x1b[${moveLeftCount}D');
    }
  }

  void _insertText(String value) {
    final left = _currentInput.substring(0, _cursorPosition);
    final right = _currentInput.substring(_cursorPosition);
    _currentInput = '$left$value$right';
    _cursorPosition += value.length;
    _refreshCurrentLine();
  }

  void _backspace() {
    if (_cursorPosition <= 0 || _currentInput.isEmpty) {
      return;
    }
    final left = _currentInput.substring(0, _cursorPosition - 1);
    final right = _currentInput.substring(_cursorPosition);
    _currentInput = '$left$right';
    _cursorPosition -= 1;
    _refreshCurrentLine();
  }

  void _moveLeft() {
    if (_cursorPosition <= 0) {
      return;
    }
    _cursorPosition -= 1;
    _refreshCurrentLine();
  }

  void _moveRight() {
    if (_cursorPosition >= _currentInput.length) {
      return;
    }
    _cursorPosition += 1;
    _refreshCurrentLine();
  }

  void _moveHome() {
    _cursorPosition = 0;
    _refreshCurrentLine();
  }

  void _moveEnd() {
    _cursorPosition = _currentInput.length;
    _refreshCurrentLine();
  }

  void _handleTerminalOutput(String data) {
    if (_isExecuting) {
      return;
    }

    if (data == '\x1b[D') {
      _moveLeft();
      return;
    }
    if (data == '\x1b[C') {
      _moveRight();
      return;
    }
    if (data == '\x1b[H') {
      _moveHome();
      return;
    }
    if (data == '\x1b[F') {
      _moveEnd();
      return;
    }

    for (final rune in data.runes) {
      final char = String.fromCharCode(rune);

      if (char == '\r' || char == '\n') {
        final command = _currentInput.trim();
        _currentInput = '';
        _cursorPosition = 0;
        terminal.write('\r\n');

        if (command.isEmpty) {
          _writePrompt();
          continue;
        }

        _executeCommand(command);
        continue;
      }

      if (rune == 127 || rune == 8) {
        _backspace();
        continue;
      }

      if (rune == 9) {
        _insertText('\t');
        continue;
      }

      if (rune >= 32) {
        _insertText(char);
      }
    }
  }

  Future<void> _executeCommand(String command) async {
    _isExecuting = true;
    notifyListeners();

    final result = await _termuxService.runCommand(
      command: command,
      workingDir: '/data/data/com.termux/files/home',
    );

    if (result.isNotEmpty) {
      terminal.write('$result\r\n');
    }

    _writePrompt();
    _isExecuting = false;
    notifyListeners();
  }

  Future<void> runQuickCommand(String command, {String? workingDir}) async {
    if (command.trim().isEmpty) {
      return;
    }

    if (_isExecuting) {
      terminal.write('\r\n[busy] wait for current command to finish\r\n');
      _writePrompt();
      return;
    }

    terminal.write('$command\r\n');
    _isExecuting = true;
    notifyListeners();

    final result = await _termuxService.runCommand(
      command: command,
      workingDir: workingDir ?? '/data/data/com.termux/files/home',
    );

    if (result.isNotEmpty) {
      terminal.write('$result\r\n');
    }

    _isExecuting = false;
    _writePrompt();
    notifyListeners();
  }

  void appendOutput(String line) {
    terminal.write('\r\n$line\r\n');
    _writePrompt();
    notifyListeners();
  }

  void handleExtraKey(String key) {
    if (_isExecuting) {
      return;
    }

    switch (key) {
      case 'ESC':
        _insertText('\x1b');
        break;
      case 'TAB':
        _insertText('\t');
        break;
      case 'HOME':
        _moveHome();
        break;
      case 'END':
        _moveEnd();
        break;
      case 'LEFT':
        _moveLeft();
        break;
      case 'RIGHT':
        _moveRight();
        break;
      case 'UP':
      case 'DOWN':
      case 'PGUP':
      case 'PGDN':
      case 'CTRL':
      case 'ALT':
        break;
      case 'ENTER':
        _handleTerminalOutput('\n');
        break;
      default:
        _insertText(key);
        break;
    }
  }

  Future<void> connectSsh({
    required String username,
    required String password,
  }) async {
    connecting = true;
    notifyListeners();

    try {
      await _sshService.connect(username: username, password: password);
      terminal.write('\r\nSSH connected to Termux (127.0.0.1:8022)\r\n');
    } catch (error) {
      terminal.write('\r\nSSH error: $error\r\n');
    } finally {
      connecting = false;
      _writePrompt();
      notifyListeners();
    }
  }

  void sendInput(String input) {
    _sshService.write('$input\n');
  }

  void clearOutput() {
    terminal.eraseDisplay();
    terminal.eraseScrollbackOnly();
    _currentInput = '';
    _cursorPosition = 0;
    _writePrompt();
    notifyListeners();
  }

  @override
  void dispose() {
    _sshSubscription.cancel();
    _sshService.dispose();
    super.dispose();
  }
}
