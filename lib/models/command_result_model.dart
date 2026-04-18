class CommandResultModel {
  const CommandResultModel({
    required this.command,
    required this.success,
    required this.message,
    this.timestamp,
  });

  final String command;
  final bool success;
  final String message;
  final DateTime? timestamp;
}
