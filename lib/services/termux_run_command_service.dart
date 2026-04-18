import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';

class TermuxRunCommandService {
  static const MethodChannel _channel = MethodChannel(AppConstants.termuxChannel);

  Future<bool> hasRunCommandPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('hasRunCommandPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestRunCommandPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestRunCommandPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod<bool>('openAppSettings');
    } catch (_) {
      // ignore
    }
  }

  Future<bool> ensureRunCommandPermission() async {
    if (await hasRunCommandPermission()) {
      return true;
    }

    return requestRunCommandPermission();
  }

  Future<String> runCommand({
    required String command,
    String workingDir = AppConstants.termuxHome,
  }) async {
    try {
      // Best-effort request; do not block execution because some devices/ROMs
      // report custom permission state inconsistently.
      await ensureRunCommandPermission();

      final result = await _channel.invokeMethod<String>(
        'runCommand',
        {
          'command': command,
          'workingDir': workingDir,
        },
      );
      return result ?? 'Command sent';
    } catch (error) {
      return 'Termux command error: $error';
    }
  }
}
