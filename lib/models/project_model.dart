class ProjectModel {
  const ProjectModel({
    required this.name,
    required this.path,
    this.lastOpened,
  });

  final String name;
  final String path;
  final DateTime? lastOpened;
}
