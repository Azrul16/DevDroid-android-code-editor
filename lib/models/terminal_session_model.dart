class TerminalSessionModel {
  const TerminalSessionModel({
    required this.id,
    required this.name,
    required this.connected,
  });

  final String id;
  final String name;
  final bool connected;
}
