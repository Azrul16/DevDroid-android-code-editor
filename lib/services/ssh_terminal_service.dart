import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';

class SshTerminalService {
  SSHClient? _client;
  SSHSession? _session;
  final StreamController<String> _outputController = StreamController<String>.broadcast();

  Stream<String> get output => _outputController.stream;

  bool get isConnected => _client != null && _session != null;

  Future<void> connect({
    required String username,
    required String password,
    String host = '127.0.0.1',
    int port = 8022,
  }) async {
    final socket = await SSHSocket.connect(host, port);

    _client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );

    _session = await _client!.shell();

    _session!.stdout.cast<List<int>>().transform(utf8.decoder).listen((data) {
      _outputController.add(data);
    });

    _session!.stderr.cast<List<int>>().transform(utf8.decoder).listen((data) {
      _outputController.add(data);
    });
  }

  void write(String input) {
    _session?.write(utf8.encode(input));
  }

  Future<void> close() async {
    _session?.close();
    _client?.close();
    _session = null;
    _client = null;
  }

  void dispose() {
    close();
    _outputController.close();
  }
}
